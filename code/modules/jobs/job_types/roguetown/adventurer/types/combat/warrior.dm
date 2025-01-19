//shield sword
/datum/advclass/sfighter
	name = "Warrior"
	tutorial = "Warriors are well balanced fighters, skilled in blades and capable of most other weapons. \
	they are an important member to most parties for their combat prowess, but not for much more"
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/adventurer/sfighter
	traits_applied = list(TRAIT_HEAVYARMOR)

	category_tags = list(CTAG_ADVENTURER)

/datum/outfit/job/roguetown/adventurer/sfighter/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/swimming, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/medicine, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
		var/weapons = list("Sword & Shield","Mace & Shield","Spear")
		var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
		switch(weapon_choice)
			if("Sword & Shield")
				H.mind.adjust_skillrank(/datum/skill/combat/swords, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/shields, 2, TRUE)
				beltr = /obj/item/rogueweapon/sword/iron
				backr = /obj/item/rogueweapon/shield/wood
			if("Mace & Shield")
				H.mind.adjust_skillrank(/datum/skill/combat/maces, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/shields, 2, TRUE)
				beltr =/obj/item/rogueweapon/mace/spiked
				backr = /obj/item/rogueweapon/shield/wood
			if("Spear")
				H.mind.adjust_skillrank(/datum/skill/combat/polearms, 2, TRUE)
				r_hand = /obj/item/rogueweapon/spear
		H.change_stat("strength", 1)
		H.change_stat("endurance", 1)
		H.change_stat("constitution", 1)
		H.change_stat("speed", 1)
	backl = /obj/item/storage/backpack/rogue/satchel
	beltl = /obj/item/rogueweapon/huntingknife
	shoes = /obj/item/clothing/shoes/roguetown/boots
	gloves = /obj/item/clothing/gloves/roguetown/leather
	belt = /obj/item/storage/belt/rogue/leather
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/random
	pants = /obj/item/clothing/under/roguetown/trou/leather
	ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
