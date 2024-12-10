/datum/mob_descriptor/age
	name = "Age"
	slot = MOB_DESCRIPTOR_SLOT_AGE
	verbage = "looks"

/datum/mob_descriptor/age/can_describe(mob/living/described)
	if(!ishuman(described))
		return FALSE
	return TRUE

/datum/mob_descriptor/age/get_description(mob/living/described)
	var/mob/living/carbon/human/H = described
	if(H.age == AGE_OLD)
		return "old"
	else if (H.age == AGE_MIDDLEAGED)
		return "middle-aged"
	else if (H.age == AGE_YOUNG)
		return "young"
	else
		return "adult"

/datum/mob_descriptor/penis
	name = "penis"
	slot = MOB_DESCRIPTOR_SLOT_PENIS
	verbage = "has"
	show_obscured = TRUE

/datum/mob_descriptor/penis/can_describe(mob/living/described)
	if(!ishuman(described))
		return FALSE
	var/mob/living/carbon/human/H = described
	var/obj/item/organ/penis/penis = H.getorganslot(ORGAN_SLOT_PENIS)
	if(!penis)
		return FALSE
	if(H.underwear)
		return FALSE
	if(!get_location_accessible(H, BODY_ZONE_PRECISE_GROIN))
		return FALSE
	return TRUE

/datum/mob_descriptor/penis/get_description(mob/living/described)
	var/mob/living/carbon/human/H = described
	var/obj/item/organ/penis/penis = H.getorganslot(ORGAN_SLOT_PENIS)
	var/adjective
	var/arousal_modifier

	switch(penis.penis_size)
		if(0 to 1.9)
			adjective = "tiny"
		if(2 to 3.9)
			adjective = "small"
		if(4 to 5.9)
			adjective = "below average"
		if(6 to 7.9)
			adjective = "average"
		if(8 to 9.9)
			adjective = "above average"
		if(10 to 11.9)
			adjective = "large"
		if(12 to 13.9)
			adjective = "huge"
		if(14 to 15.9)
			adjective = "massive"
		if(16 to INFINITY)
			adjective = "monstrous"

	switch(H.sexcon.arousal)
		if(80 to INFINITY)
			arousal_modifier = ", throbbing violently"
		if(50 to 80)
			arousal_modifier = ", turgid and leaky"
		if(20 to 50)
			arousal_modifier = ", stiffened and twitching"
		else
			arousal_modifier = ", soft and flaccid"

	var/used_name
	if(penis.erect_state != ERECT_STATE_HARD && penis.sheath_type != SHEATH_TYPE_NONE)
		switch(penis.sheath_type)
			if(SHEATH_TYPE_NORMAL)
				if(penis.penis_size >= 8)
					used_name = "a fat sheath"
				else
					used_name = "a sheath"
			if(SHEATH_TYPE_SLIT)
				used_name = "a genital slit"
	else
		used_name = "a <font color='#e9a8d1'>[adjective] [round(penis.penis_size, 0.1)] inch penis</font>[arousal_modifier]"

	return "[used_name]"

/datum/mob_descriptor/testicles
	name = "balls"
	slot = MOB_DESCRIPTOR_SLOT_TESTICLES
	verbage = "has"
	show_obscured = TRUE

/datum/mob_descriptor/testicles/can_describe(mob/living/described)
	if(!ishuman(described))
		return FALSE
	var/mob/living/carbon/human/H = described
	var/obj/item/organ/testicles/testes = H.getorganslot(ORGAN_SLOT_TESTICLES)
	if(!testes)
		return FALSE
	if(H.underwear)
		return FALSE
	if(!get_location_accessible(H, BODY_ZONE_PRECISE_GROIN))
		return FALSE
	var/obj/item/organ/penis/penis = H.getorganslot(ORGAN_SLOT_PENIS)
	if(penis && penis.sheath_type == SHEATH_TYPE_SLIT) //If our penis hides in a slit, dont describe testicles
		return FALSE
	return TRUE

