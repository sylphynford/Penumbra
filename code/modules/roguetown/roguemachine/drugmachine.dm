#define DRUGRADE_MONEYA				(1<<0)
#define DRUGRADE_MONEYB 	      	(1<<1)
#define DRUGRADE_WINE 	          	(1<<2)
#define DRUGRADE_WEAPONS 	      	(1<<3)
#define DRUGRADE_CLOTHES 	      	(1<<4)
#define DRUGRADE_NOTAX				(1<<5)

/obj/structure/roguemachine/drugmachine
	name = "PURITY"
	desc = "You want to destroy your life."
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = "streetvendor1"
	density = TRUE
	blade_dulling = DULLING_BASH
	max_integrity = 0
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	var/list/held_items = list()
	var/locked = FALSE
	var/budget = 0
	var/secret_budget = 0
	var/recent_payments = 0
	var/last_payout = 0
	var/drugrade_flags

/obj/structure/roguemachine/drugmachine/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/roguekey))
		var/obj/item/roguekey/K = P
		if(K.lockid == "nightman")
			locked = !locked
			playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
			update_icon()
			return attack_hand(user)
		else
			to_chat(user, span_warning("Wrong key."))
			return
	if(istype(P, /obj/item/storage/keyring))
		var/obj/item/storage/keyring/K = P
		for(var/obj/item/roguekey/KE in K.keys)
			if(KE.lockid == "nightman")
				locked = !locked
				playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
				update_icon()
				return attack_hand(user)
	if(istype(P, /obj/item/roguecoin))
		budget += P.get_real_price()
		qdel(P)
		update_icon()
		playsound(loc, 'sound/misc/machinevomit.ogg', 100, TRUE, -1)
		return attack_hand(user)
	..()

/obj/structure/roguemachine/drugmachine/process()
	if(recent_payments)
		if(world.time > last_payout + rand(6 MINUTES,8 MINUTES))
			var/amt = recent_payments * 0.10
			if(drugrade_flags & DRUGRADE_MONEYA)
				amt = recent_payments * 0.25
			if(drugrade_flags & DRUGRADE_MONEYB)
				amt = recent_payments * 0.50
			recent_payments = 0
			send_ooc_note("<b>Income from PURITY:</b> [amt]", job = "Bathmaster")
			secret_budget += amt
			last_payout = world.time

