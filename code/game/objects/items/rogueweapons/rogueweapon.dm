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
		"embed_chance" = 20,
		"embedded_pain_multiplier" = 1,
		"embedded_fall_chance" = 0,
	)
	var/initial_sl
	var/list/possible_enhancements
	var/renamed_name
	resistance_flags = FIRE_PROOF
	var/is_hot = FALSE
	var/heat_timer

/obj/item/rogueweapon/Initialize()
	. = ..()
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
	var/pristine_blade = TRUE
	if(max_blade_int && dismember_blade_int)
		var/blade_int_modifier = (blade_int / dismember_blade_int)
		//blade is about as sharp as a brick it won't dismember shit
		if(blade_int_modifier <= 0.15)
			return 0
		nuforce *= blade_int_modifier
		pristine_blade = (blade_int >= (dismember_blade_int * 0.95))

	if(user)
		if(istype(user.rmb_intent, /datum/rmb_intent/weak))
			nuforce = 0
		else if(istype(user.rmb_intent, /datum/rmb_intent/strong))
			nuforce *= 1.1

		if(user.used_intent.blade_class == BCLASS_CHOP) //chopping attacks always attempt dismembering
			nuforce *= 1.1
		else if(user.used_intent.blade_class == BCLASS_CUT)
			if(!pristine_blade && (total_dam < affecting.max_damage * 0.8))
				return 0
		else
			return 0

	if(nuforce < 10)
		return 0

	var/probability = (nuforce) * (total_dam / affecting.max_damage)
	var/hard_dismember = HAS_TRAIT(affecting, TRAIT_HARDDISMEMBER)
	var/easy_dismember = affecting.rotted || affecting.skeletonized || HAS_TRAIT(affecting, TRAIT_EASYDISMEMBER)
	if(affecting.owner)
		if(!hard_dismember)
			hard_dismember = HAS_TRAIT(affecting.owner, TRAIT_HARDDISMEMBER)
		if(!easy_dismember)
			easy_dismember = HAS_TRAIT(affecting.owner, TRAIT_EASYDISMEMBER)
	if(hard_dismember)
		return min(probability, 5)
	else if(easy_dismember)
		return probability * 1.5
	return probability

/obj/item/rogueweapon/pre_attack(atom/A, mob/living/user, params)
	if(is_hot && !user.cmode)
		var/obj/item/bodypart/BP
		if(istype(A, /obj/item/bodypart))
			BP = A
		else if(ismob(A))
			var/mob/living/M = A
			BP = M.get_bodypart(check_zone(user.zone_selected))
		
		if(BP?.owner)
			for(var/datum/wound/W in BP.wounds)
				if(W.bleed_rate)
					user.visible_message(span_warning("[user] begins cauterizing [BP.owner]'s [BP.name] with [src]!"), 
									span_warning("You begin cauterizing [BP.owner]'s [BP.name] with [src]!"))
					
					if(do_after(user, 5 SECONDS, target = BP.owner))
						// Remove all bleeding wounds
						for(var/datum/wound/W2 in BP.wounds)
							if(W2.bleed_rate)
								qdel(W2)
						BP.receive_damage(burn = 80) // Massive burn damage
						user.visible_message(span_warning("[user] cauterizes [BP.owner]'s [BP.name] with [src]!"),
										span_warning("You cauterize [BP.owner]'s [BP.name] with [src]!"))
						playsound(src.loc, "burn", 100, FALSE, -1)
					return TRUE
	return ..()

/obj/item/rogueweapon/fire_act(added, maxstacks)
	. = ..()
	if(smeltresult && !is_hot)
		is_hot = TRUE
		if(heat_timer)
			deltimer(heat_timer)
		heat_timer = addtimer(CALLBACK(src, PROC_REF(cool_weapon)), 20 SECONDS, TIMER_STOPPABLE)

/obj/item/rogueweapon/proc/cool_weapon()
	is_hot = FALSE
	heat_timer = null

