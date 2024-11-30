//shield flail or longsword, tief can be this with red cross

/datum/job/roguetown/templar
	title = "Templar"
	department_flag = CHURCHMEN
	faction = "Station"
	tutorial = "The Templar is a fanatical enforcer tasked with eradicating heresy within the realm, answering only to those who are recognized as true representatives of Psydon: the Inquisitor first, and the priesthood second. Their role is not to interpret the will of Psydon but to enforce the edicts of those granted divine mandate. Any claim of a Templar understanding or interpreting the Psydon will is seen as a violation of their sacred purpose as such presumptions are considered heretical in themselves. Their service is ingrained in them so deeply that their lives are regarded as insignificant in comparison to the sacred duty they bear."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	allowed_patrons = ALL_DIVINE_PATRONS
	outfit = /datum/outfit/job/roguetown/templar
	min_pq = 0 //Deus vult, but only according to the proper escalation rules
	max_pq = null
	round_contrib_points = 2
	total_positions = 3
	spawn_positions = 3
	advclass_cat_rolls = list(CTAG_TEMPLAR = 20)
	display_order = JDO_TEMPLAR

	give_bank_account = TRUE

/datum/outfit/job/roguetown/templar
	has_loadout = TRUE
	allowed_patrons = ALL_DIVINE_PATRONS
	belt = /obj/item/storage/belt/rogue/leather/black
	beltl = /obj/item/storage/belt/rogue/pouch/coins/poor
	beltr = /obj/item/storage/keyring/templar
	id = /obj/item/clothing/ring/silver
	backl = /obj/item/storage/backpack/rogue/satchel

/datum/job/roguetown/templar/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	..()
	if(L && M?.client)
		var/mob/living/carbon/human/H = L
		var/list/valid_classes = list()
		var/preferred_class = M.client?.prefs?.templar_class

		// Build list of valid classes for this character
		for(var/type in subtypesof(/datum/advclass/templar))
			var/datum/advclass/templar/AC = new type()
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

		var/datum/advclass/templar/chosen_class
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

/datum/advclass/templar/monk
	name = "Monk"
	tutorial = "You are a monk of the Church, trained in pugilism and acrobatics. You bear no armor but your faith, and your hands are lethal weapons in service to PSYDON."
	outfit = /datum/outfit/job/roguetown/templar/monk
	category_tags = list(CTAG_TEMPLAR)

/datum/outfit/job/roguetown/templar/monk
	neck = /obj/item/clothing/neck/roguetown/psicross/
	cloak = /obj/item/clothing/cloak/templar/psydon
	pants = /obj/item/clothing/under/roguetown/tights/black
	wrists = /obj/item/clothing/wrists/roguetown/wrappings
	shoes = /obj/item/clothing/shoes/roguetown/sandals

/datum/advclass/templar/monk/equipme(mob/living/carbon/human/H)
	if(!H)
		return FALSE
	
	// First equip the base outfit
	if(outfit)
		var/datum/outfit/O = new outfit
		O.equip(H)

	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/cooking, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/medicine, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/magic/holy, 2, TRUE)
		H.change_stat("strength", 2)
		H.change_stat("endurance", 2)
		H.change_stat("perception", -1)

		ADD_TRAIT(H, TRAIT_DODGEEXPERT, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)

	// Apply patron-specific equipment
	var/neck_type = /obj/item/clothing/neck/roguetown/psicross/
	var/cloak_type = /obj/item/clothing/cloak/templar/psydon
	
	switch(H.patron?.type)
		if(/datum/patron/divine/astrata)
			neck_type = /obj/item/clothing/neck/roguetown/psicross/
			cloak_type = /obj/item/clothing/cloak/templar/psydon
		if(/datum/patron/divine/dendor)
			neck_type = /obj/item/clothing/neck/roguetown/psicross/
			cloak_type = /obj/item/clothing/cloak/templar/psydon
		if(/datum/patron/divine/necra)
			neck_type = /obj/item/clothing/neck/roguetown/psicross/
			cloak_type = /obj/item/clothing/cloak/templar/psydon
		if(/datum/patron/divine/pestra)
			neck_type = /obj/item/clothing/neck/roguetown/psicross/
			cloak_type = /obj/item/clothing/cloak/templar/psydon
		if(/datum/patron/divine/noc)
			neck_type = /obj/item/clothing/neck/roguetown/psicross/
			cloak_type = /obj/item/clothing/cloak/templar/psydon
		if(/datum/patron/divine/ravox)
			neck_type = /obj/item/clothing/neck/roguetown/psicross/
			cloak_type = /obj/item/clothing/cloak/templar/psydon
		if(/datum/patron/divine/malum)
			neck_type = /obj/item/clothing/neck/roguetown/psicross/
			cloak_type = /obj/item/clothing/cloak/templar/psydon
		if(/datum/patron/old_god)
			neck_type = /obj/item/clothing/neck/roguetown/psicross
			cloak_type = /obj/item/clothing/cloak/tabard/crusader/psydon

	H.equip_to_slot_or_del(new neck_type(H), SLOT_NECK)
	H.equip_to_slot_or_del(new cloak_type(H), SLOT_CLOAK)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/roguetown/tights/black(H), SLOT_PANTS)
	H.equip_to_slot_or_del(new /obj/item/clothing/wrists/roguetown/wrappings(H), SLOT_WRISTS)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/roguetown/sandals(H), SLOT_SHOES)

	return TRUE

