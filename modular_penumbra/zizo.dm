/mob/living/carbon/human
	var/datum/patron/inhumen/zizo/zizo_patron = null

/datum/patron/inhumen/zizo/verb/remember_friends()
	set name = "Remember Friends"
	set category = "CULTIST"
	set desc = "See who else follows Zizo."

	var/mob/living/carbon/human/H = usr
	if(!istype(H))
		return
	
	if(!H.mind)
		return

	if(!HAS_TRAIT(H, TRAIT_CABAL))
		to_chat(H, span_warning("Only followers of Zizo may use this power."))
		return

	var/list/cabal_members = list()
	for(var/mob/living/carbon/human/member in GLOB.human_list)
		if(HAS_TRAIT(member, TRAIT_CABAL) && member.mind)
			var/role_text = member.mind.assigned_role
			if(!role_text)
				role_text = "Unknown"
			var/leader_text = HAS_TRAIT(member, TRAIT_CABAL_LEADER) ? " (Leader)" : ""
			cabal_members += "[member.real_name] the [role_text][leader_text]"

	if(!length(cabal_members))
		to_chat(H, span_warning("There are no other followers of Zizo."))
		return

	to_chat(H, span_cultitalic("You remember other followers of Zizo:"))
	for(var/member in cabal_members)
		to_chat(H, span_cult("• [member]"))

/datum/patron/inhumen/zizo/on_gain(mob/living/pious)
	. = ..()
	if(ishuman(pious))
		var/mob/living/carbon/human/H = pious
		H.verbs |= /datum/patron/inhumen/zizo/verb/remember_friends
		if(!H.mind?.has_antag_datum(/datum/antagonist/vampirelord))
			H.verbs |= /datum/patron/inhumen/zizo/verb/create_omen
			H.zizo_patron = src

/datum/patron/inhumen/zizo/on_loss(mob/living/pious)
	. = ..()
	if(ishuman(pious))
		var/mob/living/carbon/human/H = pious
		REMOVE_TRAIT(H, TRAIT_CABAL, "[type]")
		H.verbs -= /datum/patron/inhumen/zizo/verb/remember_friends
		H.verbs -= /datum/patron/inhumen/zizo/verb/create_omen
		H.zizo_patron = null

/datum/patron/inhumen/zizo/verb/cabal_message()
	set name = "Send Cabal Message"
	set category = "CULTIST"
	set desc = "Send a telepathic message to all followers of Zizo."

	var/mob/living/carbon/human/H = usr
	if(!istype(H))
		return
	
	if(!H.mind)
		return

	if(!HAS_TRAIT(H, TRAIT_CABAL_LEADER))
		to_chat(H, span_warning("Only the Cabal Leader may use this power."))
		return

	if(H.next_cabal_message && world.time < H.next_cabal_message)
		var/time_left = round((H.next_cabal_message - world.time)/10)
		to_chat(H, span_warning("You must wait [time_left] seconds before sending another message.."))
		return

	var/message = input(H, "Enter a message to telepathically send to all followers.", "Cabal Message") as text|null
	if(!message)
		return

	if(!HAS_TRAIT(H, TRAIT_CABAL_LEADER)) 
		return

	// Visual feedback for nearby observers
	H.visible_message(span_warning("[H] starts contorting their hands in strange ways!"), \
					span_notice("You begin the ritual to send a telepathic message..."))
	
	// Start a do_after that will cancel if the caster moves
	if(!do_after(H, 150, H))  // 15 seconds
		to_chat(H, span_warning("Your concentration was broken! The message failed."))
		return

	H.next_cabal_message = world.time + (3 MINUTES)

	for(var/mob/living/carbon/human/member in GLOB.human_list)
		if(HAS_TRAIT(member, TRAIT_CABAL))
			if(member == H)
				to_chat(member, "<span class='cultlarge'><font size='4'>You send a telepathic message to the Cabal: [message]</font></span>")
			else
				to_chat(member, "<span class='cultlarge'><font size='4'>The Cabal Leader's voice echoes in your mind: [message]</font></span>")

/datum/controller/subsystem/ticker/proc/choose_cabal_leader()
	var/list/potential_leaders = list()
	log_game("Attempting to choose Cabal Leader...")
	var/cabal_count = 0
	
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(HAS_TRAIT(H, TRAIT_CABAL))
			cabal_count++
			if(!H.mind)
				continue
			if(H.mind.has_antag_datum(/datum/antagonist/vampirelord))
				log_game("- [H.real_name] skipped (Vampire Lord)")
				continue
			log_game("- [H.real_name] added to potential leaders")
			potential_leaders += H
	
	log_game("Found [cabal_count] total Cabal members and [length(potential_leaders)] potential leaders")
	
	if(length(potential_leaders))
		var/mob/living/carbon/human/chosen = pick(potential_leaders)
		ADD_TRAIT(chosen, TRAIT_CABAL_LEADER, TRAIT_GENERIC)
		chosen.verbs += /datum/patron/inhumen/zizo/verb/cabal_message
		chosen.verbs += /datum/patron/inhumen/zizo/verb/punish_follower
		chosen.verbs += /datum/patron/inhumen/zizo/verb/zizoconvert
		to_chat(chosen, "<span class='cultlarge'><font size='5'><b>You have been chosen as the Leader of the Cabal! Use your power to guide your followers to victory over the Psydonite fools.</b></font></span>")
		log_game("Chose [chosen.real_name] as Cabal Leader")
	else
		log_game("Failed to find any valid Cabal Leader candidates")