/datum/mob_descriptor/testicles/get_description(mob/living/described)
	var/mob/living/carbon/human/H = described
	var/obj/item/organ/testicles/testes = H.getorganslot(ORGAN_SLOT_TESTICLES)
	var/adjective
	switch(testes.ball_size)
		if(1)
			adjective = "small"
		if(2)
			adjective = "average"
		if(3)
			adjective = "large"
	return "a <font color='#e9a8d1'>[adjective] pair of balls</font>"

/datum/mob_descriptor/vagina
	name = "vagina"
	slot = MOB_DESCRIPTOR_SLOT_VAGINA
	verbage = "has"
	show_obscured = TRUE

/datum/mob_descriptor/vagina/can_describe(mob/living/described)
	if(!ishuman(described))
		return FALSE
	var/mob/living/carbon/human/H = described
	var/obj/item/organ/vagina/vagina = H.getorganslot(ORGAN_SLOT_VAGINA)
	if(!vagina)
		return FALSE
	if(H.underwear)
		return FALSE
	if(!get_location_accessible(H, BODY_ZONE_PRECISE_GROIN))
		return FALSE
	return TRUE

/datum/mob_descriptor/vagina/get_description(mob/living/described)
	var/mob/living/carbon/human/H = described
	var/obj/item/organ/vagina/vagina = H.getorganslot(ORGAN_SLOT_VAGINA)
	var/vagina_type
	var/arousal_modifier
	switch(vagina.accessory_type)
		if(/datum/sprite_accessory/vagina/human)
			vagina_type = "plain vagina"
		if(/datum/sprite_accessory/vagina/hairy)
			vagina_type = "hairy vagina"
		if(/datum/sprite_accessory/vagina/spade)
			vagina_type = "spade vagina"
		if(/datum/sprite_accessory/vagina/furred)
			vagina_type = "furred vagina"
		if(/datum/sprite_accessory/vagina/gaping)
			vagina_type = "gaping vagina"
		if(/datum/sprite_accessory/vagina/cloaca)
			vagina_type = "cloaca"
	switch(H.sexcon.arousal)
		if(80 to INFINITY)
			arousal_modifier = ", gushing with arousal"
		if(50 to 80)
			arousal_modifier = ", slickened with arousal"
		if(20 to 50)
			arousal_modifier = ", wet with arousal"
	return "<font color='#e9a8d1'>a [vagina_type][arousal_modifier]</font>"

/datum/mob_descriptor/breasts
	name = "breasts"
	slot = MOB_DESCRIPTOR_SLOT_BREASTS
	verbage = "has"
	show_obscured = TRUE

/datum/mob_descriptor/breasts/can_describe(mob/living/described)
	if(!ishuman(described))
		return FALSE
	var/mob/living/carbon/human/H = described
	var/obj/item/organ/breasts/breasts = H.getorganslot(ORGAN_SLOT_BREASTS)
	if(!breasts)
		return FALSE
	if(H.underwear && H.underwear.covers_breasts)
		return FALSE
	if(!get_location_accessible(H, BODY_ZONE_CHEST))
		return FALSE
	return TRUE

/datum/mob_descriptor/breasts/get_description(mob/living/described)
	var/mob/living/carbon/human/H = described
	var/obj/item/organ/breasts/breasts = H.getorganslot(ORGAN_SLOT_BREASTS)
	var/adjective

	switch(breasts.breast_size)
		if(0)
			adjective = "perky"  // A-cup
		if(2)
			adjective = "pert"   // B-cup
		if(3)
			adjective = "full"   // C-cup
		if(4)
			adjective = "heavy"  // D-cup
		if(5)
			adjective = "massive" // E-cup

	var/cup_size = find_key_by_value(GLOB.named_breast_sizes, breasts.breast_size)
	return "<font color='#e9a8d1'>[adjective] [cup_size] breasts</font>"
