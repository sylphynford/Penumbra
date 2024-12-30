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
			cabal_members += "[member.real_name] the [role_text]"

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
