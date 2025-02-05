SUBSYSTEM_DEF(migrants)
	name = "Migrants"
	wait = 2 SECONDS
	runlevels = RUNLEVEL_GAME
	var/wave_number = 1
	var/current_wave = null
	var/time_until_next_wave = 10 SECONDS
	var/wave_timer = 0

	var/special_wave_type = null

	var/time_between_waves = 10 SECONDS
	var/time_between_fail_wave = 90 SECONDS
	var/wave_wait_time = 30 SECONDS

	var/list/spawned_waves = list()
	var/conditional_wave
	var/list/role_assignments = list() // Track assignments per role type
	var/consecutive_failures = 0 // Track consecutive failed attempts


/datum/controller/subsystem/migrants/Initialize()
	return ..()

/datum/controller/subsystem/migrants/fire(resumed)
	process_migrants(2 SECONDS)
	update_ui()

/datum/controller/subsystem/migrants/proc/set_current_wave(wave_type, time)
	current_wave = wave_type
	wave_timer = time

/datum/controller/subsystem/migrants/proc/process_migrants(dt)
	if(current_wave)
		process_current_wave(dt)
	else
		process_next_wave(dt)

/datum/controller/subsystem/migrants/proc/process_current_wave(dt)
	wave_timer -= dt

	if(wave_timer > 0)
		return
	// Try and spawn wave
	var/success = try_spawn_wave()
	if(success)
		log_game("Migrants: Successfully spawned wave: [current_wave]")
		wave_number++
		consecutive_failures = 0
		// Update available roles by removing filled ones
		var/datum/migrant_wave/wave = MIGRANT_WAVE(current_wave)
		for(var/role_type in role_assignments)
			var/filled_amount = length(role_assignments[role_type])
			if(filled_amount > 0)
				wave.roles[role_type] -= filled_amount
				if(wave.roles[role_type] <= 0)
					wave.roles -= role_type
	else
		log_game("Migrants: FAILED to spawn wave: [current_wave]")
		consecutive_failures++

	// Check if we need to keep the wave going for unfilled roles
	var/datum/migrant_wave/wave = MIGRANT_WAVE(current_wave)
	var/total_roles = wave.get_roles_amount()

	// Change wave if all roles are filled or we've had 2 consecutive failures
	if(total_roles <= 0 || consecutive_failures >= 2)
		consecutive_failures = 0
		wave_number = 1 // Reset wave number when changing waves
		// Reset ALL waves to their original values, not just the current one
		for(var/wave_type in GLOB.migrant_waves)
			var/datum/migrant_wave/reset_wave = MIGRANT_WAVE(wave_type)
			for(var/role_type in reset_wave.original_roles)
				reset_wave.roles[role_type] = reset_wave.original_roles[role_type]

		set_current_wave(null, 0)
		time_until_next_wave = time_between_waves
	else
		// Keep the wave going for remaining roles

		wave_timer = time_between_fail_wave
		role_assignments.Cut() // Reset role assignments for next attempt
		update_ui() // Update UI to show remaining available roles

