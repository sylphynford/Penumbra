GLOBAL_DATUM_INIT(SSroundstart_events, /datum/controller/subsystem/roundstart_events, new)

// Base types
/datum/round_event_control/roundstart
	var/runnable = TRUE
	var/event_announcement = ""
	var/selected_event_name = null

/datum/round_event/roundstart
	var/is_active = FALSE

	proc/apply_effect()
		SHOULD_CALL_PARENT(TRUE)
		return

/datum/round_event_control/roundstart/proc/can_spawn_event()
	if(!(SSticker.current_state in list(GAME_STATE_PREGAME, GAME_STATE_SETTING_UP, GAME_STATE_PLAYING)))
		return FALSE
	return runnable


// Matriarchy event
/datum/round_event/roundstart/matriarchy

/datum/round_event/roundstart/matriarchy/apply_effect()
	. = ..()
	is_active = TRUE
	
	var/mob/living/carbon/human/baron
	var/mob/living/carbon/human/consort
	
	// Find the Baron and Consort
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(H.mind?.assigned_role == "Baron" || H.mind?.assigned_role == "Baroness")
			baron = H
		else if(H.mind?.assigned_role == "Consort")
			consort = H
	
	if(!baron || !consort)
		return
	
	// Store their locations
	var/turf/baron_loc = get_turf(baron)
	var/turf/consort_loc = get_turf(consort)
	
	// Close any open color choice menus for the baron
	if(baron.client)
		baron.client << browse(null, "window=color_choice")
		baron.client << browse(null, "window=Banner Color")
	
	// Swap their positions
	baron.forceMove(consort_loc)
	consort.forceMove(baron_loc)
	
	// Update Consort's title and name
	consort.job = "Consort-Regnant"
	
	// Swap their spells
	var/list/baron_spells = list()
	var/list/consort_spells = list()
	
	// Store baron's spells
	if(baron.mind)
		baron_spells = baron.mind.spell_list.Copy()
		for(var/obj/effect/proc_holder/spell/S in baron_spells)
			baron.mind.RemoveSpell(S)
	
	// Store consort's spells
	if(consort.mind)
		consort_spells = consort.mind.spell_list.Copy()
		for(var/obj/effect/proc_holder/spell/S in consort_spells)
			consort.mind.RemoveSpell(S)
	
	// Give baron's spells to consort
	for(var/obj/effect/proc_holder/spell/S in baron_spells)
		if(consort.mind)
			consort.mind.AddSpell(S)
	
	// Give consort's spells to baron
	for(var/obj/effect/proc_holder/spell/S in consort_spells)
		if(baron.mind)
			baron.mind.AddSpell(S)
	
	// Transfer crown
	var/obj/item/clothing/head/crown = baron.get_item_by_slot(SLOT_HEAD)
	if(istype(crown, /obj/item/clothing/head/roguetown/crown/serpcrown))
		baron.dropItemToGround(crown)
		if(consort.head)
			qdel(consort.head)
		consort.equip_to_slot_or_del(crown, SLOT_HEAD)
	
	// Transfer cloak
	var/obj/item/clothing/cloak = baron.get_item_by_slot(SLOT_CLOAK)
	if(istype(cloak, /obj/item/clothing/cloak/lordcloak))
		baron.dropItemToGround(cloak)
		if(consort.cloak)
			qdel(consort.cloak)
		consort.equip_to_slot_or_del(cloak, SLOT_CLOAK)
	
	// Give new scepter directly to consort
	var/obj/item/rogueweapon/lordscepter/new_scepter = new(get_turf(consort))
	consort.put_in_hands(new_scepter)
	
	// Delete any existing scepter the baron might have
	for(var/obj/item/rogueweapon/lordscepter/old_scepter in baron.GetAllContents())
		qdel(old_scepter)
	
	// Give the color choice to the consort instead
	addtimer(CALLBACK(consort, TYPE_PROC_REF(/mob, lord_color_choice)), 50)

/datum/round_event_control/roundstart/matriarchy
	name = "Regnant"
	typepath = /datum/round_event/roundstart/matriarchy
	weight = 5
	event_announcement = "The crown passes to the Consort in a rare recognizance of ancient law..."
	runnable = TRUE



//Militia event

/datum/component/militia_blessing
	var/applied = TRUE

/datum/component/militia_blessing/Initialize()
	. = ..()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