// Hook into game start
/datum/controller/subsystem/ticker/proc/setup_cabal_leader()
	addtimer(CALLBACK(src, PROC_REF(choose_cabal_leader)), 10 SECONDS)

/datum/patron/inhumen/zizo/verb/punish_follower()
	set name = "Punish Follower"
	set category = "CULTIST"
	set desc = "Strike down an unfaithful follower with unholy lightning."

	var/mob/living/carbon/human/H = usr
	if(!istype(H))
		return
	
	if(!H.mind)
		return

	if(!HAS_TRAIT(H, TRAIT_CABAL_LEADER))
		to_chat(H, span_warning("Only the Cabal Leader may use this power."))
		return

	if(H.next_punishment && world.time < H.next_punishment)
		var/time_left = round((H.next_punishment - world.time)/10)
		to_chat(H, span_warning("You must wait [time_left] seconds before punishing another follower."))
		return

	var/list/cabal_members = list()
	for(var/mob/living/carbon/human/member in GLOB.human_list)
		if(HAS_TRAIT(member, TRAIT_CABAL) && member != H && member.mind)
			if(member.mind.has_antag_datum(/datum/antagonist/vampirelord))
				continue
			cabal_members[member.real_name] = member

	if(!length(cabal_members))
		to_chat(H, span_warning("There are no followers to punish."))
		return

	var/chosen_name = input(H, "Choose a follower to punish", "Divine Punishment") as null|anything in cabal_members
	if(!chosen_name)
		return

	var/mob/living/carbon/human/target = cabal_members[chosen_name]
	if(!target || !HAS_TRAIT(target, TRAIT_CABAL))
		return

	H.next_punishment = world.time + (1 MINUTES)

	// Visual effects
	var/turf/T = get_turf(target)
	var/turf/lightning_source = get_step(get_step(target, NORTH), NORTH)
	lightning_source.Beam(target, icon_state="lightning[rand(1,12)]", time = 5)
	playsound(T, 'sound/magic/lightning.ogg', 100, TRUE)
	target.Stun(300) // 30 seconds stun
	if(ishuman(target))
		var/mob/living/carbon/human/target_human = target
		target_human.electrocution_animation(40)
	new /obj/effect/temp_visual/cult/sparks(T)

	// Damage
	target.adjustFireLoss(40)
	target.adjustBruteLoss(20)
	target.flash_act(1, TRUE, TRUE, TRUE)

	// Messages
	to_chat(H, "<span class='cultlarge'><font size='4'>You strike [target] with unholy punishment!</font></span>")
	to_chat(target, "<span class='cultlarge'><font size='4'>Your leader punishes you with unholy lightning!</font></span>")
	for(var/mob/living/carbon/human/member in GLOB.human_list)
		if(HAS_TRAIT(member, TRAIT_CABAL) && member != H && member != target)
			to_chat(member, "<span class='cultlarge'><font size='3'>[target] has been punished by the Cabal Leader!</font></span>")