/datum/controller/subsystem/migrants/proc/try_spawn_wave()
	var/datum/migrant_wave/wave = MIGRANT_WAVE(current_wave)
	/// Create initial assignment list
	var/list/assignments = list()
	/// Populate it with only available roles
	for(var/role_type in wave.roles)
		var/amount = wave.roles[role_type]
		for(var/i in 1 to amount)
			assignments += new /datum/migrant_assignment(role_type)
	/// Shuffle assignments so role rolling is not consistent
	assignments = shuffle(assignments)

	var/list/active_migrants = get_active_migrants()
	active_migrants = shuffle(active_migrants)

	var/list/picked_migrants = list()
	if(!length(active_migrants))
		return FALSE

	// First pass - assign priority players to roles they want
	for(var/datum/migrant_assignment/assignment as anything in assignments)
		if(!length(active_migrants))
			break
		if(assignment.client)
			continue

		var/list/priority = get_priority_players(active_migrants, assignment.role_type)
		if(!length(priority))
			continue

		// Track assignments per role type
		if(!role_assignments[assignment.role_type])
			role_assignments[assignment.role_type] = list()

		// Shuffle and pick randomly from valid candidates
		priority = shuffle(priority)
		var/slots_available = wave.roles[assignment.role_type] - length(role_assignments[assignment.role_type])
		if(slots_available > 0)
			var/client/picked = pick(priority)
			if(can_be_role(picked, assignment.role_type))
				active_migrants -= picked
				assignment.client = picked
				picked_migrants += picked
				role_assignments[assignment.role_type] += picked

	// Second pass - fill remaining slots with any available migrants
	for(var/datum/migrant_assignment/assignment as anything in assignments)
		if(!length(active_migrants))
			break
		if(assignment.client)
			continue

		var/client/picked
		for(var/client/client as anything in active_migrants)
			// Skip if client can't be this role
			if(!can_be_role(client, assignment.role_type))
				continue
			// Skip if client is already assigned to ANY role
			if(client in picked_migrants)
				continue
			// Skip if client hasn't specifically chosen this role
			if(!(assignment.role_type in client.prefs.migrant.role_preferences))
				continue
			picked = client
			break

		if(!picked)
			continue

		active_migrants -= picked
		assignment.client = picked
		picked_migrants += picked
		role_assignments[assignment.role_type] += picked

	// Find spawn points for assignments
	var/turf/spawn_location = get_spawn_turf_for_job(wave.spawn_landmark)
	var/atom/fallback_location = spawn_location

	var/list/turfs = get_safe_turfs_around_location(spawn_location)
	for(var/i in 1 to turfs.len)
		var/turf/turf = turfs[i]
		if(assignments.len < i)
			break
		var/datum/migrant_assignment/assignment = assignments[i]
		assignment.spawn_location = turf

	// Use fallback location for any assignments without a specific spawn point
	for(var/datum/migrant_assignment/assignment as anything in assignments)
		if(!assignment.spawn_location)
			assignment.spawn_location = fallback_location

	// Only spawn migrants that have clients assigned
	var/spawned_count = 0
	for(var/client/client as anything in picked_migrants)
		client.prefs.migrant.post_spawn()

	for(var/datum/migrant_assignment/assignment as anything in assignments)
		if(assignment.client) // Only spawn if we have a client
			spawn_migrant(wave, assignment, wave.spawn_on_location)
			spawned_count++

	if(!spawned_count) // If no one was spawned, consider it a failure
		return FALSE

	// Update wave counter
	var/used_wave_type = wave.type
	if(wave.shared_wave_type)
		used_wave_type = wave.shared_wave_type
	if(!spawned_waves[used_wave_type])
		spawned_waves[used_wave_type] = 0
	spawned_waves[used_wave_type] += 1

	message_admins("MIGRANTS: Spawned wave: [wave.name] (players: [spawned_count]) at [ADMIN_VERBOSEJMP(spawn_location)]")

	if(wave.type == special_wave_type)
		special_wave_type = null
	unset_all_active_migrants()

	return TRUE

/datum/controller/subsystem/migrants/proc/get_status_line()
	var/string = ""
	if(current_wave)
		var/datum/migrant_wave/wave = MIGRANT_WAVE(current_wave)
		string = "[wave.name] ([get_active_migrant_amount()]/[wave.get_roles_amount()]) - [wave_timer / (1 SECONDS)]s"
	else
		string = "Mist - [time_until_next_wave / (1 SECONDS)]s"
	return "Migrants: [string]"

/datum/controller/subsystem/migrants/proc/unset_all_active_migrants()
	var/list/active_migrants = get_active_migrants()
	if(active_migrants)
		for(var/client/client as anything in active_migrants)
			client.prefs.migrant.set_active(FALSE)

/datum/controller/subsystem/migrants/proc/get_safe_turfs_around_location(atom/location)
	var/list/turfs = list()
	var/turf/turfloc = get_turf(location)
	for(var/turf/turf as anything in RANGE_TURFS(2, turfloc))
		if(!isfloorturf(turf))
			continue
		if(islava(turf))
			continue
		if(is_blocked_turf(turf))
			continue
		turfs += turf
	turfs = shuffle(turfs)
	return turfs

