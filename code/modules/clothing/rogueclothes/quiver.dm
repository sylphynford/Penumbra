
/obj/item/quiver
	name = "quiver"
	desc = ""
	icon_state = "quiver0"
	item_state = "quiver"
	icon = 'icons/roguetown/weapons/ammo.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/backpack_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/backpack_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_HIP|ITEM_SLOT_BACK
	resistance_flags = FIRE_PROOF
	max_integrity = 0
	equip_sound = 'sound/blank.ogg'
	bloody_icon_state = "bodyblood"
	alternate_worn_layer = UNDER_CLOAK_LAYER
	strip_delay = 20
	var/max_storage = 20
	var/list/ammo_list = list()
	sewrepair = TRUE

/obj/item/quiver/attack_turf(turf/T, mob/living/user)
	if(ammo_list.len >= max_storage)
		to_chat(user, span_warning("My [src.name] is full!"))
		return
	to_chat(user, span_notice("I begin to gather the ammunition..."))
	for(var/obj/item/ammo_casing/caseless/rogue/arrow in T.contents)
		if(do_after(user, 5))
			if(!eatarrow(arrow))
				break

/obj/item/quiver/proc/eatarrow(obj/A)
	if(A.type in subtypesof(/obj/item/ammo_casing/caseless/rogue))
		if(ammo_list.len < max_storage)
			A.forceMove(src)
			ammo_list += A
			update_icon()
			return TRUE
		else
			return FALSE

/obj/item/quiver/attackby(obj/A, loc, params)
	if(A.type in subtypesof(/obj/item/ammo_casing/caseless/rogue))
		if(ammo_list.len < max_storage)
			A.forceMove(src)
			ammo_list += A
			update_icon()
		else
			to_chat(loc, span_warning("Full!"))
		return
	if(istype(A, /obj/item/gun/ballistic/revolver/grenadelauncher/bow))
		var/obj/item/gun/ballistic/revolver/grenadelauncher/bow/B = A
		if(ammo_list.len && !B.chambered)
			for(var/AR in ammo_list)
				if(istype(AR, /obj/item/ammo_casing/caseless/rogue/arrow))
					ammo_list -= AR
					B.attackby(AR, loc, params)
					break
				else
					to_chat(loc, "<span class='warning'>Wrong ammunition kind!</span>")
					return
		return
	..()

	if(istype(A, /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow))
		var/obj/item/gun/ballistic/revolver/grenadelauncher/crossbow/C = A
		if(C.cocked)
			if(ammo_list.len && !C.chambered)
				for(var/BT in ammo_list)
					if(istype(BT, /obj/item/ammo_casing/caseless/rogue/bolt))
						ammo_list -= BT
						C.attackby(BT, loc, params)
						break
					else
						to_chat(loc, "<span class='warning'>Wrong ammunition kind!</span>")
						return
		else
			to_chat(loc, "<span class='warning'>I need to cock the crossbow first.</span>")
			return

/obj/item/quiver/attack_right(mob/user)
	if(ammo_list.len)
		var/obj/O = ammo_list[ammo_list.len]
		ammo_list -= O
		O.forceMove(user.loc)
		user.put_in_hands(O)
		update_icon()
		return TRUE

/obj/item/quiver/examine(mob/user)
	. = ..()
	if(ammo_list.len)
		. += span_notice("[ammo_list.len] inside.")

/obj/item/quiver/update_icon()
	if(ammo_list.len)
		icon_state = "quiver1"
	else
		icon_state = "quiver0"

/obj/item/quiver/arrows/Initialize()
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/arrow/iron/A = new()
		ammo_list += A
	update_icon()

/obj/item/quiver/bolts/Initialize()
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/bolt/A = new()
		ammo_list += A
	update_icon()
/*
/obj/item/quiver/Parrows/Initialize()
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/arrow/poison/A = new()
		ammo_list += A
	update_icon()

/obj/item/quiver/Pbolts/Initialize()
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/bolt/poison/A = new()
		ammo_list += A
	update_icon()
*/