// Then the rest of your existing event code
/datum/round_event/roundstart/militia
	var/static/list/weapon_skills = list(
		/obj/item/rogueweapon/sword/short = /datum/skill/combat/swords,
		/obj/item/rogueweapon/mace/cudgel = /datum/skill/combat/maces,
		/obj/item/rogueweapon/spear = /datum/skill/combat/polearms,
		/obj/item/rogueweapon/stoneaxe/woodcut/steel = /datum/skill/combat/axes
	)

	var/static/list/basic_weapons = list(
		/obj/item/rogueweapon/sword/short,
		/obj/item/rogueweapon/mace/cudgel,
		/obj/item/rogueweapon/spear,
		/obj/item/rogueweapon/stoneaxe/woodcut/steel
	)

/datum/round_event/roundstart/militia/apply_effect()
	. = ..()
	is_active = TRUE
	bless_existing_players()
	START_PROCESSING(SSprocessing, src)

/datum/round_event/roundstart/militia/process()
	if(!is_active)
		STOP_PROCESSING(SSprocessing, src)
		return
	
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(!H.mind?.key || H.GetComponent(/datum/component/militia_blessing))
			continue
		apply_blessing(H)

/datum/round_event/roundstart/militia/proc/bless_existing_players()
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		apply_blessing(H)

/datum/round_event/roundstart/militia/proc/apply_blessing(mob/living/carbon/human/H)
	if(!H || !H.mind || !H.job)
		return FALSE
	
	var/datum/job/J = SSjob.GetJob(H.job)
	if(!J || !(J.department_flag & PEASANTS))
		return FALSE

	// Give random basic weapon and increase its related skill
	var/weapon_type = pick(basic_weapons)
	var/obj/item/weapon = new weapon_type(get_turf(H))
	H.put_in_hands(weapon)
	
	// Increase the specific weapon skill
	var/skill_type = weapon_skills[weapon_type]
	if(skill_type)
		H.mind.adjust_skillrank(skill_type, 2, TRUE)
	
	// Always increase these basic combat skills
	H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)

	// Increase stats
	H.change_stat("strength", 1)
	H.change_stat("endurance", 1)
	H.change_stat("constitution", 1)
	
	// Add militia blessing component
	H.AddComponent(/datum/component/militia_blessing)

/datum/round_event_control/roundstart/militia
	name = "Militia"
	typepath = /datum/round_event/roundstart/militia
	weight = 5
	event_announcement = "The common folk have been drilled ruthlessly by the Baron into an organized militia.."
	runnable = TRUE


// Funky Water event
/datum/round_event/roundstart/funky_water/apply_effect()
	. = ..()
	is_active = TRUE
	START_PROCESSING(SSprocessing, src)

/datum/round_event/roundstart/funky_water/process()
	if(!is_active)
		STOP_PROCESSING(SSprocessing, src)
		return

	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(H.client && H.sexcon)
			// Check if they have water in their system
			if(H.reagents && H.reagents.has_reagent(/datum/reagent/water))
				H.sexcon.set_arousal(H.sexcon.arousal + 0.5)
				
				// Check for orgasm conditions
				if(H.sexcon.arousal >= 100 && H.sexcon.can_ejaculate())
					H.sexcon.ejaculate()
					H.sexcon.set_arousal(0)

/datum/round_event_control/roundstart/funky_water
	name = "Funky Water"
	typepath = /datum/round_event/roundstart/funky_water
	weight = 5
	event_announcement = "Something is wrong with the water supply..."
	runnable = TRUE

// Eternal Night event
/datum/round_event/roundstart/eternal_night

/datum/round_event/roundstart/eternal_night/apply_effect()
	. = ..()
	is_active = TRUE

	// Disable sunlight system
	for(var/obj/effect/sunlight/S in GLOB.sunlights)
		S.light_power = 0
		S.set_light(0)  // Just use set_light with brightness 0
		STOP_PROCESSING(SStodchange, S)

	// Prevent nightshift system from re-enabling lights
	GLOB.SSroundstart_events.eternal_night_active = TRUE
	START_PROCESSING(SSprocessing, src)

/datum/round_event/roundstart/eternal_night/process()
	if(!is_active)
		STOP_PROCESSING(SSprocessing, src)
		return

	// Continuously ensure lights stay disabled
	for(var/obj/effect/sunlight/S in GLOB.sunlights)
		if(S.light_power != 0)
			S.light_power = 0
			S.set_light(0)
			STOP_PROCESSING(SStodchange, S)

/datum/round_event_control/roundstart/eternal_night
	name = "Magician's Curse"
	typepath = /datum/round_event/roundstart/eternal_night
	weight = 5
	event_announcement = "The sky has been darkened by inhumen magicks..."
	runnable = TRUE

