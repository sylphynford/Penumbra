/datum/advclass/mercenary/grenzelhoft
	name = "Grenzelhoft"
	tutorial = "A mercenary company from the far north, known for their discipline and heavy armor."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/mercenary/grenzelhoft
	category_tags = list(CTAG_MERCENARY)
	cmode_music = 'sound/music/combat_grenzelhoft.ogg'

/datum/advclass/mercenary/grenzelhoft/equipme(mob/living/carbon/human/H)
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
			var/classchoice = pick(list("Doppelsoldner", "Halberdier"))
			apply_class_equipment(H, classchoice)
			return

		to_chat(H, span_notice("\n\nChoose your Grenzelhoft archetype..."))
		var/classchoice = alert(H, "Choose your Grenzelhoft archetype", "Class Selection", "Doppelsoldner", "Halberdier")
		
		if(!classchoice)
			classchoice = pick(list("Doppelsoldner", "Halberdier"))
			to_chat(H, span_warning("No selection made. Random archetype selected: [classchoice]"))
		
		apply_class_equipment(H, classchoice)
	
	return TRUE

/datum/advclass/mercenary/grenzelhoft/proc/apply_class_equipment(mob/living/carbon/human/H, classchoice)
	switch(classchoice)
		if("Doppelsoldner")
			H.set_blindness(0)
			to_chat(H, span_warning("You are a Doppelsoldner of Grenzelhoft, a swordsman experienced with long-length blades."))
			if(H.mind)
				H.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/maces, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/shields, 1, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/polearms, 3, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
			H.change_stat("strength", 2)
			H.change_stat("endurance", 2)
			H.change_stat("constitution", 1)
			H.change_stat("perception", 1)
			H.change_stat("speed", -1)
			var/obj/item/rogueweapon/greatsword/grenz/sword = new(get_turf(H))
			H.put_in_hands(sword)
		if("Halberdier")
			H.set_blindness(0)
			to_chat(H, span_warning("You are a Halberdier from Grenzelhoft, a skilled user of polearms and axes. Though you prefer them combined.."))
			if(H.mind)
				H.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/maces, 3, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/swords, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/polearms, 4, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
			H.change_stat("strength", 2)
			H.change_stat("endurance", 1)
			H.change_stat("constitution", 1)
			H.change_stat("perception", 1)
			var/obj/item/rogueweapon/halberd/weapon = new(get_turf(H))
			H.put_in_hands(weapon)

	ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)

/datum/outfit/job/roguetown/mercenary/grenzelhoft
	name = "Grenzelhoft Mercenary"
	
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	belt = /obj/item/storage/belt/rogue/leather
	beltl = /obj/item/flashlight/flare/torch
	beltr = /obj/item/storage/belt/rogue/pouch/coins/poor
	neck = /obj/item/clothing/neck/roguetown/gorget
	shirt = /obj/item/clothing/suit/roguetown/shirt/grenzelhoft
	head = /obj/item/clothing/head/roguetown/grenzelhofthat
	armor = /obj/item/clothing/suit/roguetown/armor/blacksteel/cuirass
	pants = /obj/item/clothing/under/roguetown/grenzelpants
	shoes = /obj/item/clothing/shoes/roguetown/grenzelhoft
	gloves = /obj/item/clothing/gloves/roguetown/grenzelgloves
	backr = /obj/item/storage/backpack/rogue/satchel/black
	backl = /obj/item/gwstrap
	
	backpack_contents = list(/obj/item/roguekey/mercenary)