/datum/advclass/templar/crusader
	name = "Templar"
	tutorial = "You are a templar of the Church, trained in heavy weaponry and zealous warfare. The Inquisitor knows best, or so you believe."
	outfit = /datum/outfit/job/roguetown/templar/crusader
	category_tags = list(CTAG_TEMPLAR)

/datum/outfit/job/roguetown/templar/crusader
	head = /obj/item/clothing/head/roguetown/helmet/sallet/visored
	neck = /obj/item/clothing/neck/roguetown/psicross/
	cloak = /obj/item/clothing/cloak/tabard/crusader/psydon
	gloves = /obj/item/clothing/gloves/roguetown/chain
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	pants = /obj/item/clothing/under/roguetown/chainlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	shoes = /obj/item/clothing/shoes/roguetown/boots
	armor = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk

/datum/advclass/templar/crusader/equipme(mob/living/carbon/human/H)
	if(!H)
		return FALSE
	
	// First equip the base outfit
	if(outfit)
		var/datum/outfit/O = new outfit
		O.equip(H)

	if(H.mind)
		H.virginity = TRUE
		H.mind.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/maces, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/bows, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/magic/holy, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/medicine, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/shields, 3, TRUE)
		H.change_stat("strength", 2)
		H.change_stat("constitution", 2)
		H.change_stat("endurance", 2)
		H.change_stat("speed", -2)

		ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)

	H.equip_to_slot_or_del(new /obj/item/clothing/head/roguetown/helmet/sallet/visored(H), SLOT_HEAD)
	
	// Apply patron-specific equipment
	var/neck_type = /obj/item/clothing/neck/roguetown/psicross/
	var/cloak_type = /obj/item/clothing/cloak/tabard/crusader/psydon
	var/wrists_type = /obj/item/clothing/neck/roguetown/psicross/
	
	switch(H.patron?.type)
		if(/datum/patron/divine/astrata)
			wrists_type = /obj/item/clothing/neck/roguetown/psicross/
			cloak_type = /obj/item/clothing/cloak/templar/psydon
		if(/datum/patron/divine/dendor)
			wrists_type = /obj/item/clothing/neck/roguetown/psicross/
			cloak_type = /obj/item/clothing/cloak/templar/psydon
		if(/datum/patron/divine/necra)
			wrists_type = /obj/item/clothing/neck/roguetown/psicross/
			cloak_type = /obj/item/clothing/cloak/templar/psydon
		if(/datum/patron/divine/pestra)
			wrists_type = /obj/item/clothing/neck/roguetown/psicross/
			cloak_type = /obj/item/clothing/cloak/templar/psydon
		if(/datum/patron/divine/noc)
			wrists_type = /obj/item/clothing/neck/roguetown/psicross/
			cloak_type = /obj/item/clothing/cloak/templar/psydon
		if(/datum/patron/divine/ravox)
			wrists_type = /obj/item/clothing/neck/roguetown/psicross/
			cloak_type = /obj/item/clothing/cloak/templar/psydon
		if(/datum/patron/divine/malum)
			wrists_type = /obj/item/clothing/neck/roguetown/psicross/
			cloak_type = /obj/item/clothing/cloak/templar/psydon
		if(/datum/patron/old_god)
			wrists_type = /obj/item/clothing/neck/roguetown/psicross
			cloak_type = /obj/item/clothing/cloak/templar/psydon

	H.equip_to_slot_or_del(new neck_type(H), SLOT_NECK)
	H.equip_to_slot_or_del(new cloak_type(H), SLOT_CLOAK)
	H.equip_to_slot_or_del(new wrists_type(H), SLOT_WRISTS)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/roguetown/chain(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/neck/roguetown/chaincoif(H), SLOT_NECK)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/roguetown/chainlegs(H), SLOT_PANTS)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/roguetown/armor/gambeson(H), SLOT_SHIRT)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/roguetown/boots(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk(H), SLOT_ARMOR)

	return TRUE

/datum/outfit/job/roguetown/templar/crusader/choose_loadout(mob/living/carbon/human/H)
	. = ..()
	var/weapons = list("Bastard Sword","Flail","Mace")
	var/weapon_choice = input(H,"Choose your weapon (30 seconds to choose)", "TAKE UP ARMS") as anything in weapons
	
	spawn(30 SECONDS)
		if(!weapon_choice)
			weapon_choice = pick(weapons)
			to_chat(H, span_warning("Time's up! Random weapon selected: [weapon_choice]"))
			switch(weapon_choice)
				if("Bastard Sword")
					H.put_in_hands(new /obj/item/rogueweapon/sword/long(H), TRUE)
					H.mind.adjust_skillrank(/datum/skill/combat/swords, 1, TRUE)
				if("Flail")
					H.put_in_hands(new /obj/item/rogueweapon/flail(H), TRUE)
					H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 1, TRUE)
				if("Mace")
					H.put_in_hands(new /obj/item/rogueweapon/mace(H), TRUE)
					H.mind.adjust_skillrank(/datum/skill/combat/maces, 1, TRUE)
	
	switch(weapon_choice)
		if("Bastard Sword")
			H.put_in_hands(new /obj/item/rogueweapon/sword/long(H), TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/swords, 1, TRUE)
		if("Flail")
			H.put_in_hands(new /obj/item/rogueweapon/flail(H), TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 1, TRUE)
		if("Mace")
			H.put_in_hands(new /obj/item/rogueweapon/mace(H), TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/maces, 1, TRUE)

