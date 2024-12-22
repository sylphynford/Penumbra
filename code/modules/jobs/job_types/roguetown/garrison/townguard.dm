/datum/job/roguetown/guardsman
	title = "Town Guard"
	flag = GUARDSMAN
	department_flag = GARRISON
	faction = "Station"
	total_positions = 4
	spawn_positions = 4
	selection_color = JCOLOR_SOLDIER
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	allowed_ages = list(AGE_YOUNG, AGE_ADULT, AGE_MIDDLEAGED)
	tutorial = "Responsible for the safety of the town and the enforcement of the Baron's law, you are the vanguard of the city faced with punishing those who defy His Lordship. You take orders from Sergeants, Knights, and your Liege."
	display_order = JDO_TOWNGUARD
	whitelist_req = TRUE

	outfit = /datum/outfit/job/roguetown/guardsman
	advclass_cat_rolls = list(CTAG_WATCH = 20)

	give_bank_account = 16
	min_pq = 0
	max_pq = null
	round_contrib_points = 2

	cmode_music = 'sound/music/combat_guard.ogg'

/datum/job/roguetown/guardsman/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	..()
	if(!L || !M?.client)
		return
		
	var/mob/living/carbon/human/H = L
	if(!istype(H))
		return
		
	var/list/valid_classes = list()
	var/preferred_class = M.client?.prefs?.town_guard_class

	// Build list of valid classes for this character
	for(var/type in subtypesof(/datum/advclass/watchman))
		var/datum/advclass/watchman/AC = new type()
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

	var/datum/advclass/watchman/chosen_class
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
	if(chosen_class && H.mind)
		H.mind?.transfer_to(H) // Ensure mind is properly set up
		chosen_class.equipme(H)
		qdel(chosen_class)

	// Handle tabard name
	if(istype(H.cloak, /obj/item/clothing/cloak/stabard/guard))
		var/obj/item/clothing/S = H.cloak
		var/index = findtext(H.real_name, " ")
		if(index)
			index = copytext(H.real_name, 1,index)
		if(!index)
			index = H.real_name
		S.name = "guard tabard ([index])"

/datum/outfit/job/roguetown/guardsman
	pants = /obj/item/clothing/under/roguetown/chainlegs
	cloak = /obj/item/clothing/cloak/stabard/guard
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather/black
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	backr = /obj/item/storage/backpack/rogue/satchel/black
	backpack_contents = list(/obj/item/signal_horn = 1)

/datum/outfit/job/roguetown/guardsman/footsman
	// Only define the base items that aren't handled in equipme()
	pants = /obj/item/clothing/under/roguetown/chainlegs
	cloak = /obj/item/clothing/cloak/stabard/guard
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	neck = /obj/item/clothing/neck/roguetown/coif
	shoes = /obj/item/clothing/shoes/roguetown/boots
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	backr = /obj/item/storage/backpack/rogue/satchel/black

/datum/advclass/watchman/footsman
	name = "Watch Footsman"
	tutorial = "You are a footsman of the Town Watch. Well versed in various close-quarters weapons and apprehending street-savvy criminals."
	outfit = /datum/outfit/job/roguetown/guardsman/footsman
	category_tags = list(CTAG_WATCH)

/datum/advclass/watchman/footsman/equipme(mob/living/carbon/human/H)
	if(!H)
		return FALSE
	
	// First equip the base outfit
	if(outfit)
		var/datum/outfit/O = new outfit
		O.equip(H)

	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/maces, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/axes, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/swords, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/shields, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/polearms, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/medicine, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/riding, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/tracking, 1, TRUE)
		H.change_stat("strength", 2)
		H.change_stat("constitution", 1)
		H.change_stat("endurance", 1)
		H.change_stat("speed", 1)

	ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)

	H.equip_to_slot_or_del(new /obj/item/clothing/head/roguetown/helmet/kettle(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/roguetown/armor/chainmail(H), SLOT_ARMOR)
	H.equip_to_slot_or_del(new /obj/item/rogueweapon/mace/cudgel(H), SLOT_BELT_R)
	H.equip_to_slot_or_del(new /obj/item/rogueweapon/shield/wood(H), SLOT_BACK_R)
	H.equip_to_slot_or_del(new /obj/item/storage/keyring/guardcastle(H), SLOT_BELT_L)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/rogue/leather/black(H), SLOT_BELT)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/roguetown/leather(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/rogueweapon/huntingknife/idagger/steel(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/rope/chain(H), SLOT_IN_BACKPACK)
	
	H.verbs |= /mob/proc/haltyell
	
	return TRUE

/datum/advclass/watchman/archer
	name = "Watch Archer"
	tutorial = "You are an archer of the Town Watch. Once a hunter, now a man-hunter for your lord. Rooftops, bows, and daggers are your best friend."
	outfit = /datum/outfit/job/roguetown/guardsman/archer
	category_tags = list(CTAG_WATCH)

/datum/advclass/watchman/archer/equipme(mob/living/carbon/human/H)
	if(!H)
		return FALSE
	
	// First equip the base outfit
	if(outfit)
		var/datum/outfit/O = new outfit
		O.equip(H)

	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/bows, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/maces, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/shields, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/swords, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/medicine, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/crafting, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/tanning, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/tracking, 1, TRUE)
		H.change_stat("strength", 1)
		H.change_stat("perception", 2)
		H.change_stat("intelligence", 1)
		H.change_stat("constitution", 1)


	H.equip_to_slot_or_del(new /obj/item/clothing/head/roguetown/helmet(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/roguetown/armor/leather(H), SLOT_ARMOR)
	H.equip_to_slot_or_del(new /obj/item/quiver/bolts(H), SLOT_BELT_R)
	H.equip_to_slot_or_del(new /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow(H), SLOT_BACK_L)
	H.equip_to_slot_or_del(new /obj/item/storage/keyring/guardcastle(H), SLOT_BELT_L)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/rogue/leather/black(H), SLOT_BELT)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/roguetown/leather(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/rogueweapon/huntingknife/idagger/steel(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/rope/chain(H), SLOT_IN_BACKPACK)
	
	H.verbs |= /mob/proc/haltyell
	
	return TRUE

/datum/outfit/job/roguetown/guardsman/archer
	// Only define the base items that aren't handled in equipme()
	pants = /obj/item/clothing/under/roguetown/chainlegs
	cloak = /obj/item/clothing/cloak/stabard/guardhood
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	neck = /obj/item/clothing/neck/roguetown/coif
	shoes = /obj/item/clothing/shoes/roguetown/boots
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	backr = /obj/item/storage/backpack/rogue/satchel/black
