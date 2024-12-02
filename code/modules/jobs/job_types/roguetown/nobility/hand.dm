/datum/job/roguetown/hand
	title = "Hand"
	flag = HAND
	department_flag = NOBLEMEN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1

	allowed_races = NOBLE_RACES_TYPES
	allowed_sexes = list(MALE, FEMALE)
	outfit = /datum/outfit/job/roguetown/hand
	advclass_cat_rolls = list(CTAG_HAND = 20)
	display_order = JDO_HAND
	tutorial = "You owe everything to your liege. Once, you were just a humble friend--now you are one of the most important people within the barony itself. You have played spymaster and confidant to the Noble-Family for so long that you are a veritable vault of intrigue, something you exploit with potent conviction at every opportunity. Let no man ever forget into whose ear you whisper. You've killed more men with those lips than any blademaster could ever claim to."
	whitelist_req = TRUE
	give_bank_account = 44
	noble_income = 22
	min_pq = 0 //The second most powerful person in the realm...is Mhelping where the keep is
	max_pq = null
	round_contrib_points = 3
	cmode_music = 'sound/music/combat_fancy.ogg'

/*
/datum/job/roguetown/hand/special_job_check(mob/dead/new_player/player)
	if(!player)
		return
	if(!player.ckey)
		return
	for(var/mob/dead/new_player/Lord in GLOB.player_list)
		if(Lord.mind.assigned_role == "King")
			if(Lord.brohand == player.ckey)
				return TRUE
*/

/datum/outfit/job/roguetown/hand
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather/steel

/datum/job/roguetown/hand/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	..()
	if(L && M?.client)
		var/mob/living/carbon/human/H = L
		var/list/valid_classes = list()
		var/preferred_class = M.client?.prefs?.hand_class

		// Build list of valid classes for this character
		for(var/type in subtypesof(/datum/advclass/hand))
			var/datum/advclass/hand/AC = new type()
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

		var/datum/advclass/hand/chosen_class
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

/datum/advclass/hand/hand
	name = "Hand"
	tutorial = " You have played blademaster and strategist to the Noble-Family for so long that you are a master tactician, something you exploit with potent conviction. Let no man ever forget whose ear you whisper into. You've killed more men with swords than any spymaster could ever claim to."
	outfit = /datum/outfit/job/roguetown/hand/handclassic
	category_tags = list(CTAG_HAND)

/datum/outfit/job/roguetown/hand/handclassic
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/guard
	backr = /obj/item/storage/backpack/rogue/satchel/black
	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/steel = 1, /obj/item/storage/keyring/hand = 1)
	armor = /obj/item/clothing/suit/roguetown/armor/leather/vest/hand
	pants = /obj/item/clothing/under/roguetown/tights/black
	beltr = /obj/item/rogueweapon/sword/rapier/dec

/datum/advclass/hand/hand/equipme(mob/living/carbon/human/H)
	if(!H)
		return FALSE
	
	// First equip the base outfit
	if(outfit)
		var/datum/outfit/O = new outfit
		O.equip(H)

	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/maces, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/swimming, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/lockpicking, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/riding, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/tracking, 1, TRUE)
		H.change_stat("strength", 1)
		H.change_stat("perception", 3)
		H.change_stat("intelligence", 3)

	ADD_TRAIT(H, TRAIT_NOBLE, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)

	H.equip_to_slot_or_del(new /obj/item/clothing/suit/roguetown/shirt/undershirt/guard(H), SLOT_SHIRT)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/rogue/satchel/black(H), SLOT_BACK_R)
	H.equip_to_slot_or_del(new /obj/item/rogueweapon/huntingknife/idagger/steel(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/keyring/hand(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/roguetown/armor/leather/vest/hand(H), SLOT_ARMOR)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/roguetown/tights/black(H), SLOT_PANTS)
	H.equip_to_slot_or_del(new /obj/item/rogueweapon/sword/rapier/dec(H), SLOT_BELT_R)

	return TRUE

/datum/advclass/hand/spymaster
	name = "Spymaster"
	tutorial = " You have played spymaster and confidant to the Noble-Family for so long that you are a vault of intrigue, something you exploit with potent conviction. Let no man ever forget whose ear you whisper into. You've killed more men with those lips than any blademaster could ever claim to."
	outfit = /datum/outfit/job/roguetown/hand/spymaster
	category_tags = list(CTAG_HAND)

/datum/outfit/job/roguetown/hand/spymaster
	backr = /obj/item/storage/backpack/rogue/satchel/black
	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/dtace = 1, /obj/item/storage/keyring/hand = 1, /obj/item/lockpickring/mundane = 1)
	var/non_dwarf_equipment = list(
		"shirt" = /obj/item/clothing/suit/roguetown/armor/gambeson/shadowrobe,
		"cloak" = /obj/item/clothing/cloak/half/shadowcloak,
		"gloves" = /obj/item/clothing/gloves/roguetown/fingerless/shadowgloves,
		"mask" = /obj/item/clothing/mask/rogue/shepherd/shadowmask,
		"pants" = /obj/item/clothing/under/roguetown/trou/shadowpants
	)
	var/dwarf_equipment = list(
		"cloak" = /obj/item/clothing/cloak/raincloak/mortus,
		"shirt" = /obj/item/clothing/suit/roguetown/shirt/undershirt/guard,
		"armor" = /obj/item/clothing/suit/roguetown/armor/leather/vest/hand,
		"pants" = /obj/item/clothing/under/roguetown/tights/black
	)

