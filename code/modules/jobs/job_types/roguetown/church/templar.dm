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
		var/datum/advclass/templar/chosen_class
		
		// Find the Inquisitor and their class
		var/inquisitor_class
		// Check actual Inquisitors
		for(var/mob/living/carbon/human/inq in GLOB.human_list)
			if(inq.mind?.assigned_role == "Inquisitor")
				if(inq.client?.prefs?.inquisitor_class)
					inquisitor_class = inq.client.prefs.inquisitor_class
					break
		if(!inquisitor_class)
			for(var/datum/mind/mind in SSticker.minds)
				if(mind.assigned_role == "Inquisitor")
					var/client/inq_client = GLOB.directory[mind.key]
					if(inq_client?.prefs?.inquisitor_class)
						inquisitor_class = inq_client.prefs.inquisitor_class
						break
		
		// Determine Occultist class based on Inquisitor class
		var/class_type
		if(!inquisitor_class || inquisitor_class == "random") // Handle random/unset class preference
			class_type = pick(/datum/advclass/templar/monk, /datum/advclass/templar/crusader, /datum/advclass/templar/hunter)
		else if(inquisitor_class == "Zealot")
			class_type = /datum/advclass/templar/monk
		else if(inquisitor_class == "Puritan")
			class_type = /datum/advclass/templar/hunter
		else // Confessor
			class_type = /datum/advclass/templar/crusader
		
		chosen_class = new class_type()
		
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
		H.change_stat("strength", 2)
		H.change_stat("endurance", 1)
		H.change_stat("constitution", 2)
		H.change_stat("perception", -1)

		ADD_TRAIT(H, TRAIT_DODGEEXPERT, TRAIT_GENERIC)

	return TRUE

/datum/advclass/templar/crusader
	name = "Golden Retainer"
	tutorial = "You are a Golden Retainer, having dedicated your life and service to the Confessor. You subscribe to the ideal of such a savior, choosing to display the golden rays of light upon your armor. It's pretty convincing, too!"
	outfit = /datum/outfit/job/roguetown/templar/crusader
	category_tags = list(CTAG_TEMPLAR)

/datum/outfit/job/roguetown/templar/crusader
	head = /obj/item/clothing/head/roguetown/helmet/heavy/bucket/fakegold
	neck = /obj/item/clothing/neck/roguetown/chaincoif/fakegold
	gloves = /obj/item/clothing/gloves/roguetown/chain/fakegold
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	pants = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	shoes = /obj/item/clothing/shoes/roguetown/boots
	armor = /obj/item/clothing/suit/roguetown/armor/plate/scale/fakegold
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
		H.change_stat("strength", 1)
		H.change_stat("constitution", 1)
		H.change_stat("endurance", 1)
		H.change_stat("intelligence", 1)
		H.change_stat("speed", -2)

		ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)

	return TRUE

/datum/advclass/templar/hunter
	name = "Hunter"
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
		H.change_stat("strength", 1)
		H.change_stat("endurance", 1)
		H.change_stat("intelligence", -1)
		H.change_stat("speed", 1)

		ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)

	return TRUE
