/datum/job/roguetown/monk
	title = "Monk"
	f_title = "Nun"
	flag = MONK
	department_flag = CHURCHMEN
	faction = "Station"
	total_positions = 6
	spawn_positions = 6

	allowed_races = RACES_CHURCH
	allowed_patrons = ALL_ACOLYTE_PATRONS
	allowed_sexes = list(MALE, FEMALE)
	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD)
	outfit = /datum/outfit/job/roguetown/monk
	tutorial = "As a servant of Psydon you have some faith, but even you know you gave up a life of adventure for that of the security in the Church. Assist the Priest in their daily tasks and maybe today will be the day something interesting happens."

	display_order = JDO_MONK
	give_bank_account = TRUE
	min_pq = 0 
	max_pq = null
	round_contrib_points = 2

/datum/outfit/job/roguetown/monk
	name = "Monk/Nun"
	jobtype = /datum/job/roguetown/monk

	allowed_patrons = list(/datum/patron/divine/pestra, /datum/patron/divine/astrata, /datum/patron/divine/eora, /datum/patron/divine/noc, /datum/patron/divine/necra) //Eora content from Stonekeep


/datum/outfit/job/roguetown/monk/pre_equip(mob/living/carbon/human/H)
	..()
	belt = /obj/item/storage/belt/rogue/leather/rope
	beltr = /obj/item/storage/belt/rogue/pouch/coins/poor
	beltl = /obj/item/storage/keyring/churchie
	shoes = /obj/item/clothing/shoes/roguetown/sandals
	shirt = /obj/item/clothing/suit/roguetown/shirt/shortshirt
	pants = /obj/item/clothing/under/roguetown/tights
	neck = /obj/item/clothing/neck/roguetown/psicross/wood

	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/medicine, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/cooking, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/crafting, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/sewing, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/labor/farming, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/magic/holy, 3, TRUE)
		if(H.age == AGE_OLD)
			H.mind.adjust_skillrank(/datum/skill/magic/holy, 1, TRUE)
		H.change_stat("strength", 1)
		H.change_stat("intelligence", 1)
		H.change_stat("endurance", 2)
		H.change_stat("speed", 1)

	if(H.pronouns == HE_HIM || H.pronouns == THEY_THEM || H.pronouns == IT_ITS)
		armor = /obj/item/clothing/suit/roguetown/shirt/robe
	else
		armor = /obj/item/clothing/suit/roguetown/shirt/robe/nun
		head = /obj/item/clothing/head/roguetown/nun

//	var/datum/devotion/C = new /datum/devotion(H, H.patron)
//	C.grant_spells_monk(H)
//	H.verbs += list(/mob/living/carbon/human/proc/devotionreport, /mob/living/carbon/human/proc/clericpray)