/datum/outfit/job/roguetown/hand/spymaster/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(!H)
		return
	
	// Apply race-specific equipment
	var/list/equipment = (H.dna.species.type in NON_DWARVEN_RACE_TYPES) ? non_dwarf_equipment : dwarf_equipment
	
	if(equipment["shirt"])
		shirt = equipment["shirt"]
	if(equipment["cloak"])
		cloak = equipment["cloak"]
	if(equipment["gloves"])
		gloves = equipment["gloves"]
	if(equipment["mask"])
		mask = equipment["mask"]
	if(equipment["pants"])
		pants = equipment["pants"]
	if(equipment["armor"])
		armor = equipment["armor"]

/datum/advclass/hand/spymaster/equipme(mob/living/carbon/human/H)
	if(!H)
		return FALSE
	
	// First equip the base outfit
	if(outfit)
		var/datum/outfit/O = new outfit
		O.equip(H)

	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/maces, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/bows, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/swords, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/swimming, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 5, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/riding, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/tracking, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/stealing, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/lockpicking, 2, TRUE)
		H.change_stat("strength", -1)
		H.change_stat("perception", 2)
		H.change_stat("speed", 2)
		H.change_stat("intelligence", 2)

		ADD_TRAIT(H, TRAIT_NOBLE, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_DODGEEXPERT, TRAIT_GENERIC)

	return TRUE

/datum/advclass/hand/advisor
	name = "Advisor"
	tutorial = " You have played researcher and confidant to the Noble-Family for so long that you are a vault of knowledge, something you exploit with potent conviction. Let no man ever forget the knowledge you wield. You've read more books than any blademaster or spymaster could ever claim to."
	outfit = /datum/outfit/job/roguetown/hand/advisor
	category_tags = list(CTAG_HAND)

/datum/outfit/job/roguetown/hand/advisor
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/guard
	backr = /obj/item/storage/backpack/rogue/satchel/black
	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/steel = 1, /obj/item/storage/keyring/hand = 1, /obj/item/reagent_containers/glass/bottle/rogue/poison = 1)
	armor = /obj/item/clothing/suit/roguetown/armor/leather/vest/hand
	pants = /obj/item/clothing/under/roguetown/tights/black

/datum/advclass/hand/advisor/equipme(mob/living/carbon/human/H)
	if(!H)
		return FALSE
	
	// First equip the base outfit
	if(outfit)
		var/datum/outfit/O = new outfit
		O.equip(H)

	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/swords, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/swimming, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 5, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/riding, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/tracking, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/alchemy, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/medicine, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/lockpicking, 4, TRUE)
		H.change_stat("intelligence", 3)
		H.change_stat("perception", 2)

		if(H.age == AGE_OLD)
			H.change_stat("speed", -1)
			H.change_stat("strength", -1)
			H.change_stat("intelligence", 1)
			H.change_stat("perception", 1)

	ADD_TRAIT(H, TRAIT_NOBLE, TRAIT_GENERIC)

	H.equip_to_slot_or_del(new /obj/item/clothing/suit/roguetown/shirt/undershirt/guard(H), SLOT_SHIRT)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/rogue/satchel/black(H), SLOT_BACK_R)
	H.equip_to_slot_or_del(new /obj/item/rogueweapon/huntingknife/idagger/steel(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/keyring/hand(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/glass/bottle/rogue/poison(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/roguetown/armor/leather/vest/hand(H), SLOT_ARMOR)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/roguetown/tights/black(H), SLOT_PANTS)

	return TRUE