/obj/structure/roguemachine/drugmachine/Topic(href, href_list)
	. = ..()
	if(!ishuman(usr))
		return
	if(href_list["buy"])
		if(!usr.canUseTopic(src, BE_CLOSE) || locked)
			return
		var/mob/M = usr
		var/O = text2path(href_list["buy"])
		if(held_items[O]["PRICE"])
			var/tax_amt = FLOOR(SStreasury.tax_value * held_items[O]["PRICE"], 1)
			var/full_price = held_items[O]["PRICE"] + tax_amt
			if(drugrade_flags & DRUGRADE_NOTAX)
				full_price = held_items[O]["PRICE"]
			if(budget >= full_price)
				budget -= full_price
				recent_payments += held_items[O]["PRICE"]
				if(!(drugrade_flags & DRUGRADE_NOTAX))
					SStreasury.give_money_treasury(tax_amt, "purity import tax")
			else
				say("Not enough!")
				return
		var/obj/item/I = new O(get_turf(src))
		M.put_in_hands(I)
	if(href_list["change"])
		if(!usr.canUseTopic(src, BE_CLOSE) || locked)
			return
		if(budget > 0)
			budget2change(budget, usr)
			budget = 0
	if(href_list["refund"])
		if(!usr.canUseTopic(src, BE_CLOSE) || locked)
			return
		var/obj/item/I = usr.get_active_held_item()
		if(!I)
			say("Hold the item you wish to refund!")
			return
		var/found_type
		for(var/path in held_items)
			if(istype(I, path))
				found_type = path
				break
		if(found_type)
			var/refund_amt = held_items[found_type]["PRICE"]
			if(refund_amt)
				budget += refund_amt
				qdel(I)
				playsound(loc, 'sound/misc/machinevomit.ogg', 100, TRUE, -1)
				say("Refunded [refund_amt] MAMMON")
				return attack_hand(usr)
		say("Cannot refund this item!")
	if(href_list["secrets"])
		if(!usr.canUseTopic(src, BE_CLOSE) || locked)
			return
		var/mob/living/carbon/human/H = usr
		if(H.job != "Bathmaster")
			return
		var/list/options = list()
		options += "Withdraw Cut"
		if(drugrade_flags & DRUGRADE_NOTAX)
			options += "Enable Paying Taxes"
		else
			options += "Stop Paying Taxes"
		if(!(drugrade_flags & DRUGRADE_MONEYB))
			options += "Unlock 50% Cut (105)"
		var/select = input(usr, "Please select an option.", "", null) as null|anything in options
		if(!select)
			return
		if(!usr.canUseTopic(src, BE_CLOSE) || locked)
			return
		switch(select)
			if("Withdraw Cut")
				options = list("To Bank", "Direct")
				select = input(usr, "Please select an option.", "", null) as null|anything in options
				if(!select)
					return
				if(!usr.canUseTopic(src, BE_CLOSE) || locked)
					return
				switch(select)
					if("To Bank")
						if(secret_budget <= 0)
							say("No cut available to withdraw.")
							return
						if(SStreasury.generate_money_account(secret_budget, H))
							say("Cut transferred to bank account: [secret_budget] MAMMON")
							secret_budget = 0
						else
							say("Bank transfer failed!")
					if("Direct")
						if(secret_budget <= 0)
							say("No cut available to withdraw.")
							return
						var/amount_to_withdraw = secret_budget
						budget2change(amount_to_withdraw, usr)
						say("Cut withdrawn: [amount_to_withdraw] MAMMON")
						secret_budget = 0
			if("Enable Paying Taxes")
				drugrade_flags &= ~DRUGRADE_NOTAX
				playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
			if("Stop Paying Taxes")
				drugrade_flags |= DRUGRADE_NOTAX
				playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
			if("Unlock 50% Cut (105)")
				if(drugrade_flags & DRUGRADE_MONEYB)
					return
				if(budget < 105)
					say("Ask again when you're serious.")
					playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
					return
				budget -= 105
				drugrade_flags |= DRUGRADE_MONEYB
				playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
	return attack_hand(usr)

/obj/structure/roguemachine/drugmachine/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		return
	if(locked)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
	var/contents

	var/mob/living/carbon/human/H = user
	if(H.job == "Bathmaster")
		contents = "<a href='?src=[REF(src)];secrets=1'>Secrets</a><BR><BR>"
	
	contents += "<center>PURITY - In the name of pleasure.<BR>"
	contents += "<b>MAMMON LOADED:</b> [budget]<BR>"
	contents += "<a href='?src=[REF(src)];change=1'>\[Withdraw All\]</a>"
	contents += " <a href='?src=[REF(src)];refund=1'>\[Refund Item\]</a>"
	
	if(H.job == "Bathmaster")
		contents += " <a href='?src=[REF(src)];secrets=1'>\[Secrets\]</a>"
	
	contents += "<BR><BR></center>"

	for(var/I in held_items)
		// Skip enhanced versions and oils for users without TRAIT_DRUGENHANCER
		if((!HAS_TRAIT(user, TRAIT_DRUGENHANCER)) && (findtext("[I]", "enhanced") || findtext("[I]", "oil") || findtext("[I]", "forbidden")))
			continue

		var/price = FLOOR(held_items[I]["PRICE"] + (SStreasury.tax_value * held_items[I]["PRICE"]), 1)
		if(drugrade_flags & DRUGRADE_NOTAX)
			price = held_items[I]["PRICE"]
		var/namer = held_items[I]["NAME"]
		if(!price)
			price = "0"
		if(!namer)
			held_items[I]["NAME"] = "thing"
			namer = "thing"
		contents += "[namer] ([price] MAMMON) <a href='?src=[REF(src)];buy=[I]'>\[BUY\]</a><BR>"

	var/datum/browser/popup = new(user, "VENDORTHING", "", 370, 400)
	popup.set_content(contents)
	popup.open()

/obj/structure/roguemachine/drugmachine/obj_break(damage_flag)
	..()
	budget2change(budget)
	set_light(0)
	update_icon()
	icon_state = "streetvendor0"

