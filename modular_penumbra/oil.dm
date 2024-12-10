/obj/item/frost_oil
	name = "frost weapon oil"
	desc = "A magical oil that can be applied to weapons to imbue them with freezing properties."
	icon = 'modular_penumbra/icons/oil.dmi'
	icon_state = "frostoil"
	w_class = WEIGHT_CLASS_SMALL
	var/uses = 1

/obj/item/frost_oil/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	
	if(!istype(target, /obj/item/rogueweapon))
		return
	
	var/obj/item/rogueweapon/weapon = target
	
	if(weapon.frost_hits || weapon.fire_hits || weapon.acid_hits)
		to_chat(user, span_warning("[target] is already coated in oil!"))
		return
	
	user.visible_message(span_notice("[user] begins carefully applying frost oil to [target]..."), \
						span_notice("I begin carefully applying frost oil to [target]..."))
	
	if(!do_after(user, 3 SECONDS, target = target))
		return
	
	weapon.frost_hits = 10
	weapon.on_frost_hit = TRUE
	
	user.visible_message(span_notice("[user] applies frost oil to [target]."), \
						span_notice("I apply frost oil to [target]. It will last for 10 hits."))
	
	uses--
	if(uses <= 0)
		qdel(src)

/obj/item/fire_oil
	name = "fire weapon oil"
	desc = "A magical oil that can be applied to weapons to imbue them with burning properties."
	icon = 'modular_penumbra/icons/oil.dmi'
	icon_state = "fireoil" 
	w_class = WEIGHT_CLASS_SMALL
	var/uses = 1

/obj/item/fire_oil/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	
	if(!istype(target, /obj/item/rogueweapon))
		return
	
	var/obj/item/rogueweapon/weapon = target
	
	if(weapon.frost_hits || weapon.fire_hits || weapon.acid_hits)
		to_chat(user, span_warning("[target] is already coated in oil!"))
		return
	
	user.visible_message(span_notice("[user] begins carefully applying fire oil to [target]..."), \
						span_notice("I begin carefully applying fire oil to [target]..."))
	
	if(!do_after(user, 3 SECONDS, target = target))
		return
	
	weapon.fire_hits = 10
	weapon.on_fire_hit = TRUE
	
	user.visible_message(span_notice("[user] applies fire oil to [target]."), \
						span_notice("I apply fire oil to [target]. It will last for 10 hits."))
	
	uses--
	if(uses <= 0)
		qdel(src)

/obj/item/acid_oil
	name = "acid weapon oil"
	desc = "A corrosive oil that can be applied to weapons to temporarily enhance their armor penetration."
	icon = 'modular_penumbra/icons/oil.dmi'
	icon_state = "acidoil"
	w_class = WEIGHT_CLASS_SMALL
	var/uses = 1

/obj/item/acid_oil/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	
	if(!istype(target, /obj/item/rogueweapon))
		return
	
	var/obj/item/rogueweapon/weapon = target
	
	if(weapon.frost_hits || weapon.fire_hits || weapon.acid_hits)
		to_chat(user, span_warning("[target] is already coated in oil!"))
		return
	
	user.visible_message(span_notice("[user] begins carefully applying acid oil to [target]..."), \
						span_notice("I begin carefully applying acid oil to [target]..."))
	
	if(!do_after(user, 3 SECONDS, target = target))
		return
	
	weapon.original_armor_pen = weapon.armor_penetration
	weapon.armor_penetration = 100
	weapon.acid_hits = 5
	weapon.on_acid_hit = TRUE
	
	user.visible_message(span_notice("[user] applies acid oil to [target]."), \
						span_notice("I apply acid oil to [target]. It will last for 5 hits."))
	
	uses--
	if(uses <= 0)
		qdel(src)

/obj/item/rogueweapon
	var/frost_hits = 0
	var/fire_hits = 0
	var/acid_hits = 0
	var/on_frost_hit = FALSE
	var/on_fire_hit = FALSE
	var/on_acid_hit = FALSE
	var/original_armor_pen = 0

/obj/item/rogueweapon/funny_attack_effects(mob/living/target, mob/living/user)
	. = ..()
	if(frost_hits > 0 && on_frost_hit)
		target.apply_status_effect(/datum/status_effect/buff/frostbite5e, 5 SECONDS)
		frost_hits--
		if(frost_hits <= 0)
			on_frost_hit = FALSE
			to_chat(user, span_warning("The frost oil on [src] wears off!"))
	
	if(fire_hits > 0 && on_fire_hit)
		if(target.fire_stacks < 7)
			target.adjust_fire_stacks(5)
			if(target.fire_stacks > 0)
				target.IgniteMob()
		fire_hits--
		if(fire_hits <= 0)
			on_fire_hit = FALSE
			to_chat(user, span_warning("The fire oil on [src] burns away!"))

	if(acid_hits > 0 && on_acid_hit)
		acid_hits--
		if(acid_hits <= 0)
			on_acid_hit = FALSE
			armor_penetration = original_armor_pen
			to_chat(user, span_warning("The acid oil on [src] dissolves away!"))
