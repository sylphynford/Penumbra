/datum/wound/dislocation
	name = "dislocation"
	check_name = span_bone("DISLOCATION")
	severity = WOUND_SEVERITY_MODERATE
	crit_message = list(
		"The %BODYPART jolts painfully!",
		"The %BODYPART is twisted out of place!",
		"The %BODYPART is wrenched out of it's socket!",
		"The %BODYPART is dislocated!",
	)
	sound_effect = "fracturedry"
	whp = 40
	woundpain = 40
	mob_overlay = ""
	sewn_overlay = ""
	can_sew = FALSE
	can_cauterize = FALSE
	disabling = FALSE
	critical = TRUE
	passive_healing = 0.25
	qdel_on_droplimb = TRUE
	zombie_infection_probability = 0
	werewolf_infection_probability = 0
	/// Whether or not we can be surgically relocated
	var/can_relocate = TRUE

/datum/wound/dislocation/can_stack_with(datum/wound/other)
	if(istype(other, /datum/wound/dislocation) && (type == other.type))
		return FALSE
	return TRUE

/datum/wound/dislocation/on_bodypart_gain(obj/item/bodypart/affected)
	. = ..()
	affected.temporary_crit_paralysis(20 SECONDS)
	ADD_TRAIT(affected, TRAIT_FINGERLESS, "[type]")
	switch(affected.body_zone)
		if(BODY_ZONE_R_LEG)
			affected.owner.add_movespeed_modifier(MOVESPEED_ID_DISLOCATION_RIGHT_LEG, multiplicative_slowdown = DISLOCATED_ADD_SLOWDOWN)
		if(BODY_ZONE_L_LEG)
			affected.owner.add_movespeed_modifier(MOVESPEED_ID_DISLOCATION_LEFT_LEG, multiplicative_slowdown = DISLOCATED_ADD_SLOWDOWN)
	// Add random heal timer between 3-5 minutes
	addtimer(CALLBACK(src, PROC_REF(relocate_bone)), rand(3 MINUTES, 5 MINUTES))

/datum/wound/dislocation/on_bodypart_loss(obj/item/bodypart/affected)
	. = ..()
	REMOVE_TRAIT(affected, TRAIT_FINGERLESS, "[type]")
	if(!affected.owner)
		return
	switch(affected.body_zone)
		if(BODY_ZONE_R_LEG)
			affected.owner.remove_movespeed_modifier(MOVESPEED_ID_DISLOCATION_RIGHT_LEG)
		if(BODY_ZONE_L_LEG)
			affected.owner.remove_movespeed_modifier(MOVESPEED_ID_DISLOCATION_LEFT_LEG)

/datum/wound/dislocation/on_mob_gain(mob/living/affected)
	. = ..()
	affected.emote("paincrit", TRUE)
	affected.Slowdown(20)
	shake_camera(affected, 2, 2)

/datum/wound/dislocation/proc/relocate_bone()
	if(!can_relocate)
		return FALSE
	if(bodypart_owner)
		bodypart_owner.remove_wound(src)
	else if(owner)
		owner.simple_remove_wound(src)
	return TRUE

