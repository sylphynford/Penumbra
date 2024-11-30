/datum/outfit/job/roguetown/mercenary/desertrider
	name = "Desert Rider Mercenary"
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/light
	armor = /obj/item/clothing/suit/roguetown/armor/leather/studded
	head = /obj/item/clothing/head/roguetown/helmet/turban
	pants = /obj/item/clothing/under/roguetown/pants/baggy
	cloak = /obj/item/clothing/cloak/stabard/surcoat/desertrider
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	gloves = /obj/item/clothing/gloves/roguetown/leather
	neck = /obj/item/clothing/neck/roguetown/scarf
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather
	backr = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/steel = 1, /obj/item/rope/chain = 1)

/datum/advclass/mercenary/desertrider/equipme(mob/living/carbon/human/H)
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
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/riding, 3, TRUE)
		ADD_TRAIT(H, TRAIT_LIGHTARMOR, TRAIT_GENERIC)

		H.change_stat("strength", 1)
		H.change_stat("intelligence", 1)
		H.change_stat("constitution", 1)
		H.change_stat("perception", 1)
		H.change_stat("speed", 2)

	// Wait for client to be ready (up to 5 seconds)
	spawn(0)
		var/tries = 0
		while(!H?.client && tries < 10)
			tries++
			sleep(5)
			
		if(!H?.client)
			var/classchoice = pick(list("Bow & Scimitar", "Lance & Shield"))
			apply_class_equipment(H, classchoice)
			return

		to_chat(H, span_notice("\n\nChoose your Desert Rider archetype..."))
		var/classchoice = alert(H, "Choose your Desert Rider archetype", "Class Selection", "Bow & Scimitar", "Lance & Shield")
		
		if(!classchoice)
			classchoice = pick(list("Bow & Scimitar", "Lance & Shield"))
			to_chat(H, span_warning("No selection made. Random archetype selected: [classchoice]"))
		
		apply_class_equipment(H, classchoice)
	
	return TRUE

/datum/advclass/mercenary/desertrider/proc/apply_class_equipment(mob/living/carbon/human/H, classchoice)
	H.adjust_blindness(-3)
	switch(classchoice)
		if("Bow & Scimitar")
			H.set_blindness(0)
			to_chat(H, span_warning("You are a Desert Rider archer, skilled with both bow and blade."))
			H.equip_to_slot_or_del(new /obj/item/rogueweapon/sword/scimitar(H), SLOT_BELT_R)
			H.equip_to_slot_or_del(new /obj/item/gun/ballistic/bow/recurve(H), SLOT_BACK_L)
			H.equip_to_slot_or_del(new /obj/item/quiver/arrows(H), SLOT_BELT_L)
		if("Lance & Shield")
			H.set_blindness(0)
			to_chat(H, span_warning("You are a Desert Rider lancer, a master of mounted combat."))
			H.equip_to_slot_or_del(new /obj/item/rogueweapon/shield/wood/round(H), SLOT_BACK_L)
			H.put_in_r_hand(new /obj/item/rogueweapon/spear/lance(H))
