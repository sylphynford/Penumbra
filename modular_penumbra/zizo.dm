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

	H.next_cabal_message = world.time + (1 MINUTES)

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
		to_chat(chosen, "<span class='cultlarge'><font size='5'><b>You have been chosen as the Leader of the Cabal! Use your power to guide your followers to victory over the Psydonite fools.</b></font></span>")
		log_game("Chose [chosen.real_name] as Cabal Leader")
	else
		log_game("Failed to find any valid Cabal Leader candidates")

// Hook into game start
/datum/controller/subsystem/ticker/proc/setup_cabal_leader()
	addtimer(CALLBACK(src, PROC_REF(choose_cabal_leader)), 10 SECONDS)
