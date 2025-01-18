/datum/migrant_role/antag_hunter/bounty_hunter
	name = "Fablefield Goliard"
	greet_text = "For years you've travelled to Fablefield, honing your craft at the annual grand festival of tales. You are a respected weaver of glorious and valorous stories, with a tongue and wit as sharp as your blade. Of late, you've been obsessed with the Umbra Veil... What fantastical adventures could you embark on here, with your proteges?"
	outfit = /datum/outfit/job/roguetown/antag_hunter/bounty_hunter
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS

/datum/outfit/job/roguetown/antag_hunter/bounty_hunter/pre_equip(mob/living/carbon/human/H)
	..()
	head = /obj/item/clothing/head/roguetown/bardhat
	neck = /obj/item/storage/belt/rogue/pouch/coins/mid
	shoes = /obj/item/clothing/shoes/roguetown/boots
	pants = /obj/item/clothing/under/roguetown/tights/random
	shirt = /obj/item/clothing/suit/roguetown/shirt/shortshirt
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	belt = /obj/item/storage/belt/rogue/leather
	armor = /obj/item/clothing/suit/roguetown/armor/leather/vest
	cloak = /obj/item/clothing/cloak/half/red
	backl = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogue/instrument/guitar
	beltl = /obj/item/rogueweapon/sword/rapier/dec
	beltr = /obj/item/rogueweapon/huntingknife/idagger/silver/elvish
	backpack_contents = list(/obj/item/book/rogue/tales1, /obj/item/book/rogue/blackmountain, /obj/item/book/rogue/tales3)
	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/misc/music, 6, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 5, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/magic/holy, 2, TRUE) //Futureproofing, does nothing for now.
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/crafting, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/cooking, 1, TRUE)
		H.change_stat("speed", 2)
		H.change_stat("perception", 2)
		H.change_stat("intelligence", 1)
		H.change_stat("endurance", 1)
	H.verbs |= /mob/living/carbon/human/proc/ventriloquate

	ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_EMPATH, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_GOODLOVER, TRAIT_GENERIC)

/datum/migrant_wave/bounty_hunter
	name = "Bounty Hunters"
	max_spawns = 1
	unique = TRUE
	//downgrade_wave = /datum/migrant_wave/fablefield_down_one
	roles = list(
		/datum/migrant_role/antag_hunter/bounty_hunter = 1
	)
	greet_text = "Cries of bandits have come from the town of Sombervick, and news of their garrison failing to protect them spreads. Save the town!"

/datum/migrant_wave/bounty_hunter/check_condition()
	var/bandit_found = FALSE
	for(var/datum/antagonist/A in GLOB.antagonists)
		if(istype(A, /datum/antagonist/bandit) && A.owner && A.owner.current)
			bandit_found = TRUE

	for(var/mob/living/carbon/human/H in GLOB.human_list)
		if(H.mind && !isnewplayer(H))
			if(H.stat == DEAD)
				total_dead++
			else
				total_alive++

	var/total_players = total_alive + total_dead

	if(total_players > 0 && (total_dead >= (total_players * 0.50)) && bandit_found)
		return TRUE
	else
		return FALSE