/obj/structure/roguemachine/drugmachine/update_icon()
	cut_overlays()
	if(obj_broken)
		set_light(0)
		return
	set_light(1, 1, "#1b7bf1")
	add_overlay(mutable_appearance(icon, "vendor-drug"))


/obj/structure/roguemachine/drugmachine/Destroy()
	set_light(0)
	STOP_PROCESSING(SSroguemachine, src)
	return ..()

/obj/structure/roguemachine/drugmachine/Initialize()
	. = ..()
	START_PROCESSING(SSroguemachine, src)
	update_icon()
	
	// Set base prices once during initialization
	held_items[/obj/item/reagent_containers/powder/spice] = list("PRICE" = rand(41,55),"NAME" = "chuckledust")
	held_items[/obj/item/reagent_containers/powder/ozium] = list("PRICE" = rand(6,15),"NAME" = "ozium")
	held_items[/obj/item/reagent_containers/powder/moondust] = list("PRICE" = rand(13,25),"NAME" = "moondust")
	held_items[/obj/item/clothing/mask/cigarette/rollie/cannabis] = list("PRICE" = rand(12,18),"NAME" = "swampweed zig")
	held_items[/obj/item/reagent_containers/food/snacks/grown/rogue/sweetleafdry] = list("PRICE" = rand(12,18), "NAME" = "dry swampweed")
	held_items[/obj/item/clothing/mask/cigarette/rollie/nicotine] = list("PRICE" = rand(5,10),"NAME" = "zig")
	held_items[/obj/item/reagent_containers/food/snacks/grown/rogue/pipeweeddry] = list("PRICE" = rand(5,10), "NAME" = "dry westleach leaf")
	held_items[/obj/item/slimepotion/lovepotion] = list("PRICE" = rand(80,100),"NAME" = "love potion")
	held_items[/obj/item/clothing/head/roguetown/menacing/bandit] = list("PRICE" = rand(5, 25), "NAME" = "ne'er do 'ell mask")
	held_items[/obj/item/lockpick] = list("PRICE" = rand(3,6), "NAME" = "lockpick")
	held_items[/obj/item/lockpickring/mundane] = list("PRICE" = rand(12,20), "NAME" = "lockpick ring")

	// Add enhanced versions with same prices
	held_items[/obj/item/reagent_containers/powder/spice_enhanced] = list("PRICE" = (41),"NAME" = "enhanced chuckledust")
	held_items[/obj/item/reagent_containers/powder/ozium_enhanced] = list("PRICE" = (6),"NAME" = "enhanced ozium")
	held_items[/obj/item/reagent_containers/powder/moondust_enhanced] = list("PRICE" = (13),"NAME" = "enhanced moondust")
	held_items[/obj/item/frost_oil] = list("PRICE" = (50),"NAME" = "frost oil")
	held_items[/obj/item/fire_oil] = list("PRICE" = (100),"NAME" = "fire oil")
	held_items[/obj/item/acid_oil] = list("PRICE" = (150),"NAME" = "acid oil")
	held_items[/obj/item/storage/belt/rogue/surgery_bag/full] = list("PRICE" = (75), "NAME" = "enhanced medical bag")
	held_items[/obj/item/gun/ballistic/revolver/grenadelauncher/crossbow] = list("PRICE" = (30), "NAME" = "standard crossbow")
	held_items[/obj/item/ammo_casing/caseless/rogue/bolt] = list("PRICE" = rand(5, 15), "NAME" = "crossbow bolt")
	held_items[/obj/item/ammo_casing/caseless/rogue/bolt/pyro] = list("PRICE" = rand(15,35), "NAME" = "oil covered incendiary bolt")
	held_items[/obj/item/reagent_containers/glass/bottle/rogue/poison] = list("PRICE" = rand(15, 35), "NAME" = "enhanced poison")
	held_items[/obj/item/book/granter/spell_points] = list("PRICE" = rand(100, 500), "NAME" = "tome of forbidden arcynery")
	held_items[/obj/item/reagent_containers/glass/bottle/rogue/sleepy] = list("PRICE" = rand(10, 35), "NAME" = "sleeping oil")

#undef DRUGRADE_MONEYA
#undef DRUGRADE_MONEYB
#undef DRUGRADE_WINE
#undef DRUGRADE_WEAPONS
#undef DRUGRADE_CLOTHES
#undef DRUGRADE_NOTAX
