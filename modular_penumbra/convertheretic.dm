/datum/job/roguetown/confessor/verb/ConvertToDivine()
	set category = "Inquisition"
	set name = "Convert Heretic"
	
	var/mob/living/carbon/human/user = usr
	if(!istype(user))
		return
	
	// Check for required psicross structure
	var/obj/structure/fluff/psycross/near_psycross = locate() in oview(1, user)
	if(!near_psycross)
		to_chat(user, span_warning("You must be next to a Psicross structure to perform the conversion."))
		return

	// Check for golden psicross item
	var/obj/item/clothing/neck/roguetown/psicross/g/required_item = locate() in user.held_items
	if(!required_item)
		to_chat(user, span_warning("You need a Golden Psicross in your hands to start the conversion."))
		return

	// Get valid targets
	var/list/valid_targets = list()
	for(var/mob/living/carbon/human/H in oview(1, user))
		if(H != user && H.health > 0)
			valid_targets[H.name] = H

	if(!length(valid_targets))
		to_chat(user, span_warning("There are no valid targets nearby."))
		return

	// Select target
	var/target_name
	if(length(valid_targets) == 1)
		target_name = valid_targets[1]
	else
		target_name = input(user, "Choose a target for the conversion", "Target Selection") as null|anything in valid_targets
		if(!target_name)
			return
	
	var/mob/living/carbon/human/target = valid_targets[target_name]
	if(QDELETED(target) || target.health <= 0)
		to_chat(user, span_warning("The target is dead and cannot be converted."))
		return

	// Validate divine status
	if(istype(target.patron, /datum/patron/divine))
		to_chat(user, span_warning("This target is already under divine patronage, the conversion will fail."))
		user.apply_damage(30, BURN)
		qdel(required_item)
		return

	// Begin conversion
	user.visible_message(span_notice("[user] begins the conversion ritual on [target]..."))
	
	var/initial_user_loc = user.loc
	var/initial_target_loc = target.loc
	
	if(!do_after(user, 300, target = target, extra_checks = CALLBACK(GLOBAL_PROC, .proc/conversion_checks, user, target, initial_user_loc, initial_target_loc)))
		to_chat(user, span_warning("The conversion ritual has been interrupted!"))
		return

	// Complete conversion
	target.patron = new /datum/patron/divine/astrata()
	target.apply_damage(30, BURN)
	
	to_chat(target, span_notice("You have been converted to the true faith!"))
	to_chat(user, span_notice("[target.name] has been converted to the true faith!"))
	
	qdel(required_item)

/proc/conversion_checks(mob/living/carbon/human/user, mob/living/carbon/human/target, initial_user_loc, initial_target_loc)
	if(user.loc != initial_user_loc)
		return FALSE
	if(target.loc != initial_target_loc) 
		return FALSE
	if(!user || user.stat || user.health <= 0)
		return FALSE
	if(!target || target.stat || target.health <= 0)
		return FALSE
	return TRUE
