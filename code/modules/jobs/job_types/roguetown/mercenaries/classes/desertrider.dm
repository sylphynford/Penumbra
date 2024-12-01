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

	// CLASS ARCHETYPES
	H.adjust_blindness(-3)
	var/classes = list("Janissary","Blade Dancer","Blade Caster")
	var/classchoice = input("Choose your archetypes", "Available archetypes") as anything in classes

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
			backl = /obj/item/rogueweapon/shield/wood
			r_hand = /obj/item/rogueweapon/mace/steel
			neck = /obj/item/clothing/neck/roguetown/chaincoif/full
			shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
			armor = /obj/item/clothing/suit/roguetown/armor/plate/scale
			pants = /obj/item/clothing/under/roguetown/chainlegs
			H.grant_language(/datum/language/celestial)

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
			H.change_stat("intelligence", 1)
			H.change_stat("speed", 3)
			backl = /obj/item/rogueweapon/sword/long/rider
			shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
			armor = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat
			pants = /obj/item/clothing/under/roguetown/heavy_leather_pants
			H.grant_language(/datum/language/celestial)

		if("Blade Caster")
			H.set_blindness(0)
			to_chat(H, span_warning("Blade Casters are those skilled in both magyck and swordsmanship, but excelling in nothing."))
			H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/swimming, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/craft/crafting, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/medicine, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/reading, 4, TRUE)
			H.mind.adjust_skillrank(/datum/skill/magic/arcane, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/alchemy, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/sewing, 2, TRUE)
			H.mind.adjust_spellpoints(1)
			H.change_stat("endurance", 2)
			H.change_stat("intelligence", 3)
			H.change_stat("speed", 3)
			H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/touch/prestidigitation)
			H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/push_spell)
			r_hand = /obj/item/rogueweapon/sword/long/rider
			armor = /obj/item/clothing/suit/roguetown/shirt/robe/magered
			backl = /obj/item/rogueweapon/sword/long/rider

			H.grant_language(/datum/language/celestial)
			shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/lord

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
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	

	backpack_contents = list(/obj/item/roguekey/mercenary, /obj/item/rogueweapon/huntingknife/idagger/navaja, /obj/item/clothing/neck/roguetown/shalal)
