/datum/job/roguetown/manorguard
	title = "Sergeant at Arms"
	flag = MANATARMS
	department_flag = GARRISON
	faction = "Station"
	total_positions = 2
	spawn_positions = 2

	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED)
	tutorial = "Having proven yourself loyal and capable, you are entrusted as a Sergeant in the Town Guard. Trained regularly in combat and siege warfare, you stand a small chance of surviving the Baron's reign. You take orders from the Knights and your liege, enforcing their will on the guards below you."
	display_order = JDO_CASTLEGUARD
	whitelist_req = TRUE

	outfit = /datum/outfit/job/roguetown/manorguard
	advclass_cat_rolls = list(CTAG_MENATARMS = 20)

	give_bank_account = 22
	min_pq = 0
	max_pq = null
	round_contrib_points = 2

	cmode_music = 'sound/music/combat_guard2.ogg'

/datum/job/roguetown/manorguard/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	..()
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(istype(H.cloak, /obj/item/clothing/cloak/stabard/surcoat/guard))
			var/obj/item/clothing/S = H.cloak
			var/index = findtext(H.real_name, " ")
			if(index)
				index = copytext(H.real_name, 1,index)
			if(!index)
				index = H.real_name
			S.name = "guard tabard ([index])"
	if(L && M?.client)
		var/mob/living/carbon/human/H = L
		var/list/valid_classes = list()
		var/preferred_class = M.client?.prefs?.sergeant_class

		// Build list of valid classes for this character
		for(var/type in subtypesof(/datum/advclass/manorguard))
			var/datum/advclass/manorguard/AC = new type()
			if(!AC.name)
				qdel(AC)
				continue
			
			// Check if class is allowed for this player
			if(AC.allowed_sexes?.len && !(H.gender in AC.allowed_sexes))
				qdel(AC)
				continue
			if(AC.allowed_races?.len && !(H.dna.species.type in AC.allowed_races))
				qdel(AC)
				continue
			if(AC.min_pq != -100 && !(get_playerquality(M.client.ckey) >= AC.min_pq))
				qdel(AC)
				continue
			
			valid_classes[AC.name] = AC

		// If no valid classes found, something is wrong
		if(!length(valid_classes))
			to_chat(M, span_warning("No valid classes found! Please report this to an admin."))
			return

		var/datum/advclass/manorguard/chosen_class
		if(preferred_class && valid_classes[preferred_class])
			// Use preferred class if it's valid
			chosen_class = valid_classes[preferred_class]
			to_chat(M, span_notice("Using your preferred class: [preferred_class]"))
			// Clean up other classes
			for(var/name in valid_classes)
				if(name != preferred_class)
					qdel(valid_classes[name])
		else
			// Choose random class from valid options
			var/chosen_name = pick(valid_classes)
			chosen_class = valid_classes[chosen_name]
			to_chat(M, span_warning("No class preference set. You have been randomly assigned: [chosen_name]"))
			// Clean up other classes
			for(var/name in valid_classes)
				if(name != chosen_name)
					qdel(valid_classes[name])

		// Let the class handle everything through its own equipme()
		if(chosen_class)
			H.mind?.transfer_to(H) // Ensure mind is properly set up
			chosen_class.equipme(H)
			qdel(chosen_class)
/datum/outfit/job/roguetown/manorguard
	pants = /obj/item/clothing/under/roguetown/chainlegs
	cloak = /obj/item/clothing/cloak/stabard/surcoat/guard
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	gloves = /obj/item/clothing/gloves/roguetown/leather
	neck = /obj/item/clothing/neck/roguetown/gorget
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	beltl = /obj/item/storage/keyring/guardcastle
	belt = /obj/item/storage/belt/rogue/leather/black
	backr = /obj/item/storage/backpack/rogue/satchel/black
	backpack_contents = list(/obj/item/signal_horn = 1)

