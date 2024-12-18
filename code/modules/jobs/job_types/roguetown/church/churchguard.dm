/datum/job/roguetown/churchguard
	title = "Templar"
	department_flag = CHURCHMEN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	allowed_races = RACES_CHURCH
	allowed_sexes = list(MALE, FEMALE)
	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED)
	allowed_patrons = ALL_DIVINE_PATRONS
	tutorial = "Templars are warriors who have forsaken wealth and title in lieu of service to the church, due to either zealotry or a past shame. They guard the church and its priest while keeping a watchful eye against heresy and nite-creechers. Within troubled dreams, they wonder if the blood they shed makes them holy or stained."
	display_order = JDO_CHURCHGUARD
	whitelist_req = TRUE
	outfit = /datum/outfit/job/roguetown/churchguard
	min_pq = 0
	max_pq = null
	round_contrib_points = 2

/datum/outfit/job/roguetown/churchguard/pre_equip(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/maces, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/shields, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/polearms, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
		H.change_stat("strength", 1)
		H.change_stat("endurance", 2)
		H.change_stat("constitution", 3)
		H.change_stat("perception", 1)
		H.change_stat("speed", -1)

/datum/outfit/job/roguetown/churchguard
	cloak = /obj/item/clothing/cloak/templar/psydon
	wrists = /obj/item/clothing/neck/roguetown/psicross/silver
	belt = /obj/item/storage/belt/rogue/leather 
	beltl = /obj/item/storage/keyring/templar
	beltr = /obj/item/rogueweapon/sword/long
	neck = /obj/item/clothing/neck/roguetown/bevor
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/
	head = /obj/item/clothing/head/roguetown/helmet/sallet/visored
	armor = /obj/item/clothing/suit/roguetown/armor/brigandine/coatplates
	pants = /obj/item/clothing/under/roguetown/chainlegs
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	gloves = /obj/item/clothing/gloves/roguetown/chain
	backr = /obj/item/storage/backpack/rogue/satchel/
	backl = /obj/item/rogueweapon/shield/tower/metal
	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1, /obj/item/rope/chain = 1, /obj/item/storage/belt/rogue/pouch/coins/rich = 1)