// Wealthy Benefactor event
/datum/round_event/roundstart/wealthy_benefactor
	var/static/list/rewarded_ckeys = list()

	/datum/round_event/roundstart/wealthy_benefactor/apply_effect()
		. = ..()
		is_active = TRUE
		START_PROCESSING(SSprocessing, src)

	/datum/round_event/roundstart/wealthy_benefactor/process()
		if(!is_active)
			STOP_PROCESSING(SSprocessing, src)
			return

		for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
			if(!H.mind || !H.mind.key)
				continue
			if(H.mind.key in rewarded_ckeys)
				continue
			if(H.mind.special_role in list("Vampire Lord", "Lich", "Bandit"))
				continue

			var/obj/item/storage/belt/rogue/pouch/coins/reallyrich/reward = new(get_turf(H))
			H.put_in_hands(reward)
			rewarded_ckeys += H.mind.key
			priority_announce("They say [H.real_name] recently had a large inheritence..", "Arcyne Phenomena")
			STOP_PROCESSING(SSprocessing, src)
			is_active = FALSE
			return

/datum/round_event_control/roundstart/wealthy_benefactor
	name = "Wealthy Benefactor"
	typepath = /datum/round_event/roundstart/wealthy_benefactor
	weight = 10
	event_announcement = ""
	runnable = TRUE

// Female Transformation event
/datum/round_event/roundstart/female_transformation
	var/static/list/transformed_ckeys = list()

/datum/round_event/roundstart/female_transformation/apply_effect()
	. = ..()
	is_active = TRUE
	transform_existing_players()
	START_PROCESSING(SSprocessing, src)

/datum/round_event/roundstart/female_transformation/process()
	if(!is_active)
		STOP_PROCESSING(SSprocessing, src)
		return
	transform_new_players()

/datum/round_event/roundstart/female_transformation/proc/transform_existing_players()
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		transform_human(H)

/datum/round_event/roundstart/female_transformation/proc/transform_new_players()
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(!H.mind?.key || (H.mind.key in transformed_ckeys))
			continue
		transform_human(H)

/datum/round_event/roundstart/female_transformation/proc/transform_human(mob/living/carbon/human/H)
	if(!H || !H.mind?.key || (H.mind.key in transformed_ckeys))
		return FALSE

	// Only transform males
	if(H.gender != MALE)
		return FALSE

	H.gender = FEMALE
	H.voice_type = "Feminine"
	H.pronouns = "she/her"
	// Update title/name
	var/prev_real_name = H.real_name

	// Convert male titles to female equivalents
	var/new_name = prev_real_name
	if(findtext(new_name, "Ser "))
		new_name = replacetext(new_name, "Ser ", "Dame ")
	else if(findtext(new_name, "Lord "))
		new_name = replacetext(new_name, "Lord ", "Lady ")
	else if(findtext(new_name, "King "))
		new_name = replacetext(new_name, "King ", "Queen ")
	else if(findtext(new_name, "Baron "))
		new_name = replacetext(new_name, "Baron ", "Baroness ")

	H.real_name = new_name
	H.name = new_name

	// Remove male organs and add female ones
	var/obj/item/organ/penis = H.getorganslot(ORGAN_SLOT_PENIS)
	if(penis)
		penis.Remove(H)
		qdel(penis)

	var/obj/item/organ/testicles = H.getorganslot(ORGAN_SLOT_TESTICLES)
	if(testicles)
		testicles.Remove(H)
		qdel(testicles)

	if(!H.getorganslot(ORGAN_SLOT_VAGINA))
		var/obj/item/organ/vagina/V = new
		V.Insert(H, TRUE)

	if(!H.getorganslot(ORGAN_SLOT_BREASTS))
		var/obj/item/organ/breasts/B = new
		B.Insert(H, TRUE)

	// Update appearance
	H.update_body()
	H.update_body_parts()
	H.regenerate_icons()
	H.regenerate_clothes()

	transformed_ckeys += H.mind.key


	return TRUE

/datum/round_event_control/roundstart/female_transformation
	name = "Sisterhood"
	typepath = /datum/round_event/roundstart/female_transformation
	weight = 0
	event_announcement = "Some sort of curse has turned all the men into women.."
	runnable = TRUE