// Maces + Axes + Shield	-	Better armor, typical Man-at-Arms loadout
/datum/advclass/manorguard/footsman
	name = "Sergeant-at-Arms Footsman"
	tutorial = "You are a professional soldier of the realm, specializing in melee warfare. Stalwart and hardy, your body can both withstand and dish out powerful strikes.."
	outfit = /datum/outfit/job/roguetown/manorguard/footsman
	category_tags = list(CTAG_MENATARMS)

/datum/outfit/job/roguetown/manorguard/footsman
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	armor = /obj/item/clothing/suit/roguetown/armor/plate/scale
	head = /obj/item/clothing/head/roguetown/helmet/sallet
	pants = /obj/item/clothing/under/roguetown/chainlegs
	cloak = /obj/item/clothing/cloak/stabard/surcoat/guard
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	gloves = /obj/item/clothing/gloves/roguetown/leather
	neck = /obj/item/clothing/neck/roguetown/gorget
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	beltl = /obj/item/storage/keyring/guardcastle
	belt = /obj/item/storage/belt/rogue/leather/black
	backr = /obj/item/storage/backpack/rogue/satchel/black
	backpack_contents = list(/obj/item/signal_horn = 1, /obj/item/rogueweapon/huntingknife/idagger/steel/special = 1, /obj/item/rope/chain = 1)

/datum/advclass/manorguard/footsman/equipme(mob/living/carbon/human/H)
	if(!H)
		return FALSE
	
	// First equip the base outfit
	if(outfit)
		var/datum/outfit/O = new outfit
		O.equip(H)

	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/polearms, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/axes, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/maces, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/shields, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/bows, 3, TRUE)

		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/riding, 1, TRUE)
		ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_GUARDSMAN, TRAIT_GENERIC)

		H.change_stat("strength", 2)
		H.change_stat("intelligence", 1)
		H.change_stat("constitution", 1)
		H.change_stat("endurance", 1)

	// Wait for client to be ready (up to 5 seconds)
	spawn(0)
		var/tries = 0
		while(!H?.client && tries < 10)
			tries++
			sleep(5)
			
		if(!H?.client)
			var/classchoice = pick(list("Axe & Shield", "Billhook & Cudgel"))
			apply_class_equipment(H, classchoice)
			return

		to_chat(H, span_notice("\n\nChoose your Footsman weapon..."))
		var/list/choices = list("Axe & Shield", "Billhook & Cudgel")
		var/classchoice = input(H, "Choose your Footsman weapon (30 seconds to choose)", "Weapon Selection") as anything in choices
		
		spawn(30 SECONDS)
			if(!classchoice)
				classchoice = pick(choices)
				to_chat(H, span_warning("Time's up! Random weapon selected: [classchoice]"))
				apply_class_equipment(H, classchoice)
		
		if(!classchoice)
			classchoice = pick(choices)
			to_chat(H, span_warning("No selection made. Random weapon selected: [classchoice]"))
		
		apply_class_equipment(H, classchoice)
	
	return TRUE

/datum/advclass/manorguard/footsman/proc/apply_class_equipment(mob/living/carbon/human/H, classchoice)
	H.adjust_blindness(-3)
	switch(classchoice)
		if("Axe & Shield")
			H.set_blindness(0)
			to_chat(H, span_warning("You are a stalwart shield bearer, skilled with axe and shield."))
			H.equip_to_slot_or_del(new /obj/item/rogueweapon/stoneaxe/woodcut/steel(H), SLOT_BELT_R)
			H.equip_to_slot_or_del(new /obj/item/rogueweapon/shield/wood(H), SLOT_BACK_L)
		if("Billhook & Cudgel")
			H.set_blindness(0)
			to_chat(H, span_warning("You are trained in the versatile combination of billhook and cudgel."))
			H.equip_to_slot_or_del(new /obj/item/rogueweapon/mace/cudgel(H), SLOT_BELT_R)
			H.put_in_r_hand(new /obj/item/rogueweapon/spear/billhook(H))

