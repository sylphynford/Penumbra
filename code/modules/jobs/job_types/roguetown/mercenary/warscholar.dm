/datum/outfit/job/roguetown/mercenary/warscholar
	name = "Warscholar Mercenary"
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/light
	armor = /obj/item/clothing/suit/roguetown/armor/leather/studded
	head = /obj/item/clothing/head/roguetown/helmet/kettle
	pants = /obj/item/clothing/under/roguetown/pants/baggy
	cloak = /obj/item/clothing/cloak/stabard/surcoat/warscholar
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	gloves = /obj/item/clothing/gloves/roguetown/leather
	neck = /obj/item/clothing/neck/roguetown/scarf
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather
	backr = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/steel = 1, /obj/item/rope/chain = 1)

/datum/advclass/mercenary/warscholar/equipme(mob/living/carbon/human/H)
	if(!H)
		return FALSE
	
	// First equip the base outfit
	if(outfit)
		var/datum/outfit/O = new outfit
		O.equip(H)

	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/polearms, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/axes, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/maces, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/shields, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/bows, 4, TRUE)

		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/riding, 2, TRUE)
		ADD_TRAIT(H, TRAIT_LIGHTARMOR, TRAIT_GENERIC)

		H.change_stat("strength", 1)
		H.change_stat("intelligence", 2)
		H.change_stat("constitution", 1)
		H.change_stat("perception", 1)
		H.change_stat("speed", 1)

	// Wait for client to be ready (up to 5 seconds)
	spawn(0)
		var/tries = 0
		while(!H?.client && tries < 10)
			tries++
			sleep(5)
			
		if(!H?.client)
			var/classchoice = pick(list("Sword & Book", "Spear & Book"))
			apply_class_equipment(H, classchoice)
			return

		to_chat(H, span_notice("\n\nChoose your Warscholar archetype..."))
		var/classchoice = alert(H, "Choose your Warscholar archetype", "Class Selection", "Sword & Book", "Spear & Book")
		
		if(!classchoice)
			classchoice = pick(list("Sword & Book", "Spear & Book"))
			to_chat(H, span_warning("No selection made. Random archetype selected: [classchoice]"))
		
		apply_class_equipment(H, classchoice)
	
	return TRUE

/datum/advclass/mercenary/warscholar/proc/apply_class_equipment(mob/living/carbon/human/H, classchoice)
	H.adjust_blindness(-3)
	switch(classchoice)
		if("Sword & Book")
			H.set_blindness(0)
			to_chat(H, span_warning("You are a Warscholar swordsman, combining martial prowess with arcane knowledge."))
			H.equip_to_slot_or_del(new /obj/item/rogueweapon/sword/arming(H), SLOT_BELT_R)
			H.equip_to_slot_or_del(new /obj/item/storage/book/spellbook(H), SLOT_BELT_L)
		if("Spear & Book")
			H.set_blindness(0)
			to_chat(H, span_warning("You are a Warscholar spearman, keeping foes at bay while studying the arcane."))
			H.equip_to_slot_or_del(new /obj/item/rogueweapon/spear/partisan(H), SLOT_BACK_L)
			H.equip_to_slot_or_del(new /obj/item/storage/book/spellbook(H), SLOT_BELT_L)
