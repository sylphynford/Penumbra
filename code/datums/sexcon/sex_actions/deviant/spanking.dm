/datum/sex_action/spanking
	name = "Spank them"
	check_same_tile = FALSE

/datum/sex_action/spanking/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/spanking/can_perform(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	if(!get_location_accessible(target, BODY_ZONE_PRECISE_GROIN))
		return FALSE
	return TRUE

/datum/sex_action/spanking/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	..()
	user.visible_message(span_warning("[user] starts spanking [target]..."))

/datum/sex_action/spanking/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] spanks [target]!"))
	playsound(user, 'sound/foley/slap.ogg', 50, TRUE)
	
	// Flash the target's screen red briefly
	if(target.client)
		target.overlay_fullscreen("smash", /atom/movable/screen/fullscreen/flash, 3)
		addtimer(CALLBACK(target, TYPE_PROC_REF(/mob, clear_fullscreen), "smash"), 0.5 SECONDS)

	// Pain messages
	to_chat(target, span_warning("It stings!"))
	to_chat(target, span_danger("It hurts!"))

	// Handle masochist satisfaction
	if(target.has_flaw(/datum/charflaw/masochist))
		var/datum/charflaw/masochist/M = target.get_flaw(/datum/charflaw/masochist)
		if(M)
			M.next_paincrave = world.time + rand(35 MINUTES, 45 MINUTES)
			target.remove_stress(/datum/stressevent/vice)
			target.remove_status_effect(/datum/status_effect/debuff/addiction)
			to_chat(target, span_blue("<b>The spanking satisfies your need for pain...</b>"))

/datum/sex_action/spanking/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	..()
	user.visible_message(span_warning("[user] stops spanking [target]..."))