/datum/controller/subsystem/migrants/proc/spawn_migrant(datum/migrant_wave/wave, datum/migrant_assignment/assignment, spawn_on_location)
	var/rank = "Migrant"
	var/mob/dead/new_player/newplayer = assignment.client.mob

	SSjob.AssignRole(newplayer, rank, TRUE)

	var/mob/living/character = newplayer.create_character(TRUE)	//creates the human and transfers vars and mind

	character.islatejoin = TRUE
	SSjob.EquipRank(character, rank, TRUE)

	var/datum/migrant_role/role = MIGRANT_ROLE(assignment.role_type)
	character.migrant_type = assignment.role_type


	/// copy pasta from AttemptLateSpawn(rank) further on TODO put it in a proc and use in both places

	/// Fade effect
	var/atom/movable/screen/splash/Spl = new(character.client, TRUE)
	Spl.Fade(TRUE)
	character.update_parallax_teleport()

	var/mob/living/carbon/human/humanc
	if(ishuman(character))
		humanc = character	//Let's retypecast the var to be human,

	SSticker.minds += character.mind
	GLOB.joined_player_list += character.ckey

	if(humanc)
		var/fakekey = character.ckey
		if(character.ckey in GLOB.anonymize)
			fakekey = get_fake_key(character.ckey)
		GLOB.character_list[character.mobid] = "[fakekey] was [character.real_name] ([rank])<BR>"
		GLOB.character_ckey_list[character.real_name] = character.ckey
		if(!character.mind.special_role)
			GLOB.actors_list[character.mobid] = "[character.real_name] as [rank]<BR>"
		log_character("[character.ckey] ([fakekey]) - [character.real_name] - [rank]")
	if(GLOB.respawncounts[character.ckey])
		var/AN = GLOB.respawncounts[character.ckey]
		AN++
		GLOB.respawncounts[character.ckey] = AN
	else
		GLOB.respawncounts[character.ckey] = 1

	/// And back to non copy pasta code
	if(spawn_on_location)
		character.forceMove(assignment.spawn_location)

	to_chat(character, span_alertsyndie("I am a [role.name]!"))
	to_chat(character, span_notice(wave.greet_text))
	to_chat(character, span_notice(role.greet_text))

	if(role.outfit)
		var/datum/outfit/outfit = new role.outfit()
		outfit.equip(character)

	if(role.antag_datum)
		character.mind.add_antag_datum(role.antag_datum)

	// Adding antag datums can move your character to places, so here's a bandaid
	if(spawn_on_location)
		character.forceMove(assignment.spawn_location)

	if(role.grant_lit_torch)
		grant_lit_torch(character)

	role.after_spawn(character)

	if(role.advclass_cat_rolls)
		SSrole_class_handler.setup_class_handler(character, role.advclass_cat_rolls)
		hugboxify_for_class_selection(character)
	else
		// Apply a special if we're not applying an adv class, otherwise let the adv class apply it afterwards
		apply_prefs_special(character)

/datum/controller/subsystem/migrants/proc/get_priority_players(list/players, role_type)
	var/list/priority = list()
	for(var/client/client as anything in players)
		if(!(role_type in client.prefs.migrant.role_preferences))
			continue
		priority += client
	return priority

/datum/controller/subsystem/migrants/proc/can_be_role(client/player, role_type)
	var/datum/migrant_role/role = MIGRANT_ROLE(role_type)
	if(!player)
		return FALSE
	if(!player.prefs)
		return FALSE
	var/datum/preferences/prefs = player.prefs
	if(role.allowed_races && !(prefs.pref_species.type in role.allowed_races))
		return FALSE
	if(role.allowed_sexes && !(prefs.gender in role.allowed_sexes))
		return FALSE
	if(role.allowed_ages && !(prefs.age in role.allowed_ages))
		return FALSE
	return TRUE

/datum/controller/subsystem/migrants/proc/process_next_wave(dt)
	time_until_next_wave -= dt
	if(time_until_next_wave > 0)
		return
	var/wave_type = roll_wave()
	if(wave_type)
		log_game("Migrants: Rolled wave: [wave_type]")
		set_current_wave(wave_type, wave_wait_time)

	time_until_next_wave = time_between_fail_wave

