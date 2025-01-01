//shield flail or longsword, tief can be this with red cross

/datum/job/roguetown/templar
	title = "Occultist"
	department_flag = CHURCHMEN
	faction = "Station"
	tutorial = "You are a fanatical servant of an obscure order, willingly beholden with obeisance to the Inquisitor. In other words, you are a tool of violence wielded against a corrupting evil."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_CHURCH
	allowed_patrons = ALL_DIVINE_PATRONS
	outfit = /datum/outfit/job/roguetown/templar
	min_pq = 0 
	max_pq = null
	round_contrib_points = 2
	total_positions = 3
	spawn_positions = 3
	advclass_cat_rolls = list(CTAG_TEMPLAR = 20)
	display_order = JDO_TEMPLAR
	zizo_roll = 100
	give_bank_account = TRUE

/datum/outfit/job/roguetown/templar
	has_loadout = TRUE
	allowed_patrons = ALL_DIVINE_PATRONS
	belt = /obj/item/storage/belt/rogue/leather/black
	backr = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(/obj/item/storage/keyring/templar = 1, /obj/item/storage/belt/rogue/pouch/coins/poor = 1)

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
	name = "Practical"
	tutorial = "You are a warrior-monk in training, pursuing the perfection of body and mind. Your master has lead you along your path, and it is he who will declare it finished. Serve, root corruption from the very soil, and be made better."
	outfit = /datum/outfit/job/roguetown/templar/monk
	category_tags = list(CTAG_TEMPLAR)

/datum/outfit/job/roguetown/templar/monk
	head = /obj/item/clothing/head/roguetown/roguehood
	neck = /obj/item/clothing/neck/roguetown/psicross/wood
	shirt = /obj/item/clothing/suit/roguetown/shirt/robe
	pants = /obj/item/clothing/under/roguetown/trou/leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	armor = /obj/item/clothing/suit/roguetown/armor/leather/hide
	beltr = /obj/item/rogueweapon/mace

/datum/advclass/templar/monk/equipme(mob/living/carbon/human/H)
	if(!H)
		return FALSE
	
	// First equip the base outfit
	if(outfit)
		var/datum/outfit/O = new outfit
		O.equip(H)

	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/maces, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/cooking, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/medicine, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
		H.change_stat("strength", 2)
		H.change_stat("endurance", 1)
		H.change_stat("constitution", 2)
		H.change_stat("perception", -1)

	return TRUE

/datum/advclass/templar/crusader
	name = "Crusader"
	tutorial = "You are a righteous Crusader, having dedicated your life and service to the Confessor. You subscribe to the ideal of such a savior, striking the fear of PSYDON into the hearts of the heretics."
	outfit = /datum/outfit/job/roguetown/templar/crusader
	category_tags = list(CTAG_TEMPLAR)

/datum/outfit/job/roguetown/templar/crusader
	cloak = /obj/item/clothing/cloak/stabard/crusader
	head = /obj/item/clothing/head/roguetown/helmet/heavy/bucket
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	gloves = /obj/item/clothing/gloves/roguetown/chain/
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	pants = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	shoes = /obj/item/clothing/shoes/roguetown/boots
	armor = /obj/item/clothing/suit/roguetown/armor/plate/scale
	backl = /obj/item/rogueweapon/shield/tower
	beltl = /obj/item/rogueweapon/mace/cudgel
	beltr = /obj/item/rogueweapon/sword/iron

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
		H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/maces, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/medicine, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/shields, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
		H.change_stat("strength", 1)
		H.change_stat("constitution", 1)
		H.change_stat("endurance", 1)
		H.change_stat("intelligence", 1)
		H.change_stat("speed", -2)

		ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)

	return TRUE

/datum/advclass/templar/hunter
	name = "Monster Hunter"
	tutorial = "You are a monster hunter, having followed the Puritan for some time as a dedicated hunting party. You are entrusted with the silver required to rid the world of the vilest evils."
	outfit = /datum/outfit/job/roguetown/templar/hunter
	category_tags = list(CTAG_TEMPLAR)

/datum/outfit/job/roguetown/templar/hunter
	head = /obj/item/clothing/head/roguetown/puritan
	mask = /obj/item/clothing/mask/rogue/ragmask
	neck = /obj/item/clothing/neck/roguetown/psicross/wood
	gloves = /obj/item/clothing/gloves/roguetown/otavan
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	pants = /obj/item/clothing/under/roguetown/trou/otavan
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/puritan
	shoes = /obj/item/clothing/shoes/roguetown/boots
	armor = /obj/item/clothing/suit/roguetown/armor/leather/heavy/belted
	beltr = /obj/item/rogueweapon/sword/iron/messer	
	beltl = /obj/item/rogueweapon/huntingknife/idagger/silver

/datum/advclass/templar/hunter/equipme(mob/living/carbon/human/H)
	if(!H)
		return FALSE

	if(outfit)
		var/datum/outfit/O = new outfit
		O.equip(H)

	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/maces, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/medicine, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/tracking, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
		H.change_stat("strength", 1)
		H.change_stat("endurance", 1)
		H.change_stat("intelligence", -1)
		H.change_stat("speed", 1)

		ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)

	return TRUE
