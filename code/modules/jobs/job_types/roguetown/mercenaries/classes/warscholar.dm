/datum/advclass/mercenary/warscholar
	name = "Naledi Warscholar"
	tutorial = "Heralded by sigils of black-and-gold and their distinct masks, the Naledi Warscholars once prowled the dunes of their homeland, exterminating daemons in exchange for coin, artifacts, or knowledge. As Naledi's economy falters, the Warscholars travel to foreign lands to seek further business."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/mercenary/warscholar
	category_tags = list(CTAG_MERCENARY)
	cmode_music = 'sound/music/warscholar.ogg'

/datum/outfit/job/roguetown/mercenary/warscholar
	name = "Warscholar Mercenary"
	mask = /obj/item/clothing/mask/rogue/lordmask/tarnished
	belt = /obj/item/storage/belt/rogue/leather
	beltl = /obj/item/flashlight/flare/torch
	beltr = /obj/item/storage/belt/rogue/pouch/coins/poor
	pants = /obj/item/clothing/under/roguetown/trou/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots
	gloves = /obj/item/clothing/gloves/roguetown/angle
	backr = /obj/item/storage/backpack/rogue/satchel/black
	head = /obj/item/clothing/head/roguetown/roguehood/shalal/black
	cloak = /obj/item/clothing/cloak/half
	backpack_contents = list(/obj/item/roguekey/mercenary,/obj/item/rogueweapon/huntingknife)

/datum/advclass/mercenary/warscholar/equipme(mob/living/carbon/human/H)
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
			var/classchoice = pick(list("Hierophant", "Arcyne-Monk"))
			apply_class_equipment(H, classchoice)
			return

		to_chat(H, span_notice("\n\nChoose your Warscholar archetype..."))
		var/classchoice = alert(H, "Choose your Warscholar archetype (30 seconds to choose)", "Class Selection", "Hierophant", "Arcyne-Monk")
		
		spawn(30 SECONDS)
			if(!classchoice)
				classchoice = pick(list("Hierophant", "Arcyne-Monk"))
				to_chat(H, span_warning("Time's up! Random archetype selected: [classchoice]"))
				apply_class_equipment(H, classchoice)
		
		if(!classchoice)
			classchoice = pick(list("Hierophant", "Arcyne-Monk"))
			to_chat(H, span_warning("No selection made. Random archetype selected: [classchoice]"))
		
		apply_class_equipment(H, classchoice)
	
	return TRUE

/datum/advclass/mercenary/warscholar/proc/apply_class_equipment(mob/living/carbon/human/H, classchoice)
	switch(classchoice)
		if("Hierophant")
			H.set_blindness(0)
			to_chat(H, span_warning("Hierophants are magicians who studied under cloistered sages, well-versed in all manners of arcyne. They prioritize enhancing their teammates and distracting foes while staying in the backline."))
			if(H.mind)
				H.mind.adjust_skillrank(/datum/skill/combat/polearms, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/swimming, 1, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/athletics, 1, TRUE)
				H.mind.adjust_skillrank(/datum/skill/craft/crafting, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/medicine, 3, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/riding, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/reading, 4, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/alchemy, 3, TRUE)
				H.mind.adjust_skillrank(/datum/skill/magic/arcane, 4, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/sewing, 2, TRUE)
				if(H.age == AGE_OLD)
					H.mind.adjust_skillrank(/datum/skill/magic/arcane, 1, TRUE)
					H.change_stat("speed", -1)
					H.change_stat("intelligence", 1)
					H.change_stat("perception", 1)
					H.mind.adjust_spellpoints(1)
				H.change_stat("strength", -1)
				H.change_stat("constitution", -1)
				H.change_stat("perception", 1)
				H.change_stat("intelligence", 2)
				H.mind.adjust_spellpoints(2)
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/touch/prestidigitation)
				var/obj/item/rogueweapon/woodstaff/S = new(get_turf(H))
				H.put_in_hands(S)
		if("Arcyne-Monk")
			H.set_blindness(0)
			to_chat(H, span_warning("You are a Naledi Arcyne-Monk, a warrior trained into a hybridized style of movement-controlling magic and hand-to-hand combat. Though your abilities in magical fields are lacking, you are far more dangerous than other magi in a straight fight."))
			if(H.mind)
				H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/swimming, 1, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
				H.mind.adjust_skillrank(/datum/skill/craft/crafting, 1, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/medicine, 1, TRUE)
				H.mind.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
				H.mind.adjust_skillrank(/datum/skill/magic/arcane, 2, TRUE)
				H.mind.adjust_spellpoints(-6)
				H.change_stat("strength", 1)
				H.change_stat("endurance", 2)
				H.change_stat("intelligence", 1)
				H.change_stat("perception", 1)
				var/obj/item/rogueweapon/katar/K = new(get_turf(H))
				H.put_in_hands(K)
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/touch/prestidigitation)
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/fetch)
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/slowdown_spell_aoe)
				ADD_TRAIT(H, TRAIT_DODGEEXPERT, TRAIT_GENERIC)

	//General gear regardless of class.
	if(H.pronouns == SHE_HER || H.pronouns == THEY_THEM_F)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/roguetown/armor/gambeson(H), SLOT_SHIRT)
	else
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/roguetown/armor/gambeson/lord(H), SLOT_SHIRT)

	ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
	return TRUE
