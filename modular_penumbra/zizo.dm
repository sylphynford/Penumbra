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

/datum/patron/inhumen/zizo/on_loss(mob/living/pious)
	. = ..()
	if(ishuman(pious))
		var/mob/living/carbon/human/H = pious
		REMOVE_TRAIT(H, TRAIT_CABAL, "[type]")
		H.verbs -= /datum/patron/inhumen/zizo/verb/remember_friends

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
