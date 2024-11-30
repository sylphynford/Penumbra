/datum/advclass/mercenary/steppesman
	name = "Steppesman"
	tutorial = "Once serving a Hetmen from the frontiers, you have been rented out as a mercenary in the distant realms to bring coin home. There are three things you value most; saigas, freedom, and coin."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/mercenary/steppesman
	category_tags = list(CTAG_MERCENARY)
	cmode_music = 'sound/music/combat_steppe.ogg'


/datum/outfit/job/roguetown/mercenary/steppesman/pre_equip(mob/living/carbon/human/H)
	..()
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	head = /obj/item/clothing/head/roguetown/papakha
	gloves = /obj/item/clothing/gloves/roguetown/leather
	belt = /obj/item/storage/belt/rogue/leather/black
	armor = /obj/item/clothing/suit/roguetown/armor/leather/studded
	cloak = /obj/item/clothing/cloak/raincloak/furcloak
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	beltr = /obj/item/rogueweapon/whip
	beltl= /obj/item/quiver/arrows
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
	pants = /obj/item/clothing/under/roguetown/trou/leather
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	backl = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve
	backr = /obj/item/storage/backpack/rogue/satchel
	l_hand = /obj/item/rogueweapon/shield/buckler
	backpack_contents = list(/obj/item/roguekey/mercenary, /obj/item/storage/belt/rogue/pouch/coins/poor)
	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/bows, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/shields, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/riding, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/sewing, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/crafting, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/tanning, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/swimming, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/cooking, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/tracking, 1, TRUE)
	H.change_stat("perception", 2)
	H.change_stat("constitution", 1)
	H.change_stat("endurance", 1)
	H.change_stat("speed", 1)
	ADD_TRAIT(H, TRAIT_DODGEEXPERT, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_CRITICAL_RESISTANCE, TRAIT_GENERIC)

/datum/advclass/mercenary/steppesman/equipme(mob/living/carbon/human/H)
	if(!H)
		return FALSE
	
	// First equip the base outfit
	if(outfit)
		var/datum/outfit/O = new outfit
		O.equip(H)

	// Wait for client to be ready (up to 5 seconds)
	spawn(0)
		var/tries = 0
		while(!H?.client && tries < 10)
			tries++
			sleep(5)

		if(!H?.client)
			var/classchoice = pick(list("Horse Archer", "Lancer"))
			apply_class_equipment(H, classchoice)
			return

		to_chat(H, span_notice("\n\nChoose your Steppesman archetype..."))
		var/classchoice = alert(H, "Choose your Steppesman archetype", "Class Selection", "Horse Archer", "Lancer")
		
		if(!classchoice)
			classchoice = pick(list("Horse Archer", "Lancer"))
			to_chat(H, span_warning("No selection made. Random archetype selected: [classchoice]"))
		
		apply_class_equipment(H, classchoice)
	
	return TRUE

/datum/advclass/mercenary/steppesman/proc/apply_class_equipment(mob/living/carbon/human/H, classchoice)
	switch(classchoice)
		if("Horse Archer")
			H.set_blindness(0)
			to_chat(H, span_warning("You are a Horse Archer of the Steppes, skilled with bow and arrow from horseback."))
			var/obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve/bow = new(get_turf(H))
			H.put_in_hands(bow)
		if("Lancer")
			H.set_blindness(0)
			to_chat(H, span_warning("You are a Lancer of the Steppes, skilled with spear and whip."))
			var/obj/item/rogueweapon/whip/whip = new(get_turf(H))
			H.put_in_hands(whip)
