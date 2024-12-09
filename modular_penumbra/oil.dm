/obj/item/frost_oil
	name = "frost oil"
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
	
	if(weapon.frost_hits)
		to_chat(user, span_warning("[target] is already coated in frost oil!"))
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
	name = "fire oil"
	desc = "A magical oil that can be applied to weapons to imbue them with burning properties."
	icon = 'modular_penumbra/icons/oil.dmi'
	icon_state = "frostoil"  // Using same icon for now
	w_class = WEIGHT_CLASS_SMALL
	var/uses = 1

/obj/item/fire_oil/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	
	if(!istype(target, /obj/item/rogueweapon))
		return
	
	var/obj/item/rogueweapon/weapon = target
	
	if(weapon.fire_hits)
		to_chat(user, span_warning("[target] is already coated in fire oil!"))
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

/obj/item/rogueweapon
	var/frost_hits = 0
	var/fire_hits = 0
	var/on_frost_hit = FALSE
	var/on_fire_hit = FALSE

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
