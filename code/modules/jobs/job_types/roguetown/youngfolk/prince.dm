/datum/job/roguetown/prince
	title = "Heir"
	f_title = "Successor"
	flag = PRINCE
	department_flag = YOUNGFOLK
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	allowed_races = NOBLE_RACES_TYPES
	allowed_sexes = list(MALE, FEMALE)
	allowed_ages = list(AGE_YOUNG, AGE_ADULT)
	tutorial = "You've never felt the gnawing of the winter, never known the bite of hunger and certainly have never known a honest day's work. You are as free as any bird in the sky, and you may revel in your debauchery for as long as your parents remain upon the throne: But someday you'll have to grow up, and that will be the day your carelessness will cost you more than a few mammons."
	display_order = JDO_PRINCE
	give_bank_account = 30
	noble_income = 20
	min_pq = 0
	max_pq = null
	round_contrib_points = 3
	cmode_music = 'sound/music/combat_fancy.ogg'
	family_blacklisted = TRUE
	lord_family = TRUE
	lord_rel_type = REL_TYPE_OFFSPRING
	outfit = /datum/outfit/job/roguetown/prince
	zizo_roll = 15

/datum/outfit/job/roguetown/prince
	name = "Heir"
	jobtype = /datum/job/roguetown/prince
	
	belt = /obj/item/storage/belt/rogue/leather
	beltl = /obj/item/storage/keyring/heir
	beltr = /obj/item/storage/belt/rogue/pouch/coins/rich

/datum/outfit/job/roguetown/prince/pre_equip(mob/living/carbon/human/H)
	..()
	if(!H)
		return

	if(H.gender == MALE)
		pants = /obj/item/clothing/under/roguetown/tights
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/guard
		belt = /obj/item/storage/belt/rogue/leather
		shoes = /obj/item/clothing/shoes/roguetown/nobleboot
	else if(H.gender == FEMALE)
		belt = /obj/item/storage/belt/rogue/leather/cloth/lady
		if(isdwarf(H))
			armor = /obj/item/clothing/suit/roguetown/shirt/dress/silkdress/princess
		else
			armor = /obj/item/clothing/suit/roguetown/shirt/dress/silkdress/successor
		shoes = /obj/item/clothing/shoes/roguetown/shortboots
		pants = /obj/item/clothing/under/roguetown/tights/stockings/silk/random

/datum/job/roguetown/prince/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	..()
	if(!L)
		return
		
	var/mob/living/carbon/human/H = L
	if(!istype(H))
		return

	ADD_TRAIT(H, TRAIT_NOBLE, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_SEEPRICES_SHITTY, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_GOODLOVER, TRAIT_GENERIC)

	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/music, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/riding, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/sewing, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/cooking, 1, TRUE)
		
		H.mind.adjust_skillrank(/datum/skill/combat/bows, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/swords, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
		
		H.mind.adjust_skillrank(/datum/skill/misc/swimming, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 1, TRUE)
		
		H.change_stat("intelligence", 2)
		H.change_stat("perception", 2)
		H.change_stat("fortune", 1)
		H.change_stat("strength", -1)
		H.change_stat("speed", 1)

