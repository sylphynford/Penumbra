/datum/advclass/mercenary/desert_rider
	name = "Desert Rider Mercenary"
	tutorial = "Blood, like the desert sand, stains your hands, a crimson testament to the gold you covet. A desert rider, renowned mercenary of the far east, your shamshir whispers tales of centuries-old tradition. Your loyalty, a fleeting mirage in the shifting sands, will yield to the allure of fortune."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/mercenary/desert_rider
	category_tags = list(CTAG_MERCENARY)
	cmode_music = 'sound/music/combat_desertrider.ogg'

/datum/advclass/mercenary/desert_rider/equipme(mob/living/carbon/human/H)
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
			var/classchoice = pick(list("Janissary", "Blade Dancer"))
			apply_class_equipment(H, classchoice)
			return

		to_chat(H, span_notice("\n\nChoose your Desert Rider archetype..."))
		var/classchoice = alert(H, "Choose your Desert Rider archetype", "Class Selection", "Janissary", "Blade Dancer")
		
		if(!classchoice)
			classchoice = pick(list("Janissary", "Blade Dancer"))
			to_chat(H, span_warning("No selection made. Random archetype selected: [classchoice]"))
		
		apply_class_equipment(H, classchoice)
	
	return TRUE

/datum/advclass/mercenary/desert_rider/proc/apply_class_equipment(mob/living/carbon/human/H, classchoice)
	switch(classchoice)
		if("Janissary")
			H.set_blindness(0)
			to_chat(H, span_warning("The Janissaries are the Empire's elite infantry units, wielding mace and shield. We do not break."))
			if(H.mind)
				H.mind.adjust_skillrank(/datum/skill/combat/maces, 4, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/shields, 3, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/polearms, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/swords, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/bows, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/riding, 3, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/swimming, 1, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
			H.change_stat("strength", 2)
			H.change_stat("endurance", 1)
			H.change_stat("speed", 2)
			var/obj/item/rogueweapon/shield/wood/shield = new(get_turf(H))
			H.put_in_hands(shield)
			var/obj/item/rogueweapon/mace/steel/mace = new(get_turf(H))
			H.put_in_hands(mace)
		if("Blade Dancer")
			H.set_blindness(0)
			to_chat(H, span_warning("Zybantian 'Blade Dancers' are famed and feared the world over. Their expertise in blades both long and short is well known..."))
			if(H.mind)
				H.mind.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 3, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/maces, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/bows, 3, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/shields, 1, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/polearms, 1, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 3, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/riding, 3, TRUE)
			H.change_stat("strength", 1)
			H.change_stat("endurance", 2)
			H.change_stat("speed", 2)
			var/obj/item/rogueweapon/sword/long/rider/sword = new(get_turf(H))
			H.put_in_hands(sword)

	ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_DODGEEXPERT, TRAIT_GENERIC)

/datum/outfit/job/roguetown/mercenary/desert_rider
	name = "Desert Rider Mercenary"
	
	shoes = /obj/item/clothing/shoes/roguetown/shalal
	head = /obj/item/clothing/head/roguetown/roguehood/shalal
	gloves = /obj/item/clothing/gloves/roguetown/angle
	belt = /obj/item/storage/belt/rogue/leather/shalal
	armor = /obj/item/clothing/suit/roguetown/armor/plate/scale
	beltr = /obj/item/storage/belt/rogue/pouch/coins/poor
	backr = /obj/item/storage/backpack/rogue/satchel/black
	beltl = /obj/item/flashlight/flare/torch
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/black
	pants = /obj/item/clothing/under/roguetown/chainlegs/iron
	
	backpack_contents = list(/obj/item/roguekey/mercenary, /obj/item/rogueweapon/huntingknife/idagger/navaja, /obj/item/clothing/neck/roguetown/shalal)