// Great Lover event
/datum/round_event/roundstart/great_lover
	/datum/round_event/roundstart/great_lover/apply_effect()
		. = ..()
		var/list/valid_lovers = list()
		for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
			if(H.mind)
				valid_lovers += H

		if(!length(valid_lovers))
			return

		var/mob/living/carbon/human/chosen_lover = pick(valid_lovers)
		ADD_TRAIT(chosen_lover, TRAIT_GOODLOVER, "great_lover_event")

		var/list/lover_titles = list(
			"legendary lover",
			"fabled seducer",
			"incomparable romantic",
			"extraordinary paramour",
			"illustrious heartbreaker"
		)

		var/chosen_title = pick(lover_titles)
		priority_announce("The stars have aligned... [chosen_lover.real_name] has been blessed as a [chosen_title]!", "Arcyne Phenomena")

/datum/round_event_control/roundstart/great_lover
	name = "Great Lover"
	typepath = /datum/round_event/roundstart/great_lover
	weight = 10
	event_announcement = ""
	runnable = TRUE

	// Throne execution event
/datum/round_event/roundstart/throne_execution
	proc/announce_execution(message, failed = FALSE)
		priority_announce(message, "Official Execution[failed ? " Failed" : ""]")
		// Play decree sound to all living mobs
		for(var/mob/living/L in GLOB.mob_list)
			SEND_SOUND(L, sound('sound/misc/royal_decree.ogg', volume = 100))

	proc/is_execution_immune(mob/living/carbon/human/H)
		if(!H)
			return FALSE
		// Check for werewolf species
		if(istype(H, /mob/living/carbon/human/species/werewolf))
			return TRUE
		// Check for vampire lord and lich special_roles
		if(H.mind?.special_role in list("Vampire Lord", "Lich"))
			return TRUE
		return FALSE

	proc/handle_throne_execution(mob/living/carbon/human/speaker, list/speech_args)
		if(!speaker || !(speaker.job in list("Baron", "Baroness")))
			return

		// Check if they're buckled to the throne
		if(!speaker.buckled || !istype(speaker.buckled, /obj/structure/roguethrone))
			return

		var/spoken_text = speech_args[SPEECH_MESSAGE]

		// Convert to lowercase and remove punctuation for comparison
		spoken_text = lowertext(spoken_text)
		spoken_text = replacetext(spoken_text, "!", "")
		spoken_text = replacetext(spoken_text, ".", "")
		spoken_text = replacetext(spoken_text, "?", "")
		spoken_text = replacetext(spoken_text, ",", "")

		// Check if the message starts with "execute" (case insensitive)
		if(!findtext(spoken_text, "execute ", 1, 9))
			return

		// Extract and clean the name after "execute "
		var/target_name = trim(copytext(spoken_text, 9))
		if(!length(target_name))
			return

		// Look for a mob matching the spoken name (case insensitive)
		for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
			if(lowertext(H.real_name) == target_name)
				// Check if target has a mind
				if(!H.mind)
					return

				// Check for execution immunity
				if(is_execution_immune(H))
					announce_execution("[H.real_name] resists the execution through supernatural power!", TRUE)
					// Optional: Add visual effect to show immunity
					var/turf/T = get_turf(H)
					if(T)
						new /obj/effect/temp_visual/dir_setting/bloodsplatter(T)
					return

				// If not immune and has mind, proceed with execution
				announce_execution("[H.real_name] has been violently executed by official decree!")
				var/turf/T = get_turf(H)
				if(T)
					new /obj/effect/temp_visual/dir_setting/bloodsplatter(T)
				H.gib(TRUE, TRUE, TRUE)  // Full gibbing with animation
				break

	/datum/round_event/roundstart/throne_execution/apply_effect()
		. = ..()
		// Add throne speech handling to all humans
		for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
			if(H.job in list("Baron", "Baroness"))
				RegisterSignal(H, COMSIG_MOB_SAY, PROC_REF(handle_throne_execution))

		// Make all titans announce the execution instructions with sound
		for(var/obj/structure/roguemachine/titan/T in world)
			T.say("Say EXECUTE followed by the criminal's name while sitting on the throne to destroy them.")
			playsound(T.loc, 'sound/misc/machinetalk.ogg', 50, FALSE)

/datum/round_event_control/roundstart/throne_execution
	name = "Throne Execution Power"
	typepath = /datum/round_event/roundstart/throne_execution
	weight = 5
	event_announcement = "The throne crackles with newfound power..."
	runnable = TRUE

// Eternal Day event
/datum/round_event/roundstart/eternal_day