/datum/patron/inhumen/zizo/verb/create_omen()
	set name = "Create Omen"
	set category = "CULTIST"
	set desc = "Perform a ritual with other followers to create an omen of Zizo's power."

	var/mob/living/carbon/human/H = usr
	if(!istype(H))
		return
	
	if(!H.mind)
		return

	if(!HAS_TRAIT(H, TRAIT_CABAL))
		to_chat(H, span_warning("Only followers of Zizo may use this power."))
		return

	if(H.mind.has_antag_datum(/datum/antagonist/vampirelord))
		to_chat(H, span_warning("Your vampiric nature prevents you from participating in this ritual."))
		return

	var/datum/patron/inhumen/zizo/patron = H.vars["zizo_patron"]
	if(!patron)
		to_chat(H, span_warning("Something went wrong with the ritual. (ERROR: No patron datum)"))
		return

	// Check for nearby Zizo followers
	var/list/nearby_followers = list()
	for(var/mob/living/carbon/human/nearby in orange(1, H))
		if(!HAS_TRAIT(nearby, TRAIT_CABAL))
			continue
		if(nearby.mind?.has_antag_datum(/datum/antagonist/vampirelord))
			continue
		if(nearby.stat >= UNCONSCIOUS)
			continue
		nearby_followers += nearby

	if(length(nearby_followers) < 2)
		to_chat(H, span_warning("The ritual requires three followers of Zizo standing together. (Only found [length(nearby_followers) + 1] including you)"))
		return

	// Check for the staff
	var/obj/item/rogueweapon/woodstaff/aries/staff = locate() in view(1, H)
	if(!staff)
		to_chat(H, span_warning("The ritual requires a Staff of the Shepherd placed before you."))
		return

	// Start the ritual
	H.visible_message(span_warning("[H] raises their arms and begins chanting in an otherworldly tongue!"), \
					span_cultlarge("You begin the ritual to create an omen of Zizo's power..."))

	// Alert other participants
	for(var/mob/living/carbon/human/participant in nearby_followers)
		to_chat(participant, span_cultlarge("Join the ritual by staying close to [H]!"))

	// Visual effect
	new /obj/effect/temp_visual/cult/sparks(get_turf(staff))
	
	// Start the ritual timer with correct callback
	if(!do_after(H, 200, target = staff, extra_checks = CALLBACK(patron, PROC_REF(check_ritual_conditions), H, nearby_followers, staff)))
		to_chat(H, span_warning("The ritual has been interrupted!"))
		return

	// Complete the ritual
	staff.visible_message(span_warning("The [staff] glows with an unholy light before crumbling to ash!"))
	
	// Randomly choose between haunts and goblin invasion
	if(prob(50))
		var/datum/round_event/rogue/haunts/E = new()
		E.start()
	else
		var/datum/round_event/rogue/gobinvade/E = new()
		E.start()
	
	priority_announce("Z is watching you.", "Bad Omen", 'sound/misc/evilevent.ogg')
	qdel(staff)

	// Visual effect for completion
	for(var/mob/living/carbon/human/participant in nearby_followers + H)
		new /obj/effect/temp_visual/cult/sparks(get_turf(participant))
		to_chat(participant, span_cultlarge("The ritual is complete! Zizo's power grows!"))

/datum/patron/inhumen/zizo/proc/check_ritual_conditions(mob/living/carbon/human/user, list/initial_followers, obj/item/rogueweapon/woodstaff/aries/staff)
	if(QDELETED(staff))
		return FALSE
		
	// Check if staff is still nearby
	if(!(staff in view(1, user)))
		return FALSE

	// Count current nearby followers
	var/list/current_followers = list()
	for(var/mob/living/carbon/human/nearby in orange(1, user))
		if(!HAS_TRAIT(nearby, TRAIT_CABAL))
			continue
		if(nearby.mind?.has_antag_datum(/datum/antagonist/vampirelord))
			continue
		if(nearby.stat >= UNCONSCIOUS)
			continue
		current_followers += nearby

	// Check if we still have enough followers
	if(length(current_followers) < 2)
		return FALSE

	return TRUE

/datum/patron/inhumen/zizo/verb/zizoconvert()
	set name = "Conversion"
	set category = "CULTIST"
	set desc = "Lend a fool a spark of Zizo's knowledge."

	var/mob/living/carbon/human/user = usr
	if(!istype(user))
		return

	var/list/valid_targets = list()
	for(var/mob/living/carbon/human/H in oview(1, user))
		if(H != user && H.health > 0 && !HAS_TRAIT(H, TRAIT_CABAL))
			valid_targets[H.name] = H

	if(!length(valid_targets))
		to_chat(user, span_warning("There are no valid targets nearby."))
		return
	
	var/target_name
	if(length(valid_targets) == 1)
		target_name = valid_targets[1]
	else
		target_name = input(user, "Choose a fool to convert.", "ZIZOFRENIA") as null|anything in valid_targets
		if(!target_name)
			return
	
	var/mob/living/carbon/human/target = valid_targets[target_name]
	if(QDELETED(target) || target.health <= 0)
		to_chat(user, span_warning("He's dead!"))
		return

	// Validate divine status
	if(istype(target.patron, /datum/patron/inhumen/zizo))
		to_chat(user, span_warning("This one already knows the TRUTH."))
		return

	// Begin conversion
	user.visible_message(span_notice("[user] places a hand upon [target]'s forehead..."))
	
	var/initial_user_loc = user.loc
	var/initial_target_loc = target.loc
	
	if(!do_after(user, 15, target = target, extra_checks = CALLBACK(GLOBAL_PROC, .proc/conversion_checks, user, target, initial_user_loc, initial_target_loc)))
		to_chat(user, span_warning("The conversion ritual has been interrupted!"))
		return

	// Complete conversion
	target.patron = new /datum/patron/inhumen/zizo()
	
	to_chat(target, span_notice("A phantasmagoria of runic inscriptions, a pulsating mass of flesh in a cage of mirrors. A flesh-lid opens and you feel its gaze upon you. A wave of nausea washes over you, your head throbs and in a filament of agony you realize the TRUTH."))
	target.emote("painscream", forced = TRUE)
	to_chat(user, span_notice("[target.name] has been ILLUMINATED!"))