// Shield + Swords + Crossbow/Bow	-	Lighter armor, but ranged + sword skill in exchange for it.
/datum/advclass/manorguard/boltman
	name = "Sergeant-at-Arms Boltman"
	tutorial = "You are a professional soldier of the realm, specializing in ranged implements. You sport a keen eye, looking for your enemies weaknesses."
	outfit = /datum/outfit/job/roguetown/manorguard/boltman
	category_tags = list(CTAG_MENATARMS)

/datum/outfit/job/roguetown/manorguard/boltman
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
	armor = /obj/item/clothing/suit/roguetown/armor/leather/studded
	head = /obj/item/clothing/head/roguetown/helmet/kettle
	pants = /obj/item/clothing/under/roguetown/chainlegs
	cloak = /obj/item/clothing/cloak/stabard/surcoat/guard
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	gloves = /obj/item/clothing/gloves/roguetown/leather
	neck = /obj/item/clothing/neck/roguetown/gorget
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	beltl = /obj/item/storage/keyring/guardcastle
	belt = /obj/item/storage/belt/rogue/leather/black
	backr = /obj/item/storage/backpack/rogue/satchel/black
	backpack_contents = list(/obj/item/signal_horn = 1, /obj/item/rogueweapon/huntingknife/idagger/steel/special = 1, /obj/item/rope/chain = 1)

/datum/advclass/manorguard/boltman/equipme(mob/living/carbon/human/H)
	if(!H)
		return FALSE
	
	// First equip the base outfit
	if(outfit)
		var/datum/outfit/O = new outfit
		O.equip(H)

	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/polearms, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/axes, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/maces, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/shields, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 5, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/bows, 5, TRUE)

		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/riding, 1, TRUE)
		ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_GUARDSMAN, TRAIT_GENERIC)

		H.change_stat("strength", 1)
		H.change_stat("intelligence", 1)
		H.change_stat("constitution", 1)
		H.change_stat("perception", 2)
		H.change_stat("speed", 1)

	// Wait for client to be ready (up to 5 seconds)
	spawn(0)
		var/tries = 0
		while(!H?.client && tries < 10)
			tries++
			sleep(5)
			
		if(!H?.client)
			var/classchoice = pick(list("Crossbow & Sword", "Bow & Sword"))
			apply_class_equipment(H, classchoice)
			return

		to_chat(H, span_notice("\n\nChoose your Boltman weapon..."))
		var/list/choices = list("Crossbow & Sword", "Bow & Sword")
		var/classchoice = input(H, "Choose your Boltman weapon (30 seconds to choose)", "Weapon Selection") as anything in choices
		
		spawn(30 SECONDS)
			if(!classchoice)
				classchoice = pick(choices)
				to_chat(H, span_warning("Time's up! Random weapon selected: [classchoice]"))
				apply_class_equipment(H, classchoice)
		
		if(!classchoice)
			classchoice = pick(choices)
			to_chat(H, span_warning("No selection made. Random weapon selected: [classchoice]"))
		
		apply_class_equipment(H, classchoice)
	
	return TRUE

/datum/advclass/manorguard/boltman/proc/apply_class_equipment(mob/living/carbon/human/H, classchoice)
	H.adjust_blindness(-3)
	switch(classchoice)
		if("Crossbow & Sword")
			H.set_blindness(0)
			to_chat(H, span_warning("You are a skilled crossbowman, with sword for close combat."))
			H.equip_to_slot_or_del(new /obj/item/rogueweapon/sword/short(H), SLOT_BELT_R)
			H.equip_to_slot_or_del(new /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow(H), SLOT_BACK_L)
			H.equip_to_slot_or_del(new /obj/item/quiver/bolts(H), SLOT_BELT_L)
		if("Bow & Sword")
			H.set_blindness(0)
			to_chat(H, span_warning("You are a trained archer, carrying a sword for backup."))
			H.equip_to_slot_or_del(new /obj/item/rogueweapon/sword/short(H), SLOT_BELT_R)
			H.equip_to_slot_or_del(new /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow(H), SLOT_BACK_L)
			H.equip_to_slot_or_del(new /obj/item/quiver/arrows(H), SLOT_BELT_L)