/datum/round_event/roundstart/eternal_day/apply_effect()
	. = ..()
	is_active = TRUE
	
	// Keep sunlight bright
	for(var/obj/effect/sunlight/S in GLOB.sunlights)
		S.light_power = 1
		S.light_color = pick("#dbbfbf", "#ddd7bd", "#add1b0", "#a4c0ca", "#ae9dc6", "#d09fbf")
		S.set_light(S.brightness)
		STOP_PROCESSING(SStodchange, S)
	
	START_PROCESSING(SSprocessing, src)

/datum/round_event/roundstart/eternal_day/process()
	if(!is_active)
		STOP_PROCESSING(SSprocessing, src)
		return

	// Continuously ensure lights stay bright
	for(var/obj/effect/sunlight/S in GLOB.sunlights)
		if(S.light_power != 1 || S.light_color in list("#100a18", "#0c0412", "#0f0012", "#c26f56", "#c05271", "#b84933", "#394579", "#49385d", "#3a1537"))
			S.light_power = 1
			S.light_color = pick("#dbbfbf", "#ddd7bd", "#add1b0", "#a4c0ca", "#ae9dc6", "#d09fbf")
			S.set_light(S.brightness)
			STOP_PROCESSING(SStodchange, S)

/datum/round_event_control/roundstart/eternal_day
	name = "Eternal Day"
	typepath = /datum/round_event/roundstart/eternal_day
	weight = 5
	event_announcement = "The sun refuses to set..."
	runnable = TRUE

// Admin verb for managing roundstart events
/client/proc/force_roundstart_event()
	set category = "Admin"
	set name = "Force Roundstart Event"
	set desc = "Triggers a specific roundstart event"

	if(!check_rights(R_ADMIN))
		return

	var/list/event_choices = list()
	for(var/event_path in subtypesof(/datum/round_event_control/roundstart))
		var/datum/round_event_control/roundstart/event = new event_path()
		if(event.runnable)  // Only show events that are marked as runnable
			event_choices[event.name] = event  // Store the actual event object

	var/choice = input(usr, "Choose an event to trigger", "Force Roundstart Event") as null|anything in event_choices
	if(!choice)
		return

	var/datum/round_event_control/roundstart/chosen_event = event_choices[choice]
	var/confirm = alert(usr, "Trigger [chosen_event.name]? \nAnnouncement: [chosen_event.event_announcement]", "Confirm Event", "Yes", "No")
	if(confirm != "Yes")
		return

	var/datum/round_event/roundstart/E = new chosen_event.typepath()
	if(E && istype(E))
		if(chosen_event.event_announcement)
			priority_announce(chosen_event.event_announcement, "Arcyne Phenomena")
		if(chosen_event.runnable)
			E.apply_effect()

		message_admins("[key_name_admin(usr)] forced the roundstart event: [chosen_event.name]")
		log_admin("[key_name(usr)] forced the roundstart event: [chosen_event.name]")

/datum/controller/subsystem/roundstart_events
	name = "Roundstart Events"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_EVENTS - 10

	var/list/datum/round_event_control/roundstart/roundstart_events = list()
	var/datum/round_event_control/roundstart/selected_event
	var/has_fired = FALSE
	var/list/active_events = list()
	var/eternal_night_active = FALSE

	Initialize()
		. = ..()
		for(var/path in subtypesof(/datum/round_event_control/roundstart))
			var/datum/round_event_control/roundstart/RE = new path()
			roundstart_events += RE

		// Create callback for ticker setup
		var/datum/callback/cb = CALLBACK(src, .proc/early_round_start)
		if(SSticker.round_start_events)
			SSticker.round_start_events += cb
		else
			SSticker.round_start_events = list(cb)

	proc/early_round_start()
		pick_roundstart_event()
		fire_event()

	proc/pick_roundstart_event()
		var/list/possible_events = list()

		for(var/datum/round_event_control/roundstart/RE as anything in roundstart_events)
			if(RE.runnable && RE.can_spawn_event())
				possible_events[RE] = RE.weight

		if(!length(possible_events))
			return FALSE

		selected_event = pickweight(possible_events)
		return TRUE

	proc/fire_event()
		if(!selected_event || !selected_event.typepath)
			return

		var/datum/round_event/roundstart/E = new selected_event.typepath()
		if(E && istype(E))
			active_events += E
			if(selected_event.runnable)
				E.apply_effect()
				if(selected_event.event_announcement && length(selected_event.event_announcement) > 0)
					priority_announce(selected_event.event_announcement, "Arcyne Phenomena")

				// Store the event name globally
				GLOB.roundstart_event_name = selected_event.name