/datum/wound/dislocation/proc/attempt_manual_relocation(mob/living/user, mob/living/carbon/victim)
	if(!can_relocate)
		return FALSE
	
	// Get relevant skills and stats
	var/surgery_skill = user.mind?.get_skill_level(/datum/skill/misc/medicine) || SKILL_LEVEL_NONE  // Medicine skill
	var/speed = user.STASPD || 0  // Performer's speed
	var/constitution = victim.STACON || 0  // Victim's constitution
	var/strength = user.STASTR || 0  // Performer's strength
	
	// Calculate success chance
	var/success_chance = 0
	
	// Add skill bonus (medicine skill is crucial)
	switch(surgery_skill)
		if(SKILL_LEVEL_LEGENDARY)
			success_chance += 90  // Master surgeon
		if(SKILL_LEVEL_MASTER)
			success_chance += 75
		if(SKILL_LEVEL_EXPERT)
			success_chance += 60
		if(SKILL_LEVEL_JOURNEYMAN)
			success_chance += 45
		if(SKILL_LEVEL_APPRENTICE)
			success_chance += 25
		if(SKILL_LEVEL_NOVICE)
			success_chance += 10
	
	// Add speed bonus (assuming average speed is 10)
	// Each point of speed above/below 10 adds/subtracts 5%
	success_chance += (speed - 10) * 5
	
	// Add constitution bonus (assuming average constitution is 10)
	// Each point of constitution above/below 10 adds/subtracts 5%
	success_chance += (constitution - 10) * 5
	
	// Cap at 90% and minimum of 5%
	success_chance = min(max(success_chance, 5), 90)
	
	// If in combat mode, skip success check and go straight to failure
	if(user.cmode)
		success_chance = 0
	
	// Attempt the relocation
	if(prob(success_chance))
		playsound(victim, "fracturedry", 100, TRUE, -2)  // Play fracture sound on success
		if(user == victim)
			victim.visible_message(span_notice("[user] successfully wrenches [user.p_their()] [bodypart_owner.name] back into place!"), \
								span_notice("You successfully wrench your [bodypart_owner.name] back into place!"), \
								span_hear("You hear bones crunching!"), COMBAT_MESSAGE_RANGE)
		else
			victim.visible_message(span_notice("[user] successfully wrenches [victim]'s [bodypart_owner.name] back into place!"), \
								span_notice("Your [bodypart_owner.name] is painfully wrenched back into place!"), \
								span_hear("You hear bones crunching!"), COMBAT_MESSAGE_RANGE, user)
			to_chat(user, span_notice("I successfully wrench [victim]'s [bodypart_owner.name] back into place!"))
		relocate_bone()
		return TRUE
	else
		// Failed - apply damage that can lead to fracture
		if(user == victim)
			victim.visible_message(span_danger("[user] twists [user.p_their()] [bodypart_owner.name] in the wrong direction!"), \
								span_warning("You twist your [bodypart_owner.name] painfully in the wrong direction!"), \
								span_hear("You hear bones shifting!"), COMBAT_MESSAGE_RANGE)
		else
			victim.visible_message(span_danger("[user] twists [victim]'s [bodypart_owner.name] in the wrong direction!"), \
								span_warning("Your [bodypart_owner.name] is twisted painfully in the wrong direction!"), \
								span_hear("You hear bones shifting!"), COMBAT_MESSAGE_RANGE, user)
			to_chat(user, span_warning("I twist too hard!"))
		
		// Calculate damage based on strength vs constitution
		var/damage = user.get_punch_dmg() // Get base punch damage
		damage *= 1.5 
		damage += ((strength - constitution) * 3)
		damage = max(damage, 18) // Minimum damage of 12 * 1.5
		
		// Apply damage using the combat system
		var/obj/item/bodypart/affected = bodypart_owner

		if(affected)
			affected.bodypart_attacked_by(BCLASS_TWIST, damage, user, affected.body_zone, crit_message = TRUE)
			if(length(victim.next_attack_msg))  // If we have any wound messages
				victim.visible_message(victim.next_attack_msg.Join())  // Show them
				victim.next_attack_msg.Cut()  // Then clear
		return FALSE

/datum/wound/dislocation/Topic(href, href_list)
	return

/datum/wound/dislocation/get_visible_name(mob/user)
	return ..()

/datum/wound/dislocation/neck
	name = "cervical dislocation"
	check_name = span_bone("NECK")
	crit_message = list(
		"The spine slips!",
		"The spine twists!",
		"The %BODYPART is wrenched out of it's socket!",
	)
	whp = 80
	woundpain = 100

/datum/wound/dislocation/neck/on_mob_gain(mob/living/affected)
	. = ..()
	ADD_TRAIT(affected, TRAIT_PARALYSIS, "[type]")
	if(iscarbon(affected))
		var/mob/living/carbon/carbon_affected = affected
		carbon_affected.update_disabled_bodyparts()

/datum/wound/dislocation/neck/on_mob_loss(mob/living/affected)
	. = ..()
	REMOVE_TRAIT(affected, TRAIT_PARALYSIS, "[type]")
	if(iscarbon(affected))
		var/mob/living/carbon/carbon_affected = affected
		carbon_affected.update_disabled_bodyparts()
