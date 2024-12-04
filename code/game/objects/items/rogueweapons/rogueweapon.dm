/obj/item/rogueweapon
	name = ""
	desc = ""
	icon_state = "sabre"
	item_state = "sabre"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 15
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	block_chance = 0
	armor_penetration = 0
	sharpness = IS_SHARP
	custom_materials = null
	possible_item_intents = list(SWORD_CUT, SWORD_THRUST)
	can_parry = TRUE
	wlength = 45
	sellprice = 1
	has_inspect_verb = TRUE
	parrysound = list('sound/combat/parry/parrygen.ogg')
	anvilrepair = /datum/skill/craft/weaponsmithing
	obj_flags = CAN_BE_HIT
	blade_dulling = DULLING_BASH
	max_integrity = 200
	wdefense = 3
	experimental_onhip = TRUE
	experimental_onback = TRUE
	embedding = list(
		"embed_chance" = 0,
		"embedded_pain_multiplier" = 1,
		"embedded_fall_chance" = 0,
	)
	var/initial_sl
	var/list/possible_enhancements
	var/renamed_name
	resistance_flags = FIRE_PROOF

/obj/item/rogueweapon/Initialize()
	. = ..()
	force_wielded = force + (force * 0.4) // This is equivilant to 1 point of strength
	if(!destroy_message)
		var/yea = pick("[src] is broken!", "[src] is useless!", "[src] is destroyed!")
		destroy_message = span_warning("[yea]")
/obj/item/rogueweapon/get_examine_string(mob/user, thats = FALSE)
	return "[thats? "That's ":""]<b>[get_examine_name(user)]</b>"

/obj/item/rogueweapon/get_dismemberment_chance(obj/item/bodypart/affecting, mob/user)
	if(!get_sharpness() || !affecting.can_dismember(src))
		return 0

	var/total_dam = affecting.get_damage()
	var/nuforce = get_complex_damage(src, user)
	
	// Blade integrity check (specific to dismemberment)
	if(max_blade_int && dismember_blade_int)
		var/blade_int_modifier = (blade_int / dismember_blade_int)
		if(blade_int_modifier <= 0.15)
			return 0
		nuforce *= blade_int_modifier

	if(user)
		if(istype(user.rmb_intent, /datum/rmb_intent/weak))
			return 0
		else if(istype(user.rmb_intent, /datum/rmb_intent/strong))
			nuforce *= 1.1

	// Calculate damage threshold based on traits
	var/hard_break = HAS_TRAIT(affecting, TRAIT_HARDDISMEMBER)
	var/easy_break = affecting.rotted || affecting.skeletonized || HAS_TRAIT(affecting, TRAIT_EASYDISMEMBER)
	if(affecting.owner)
		if(!hard_break)
			hard_break = HAS_TRAIT(affecting.owner, TRAIT_HARDDISMEMBER)
		if(!easy_break)
			easy_break = HAS_TRAIT(affecting.owner, TRAIT_EASYDISMEMBER)

	var/damage_threshold = affecting.max_damage * 0.5
	if(hard_break)
		damage_threshold = affecting.max_damage * 1 // Harder to break
	else if(easy_break)
		damage_threshold = affecting.max_damage * 0.1 // Easier to break
	
	// Check attack type (specific to dismemberment)
	var/is_cutting = (user?.used_intent.blade_class in list(BCLASS_CUT, BCLASS_CHOP))
	if(!is_cutting)
		return 0
	
	if(user?.used_intent.blade_class == BCLASS_CHOP)
		nuforce *= 1.1
	else if(user?.used_intent.blade_class == BCLASS_CUT)
		if((blade_int < dismember_blade_int * 0.5) || (total_dam < affecting.max_damage * 0.5))
			return 0

	if(nuforce < 10)
		return 0

	// Check if damage is enough to wound
	// Either by reaching threshold (50% HP) OR by dealing massive damage in one hit
	if(total_dam >= damage_threshold || nuforce >= (affecting.max_damage * 0.5))
		var/health_roll = 0
		if(affecting.owner)
			health_roll = affecting.owner.STACON || 10
		
		// HT scaling
		// HT 10 = +0
		// HT 15 = +8 (3x tougher)
		// HT 20 = +16 (9x tougher)
		var/ht_bonus = max(0, (health_roll - 10) * 1.6)
		
		// Damage impact - each 2 points of damage adds +1 to roll
		var/damage_mod = round(nuforce / 2)
		
		var/roll = rand(1,6) + rand(1,6) + rand(1,6) + damage_mod - ht_bonus
		
		// Thresholds for 3d6 + mods
		if(roll <= 11)  // 50% chance for no wound at HT 10
			return 0
		else if(roll <= 14)  // 12-14 light dismemberment (~7.41% at HT 15)
			if(hard_break)
				return 0.5
			else if(easy_break)
				return 1.5
			return 1
		else if(roll == 15)  // 15 nothing happens (~1.85% at HT 15)
			return 0
		// 16+ heavy dismemberment (~1.85% at HT 15)
		if(hard_break)
			return 1
		else if(easy_break)
			return 2
		return 1.5
	return 0