/datum/controller/subsystem/migrants/proc/roll_wave()

	// Special waves take priority.
	if(special_wave_type)
		return special_wave_type

	var/list/available_weighted_waves = list()

	var/active_migrants = get_active_migrant_amount()
	var/active_players = get_round_active_players()

	for(var/wave_type in GLOB.migrant_waves)
		var/datum/migrant_wave/wave = MIGRANT_WAVE(wave_type)
		if(!wave.can_roll)
			continue
		if(wave.unique)
			continue
		if(!isnull(wave.min_active) && active_migrants < wave.min_active)
			continue
		if(!isnull(wave.max_active) && active_migrants > wave.max_active)
			continue
		if(!isnull(wave.min_pop) && active_players < wave.min_pop)
			continue
		if(!isnull(wave.max_pop) && active_players > wave.max_pop)
			continue
		if(!isnull(wave.max_spawns))
			var/used_wave_type = wave.type
			if(wave.shared_wave_type)
				used_wave_type = wave.shared_wave_type
			if(spawned_waves[used_wave_type] && spawned_waves[used_wave_type] >= wave.max_spawns)
				continue
		available_weighted_waves[wave_type] = wave.weight

	if(!length(available_weighted_waves))
		return null
	return pickweight(available_weighted_waves)

/datum/controller/subsystem/migrants/proc/update_ui()
	for(var/client/client as anything in get_all_migrants())
		client.prefs.migrant.show_ui()

/datum/controller/subsystem/migrants/proc/get_active_migrant_amount()
	var/list/migrants = get_active_migrants()
	if(migrants)
		return migrants.len
	return 0

/datum/controller/subsystem/migrants/proc/get_stars_on_role(role_type)
	var/stars = 0
	var/list/active_migrants = get_active_migrants()
	if(active_migrants)
		for(var/client/client as anything in active_migrants)
			if(!(role_type in client.prefs.migrant.role_preferences))
				continue
			stars++
	return stars

/datum/controller/subsystem/migrants/proc/get_round_active_players()
	var/active = 0
	for(var/mob/player_mob as anything in GLOB.player_list)
		if(!player_mob.client)
			continue
		if(player_mob.stat == DEAD) //If not alive
			continue
		if(player_mob.client.is_afk()) //If afk
			continue
		if(!ishuman(player_mob))
			continue
		active++
	return active

/// Returns a list of all newplayer clients with active migrant pref
/datum/controller/subsystem/migrants/proc/get_active_migrants()
	var/list/available = list()
	for(var/client/client as anything in GLOB.clients)
		if(!client?.prefs?.migrant?.active)
			continue
		// Only include migrants who have selected a role
		if(!length(client.prefs.migrant.role_preferences))
			continue
		available += client
	return available

/// Returns a list of all newplayer clients
/datum/controller/subsystem/migrants/proc/get_all_migrants()
	var/list/migrants = list()
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
		if(!player.client)
			continue
		if(!player.client.prefs)
			continue
		migrants += player.client
	return migrants

/client/proc/admin_force_next_migrant_wave()
	set category = "GameMaster"
	set name = "Force Migrant Wave"
	if(!holder)
		return
	. = TRUE
	var/mob/user = usr
	message_admins("Admin [key_name_admin(user)] is forcing the next migrant wave.")
	var/picked_wave_type = input(user, "Choose migrant wave to force:", "Migrants")  as null|anything in GLOB.migrant_waves
	if(!picked_wave_type)
		return
	message_admins("Admin [key_name_admin(user)] forced next migrant wave: [picked_wave_type] (Arrival: 1 Minute)")
	log_game("Admin [key_name_admin(user)] forced next migrant wave: [picked_wave_type] (Arrival: 1 Minute)")
	SSmigrants.set_current_wave(picked_wave_type, (1 MINUTES))

/proc/get_spawn_turf_for_job(jobname)
	var/list/landmarks = list()
	for(var/obj/effect/landmark/start/sloc as anything in GLOB.start_landmarks_list)
		if(!(jobname in sloc.jobspawn_override))
			continue
		landmarks += sloc
	if(!length(landmarks))
		return null
	landmarks = shuffle(landmarks)
	return get_turf(pick(landmarks))

/proc/hugboxify_for_class_selection(mob/living/carbon/human/character)
	character.advsetup = 1
	character.invisibility = INVISIBILITY_MAXIMUM
	character.become_blind("advsetup")

	if(GLOB.adventurer_hugbox_duration)
		///FOR SOME silly FUCKING REASON THIS REFUSED TO WORK WITHOUT A FUCKING TIMER IT JUST FUCKED SHIT UP
		addtimer(CALLBACK(character, TYPE_PROC_REF(/mob/living/carbon/human, adv_hugboxing_start)), 1)

proc/grant_lit_torch(mob/living/carbon/human/character)
	var/obj/item/flashlight/flare/torch/torch = new()
	torch.spark_act()
	character.put_in_hands(torch, forced = TRUE)
