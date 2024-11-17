/datum/advclass/knighterrant
	name = "Dishonored Knight"
	tutorial = "A dishonored knight from a foreign kingdom. Stripped of your honor and decried as a blackguard, your armor has been darkened as a symbol of such. As few may trust you in this land, you may either regain your honor through heroics, or prove that your heart has been darkened as well. "
	allowed_races = RACES_ALL_KINDS
	allowed_sexes = list(MALE, FEMALE)
	outfit = /datum/outfit/job/roguetown/adventurer/knighterrant
	traits_applied = list(TRAIT_HEAVYARMOR, TRAIT_NOBLE)
	category_tags = list(CTAG_ADVENTURER)
	pickprob = 1

	cmode_music = 'sound/music/combat_knight.ogg'


/datum/outfit/job/roguetown/adventurer/knighterrant/pre_equip(mob/living/carbon/human/H)
	..()
	H.adjust_blindness(-3)
	var/classes = list("Black Knight")
	var/classchoice = input("Choose your archetypes", "Available archetypes") as anything in classes

	switch(classchoice)

		if("Normal Knight")
			head = /obj/item/clothing/head/roguetown/helmet/heavy/knight
			gloves = /obj/item/clothing/gloves/roguetown/chain
			pants = /obj/item/clothing/under/roguetown/chainlegs
			cloak = /obj/item/clothing/cloak/tabard
			neck = /obj/item/clothing/neck/roguetown/gorget
			shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
			armor = /obj/item/clothing/suit/roguetown/armor/plate
			wrists = /obj/item/clothing/wrists/roguetown/bracers
			shoes = /obj/item/clothing/shoes/roguetown/boots/armor
			belt = /obj/item/storage/belt/rogue/leather
			backr = /obj/item/storage/backpack/rogue/satchel/black
			backl = /obj/item/rogueweapon/shield/tower/metal
			backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger = 1,/obj/item/storage/belt/rogue/pouch/coins/poor)
			H.mind.adjust_skillrank(/datum/skill/combat/polearms, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/shields, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/maces, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/swimming, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/riding, 4, TRUE)
			H.mind.adjust_skillrank(/datum/skill/craft/cooking, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/labor/butchering, 1, TRUE)
			H.change_stat("strength", 2)
			H.change_stat("endurance", 1)
			H.change_stat("constitution", 2)
			H.change_stat("intelligence", 1)
			H.change_stat("speed", 1)
			H.dna.species.soundpack_m = new /datum/voicepack/male/knight()
			var/weapons = list("Bastard Sword","Flail","Spear")
			var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
			H.set_blindness(0)
			switch(weapon_choice)
				if("Bastard Sword")	
					beltr = /obj/item/rogueweapon/sword/long
				if("Flail")
					beltr = /obj/item/rogueweapon/flail/sflail
				if("Spear")
					r_hand = /obj/item/rogueweapon/spear

		if("Black Knight")
			head = /obj/item/clothing/head/roguetown/helmet/heavy/knight/black
			gloves = /obj/item/clothing/gloves/roguetown/chain/blk
			pants = /obj/item/clothing/under/roguetown/chainlegs/blk
			cloak = /obj/item/clothing/cloak/half/rider/red
			neck = /obj/item/clothing/neck/roguetown/gorget
			shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/blk
			wrists = /obj/item/clothing/wrists/roguetown/bracers
			shoes = /obj/item/clothing/shoes/roguetown/boots
			belt = /obj/item/storage/belt/rogue/leather
			backr = /obj/item/storage/backpack/rogue/satchel/black
			backl = /obj/item/rogueweapon/shield/tower/metal
			backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger = 1, /obj/item/storage/belt/rogue/pouch/coins/poor)
			H.mind.adjust_skillrank(/datum/skill/combat/polearms, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/shields, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/maces, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/swimming, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/riding, 4, TRUE)
			H.mind.adjust_skillrank(/datum/skill/craft/cooking, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/labor/butchering, 1, TRUE)
			H.change_stat("strength", 2)
			H.change_stat("endurance", 1)
			H.change_stat("constitution", 2)
			H.change_stat("intelligence", 1)
			H.dna.species.soundpack_m = new /datum/voicepack/male/knight()
			var/weapons = list("Bastard Sword","Flail","Spear")
			var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
			H.set_blindness(0)
			switch(weapon_choice)
				if("Bastard Sword")	
					beltr = /obj/item/rogueweapon/sword/long
				if("Flail")
					beltr = /obj/item/rogueweapon/flail/sflail
				if("Spear")
					r_hand = /obj/item/rogueweapon/spear

/obj/item/clothing/gloves/roguetown/chain/blk
		color = CLOTHING_GREY

/obj/item/clothing/under/roguetown/chainlegs/blk
		color = CLOTHING_GREY

/obj/item/clothing/suit/roguetown/armor/plate/blk
		color = CLOTHING_GREY

/obj/item/clothing/shoes/roguetown/boots/armor/blk
		color = CLOTHING_GREY

/obj/item/clothing/suit/roguetown/armor/chainmail/blk
		color = CLOTHING_GREY

/obj/item/clothing/suit/roguetown/armor/plate/half/blk
		color = CLOTHING_GREY
