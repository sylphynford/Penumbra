/datum/job/roguetown/knight
	title = "Knight Lieutenant"
	flag = KNIGHT
	department_flag = NOBLEMEN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	allowed_races = NOBLE_RACES_TYPES
	allowed_sexes = list(MALE, FEMALE)
	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED)
	tutorial = "The Knight Lieutenant is a seasoned knight who earned their position through merit, chosen from the ranks of squires. Tasked with overseeing the day-to-day operations of the garrison, they ensure the readiness, discipline, and coordination of those under their command. While they hold significant authority in maintaining the defence and order of the realm they ultimately answer to the Knight Banneret and the court."
	display_order = JDO_KNIGHT
	whitelist_req = TRUE
	outfit = /datum/outfit/job/roguetown/knight
	advclass_cat_rolls = list(CTAG_ROYALGUARD = 20)

	give_bank_account = 22
	noble_income = 10
	min_pq = 0
	max_pq = null
	round_contrib_points = 2

	cmode_music = 'sound/music/combat_knight.ogg'

/datum/job/roguetown/knight/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	..()
	if(L && M?.client)
		var/mob/living/carbon/human/H = L
		var/list/valid_classes = list()
		var/preferred_class = M.client?.prefs?.knight_lieutenant_class

		// Build list of valid classes for this character
		for(var/type in subtypesof(/datum/advclass/knight))
			var/datum/advclass/knight/AC = new type()
			if(!AC.name)
				qdel(AC)
				continue
			
			// Check if class is allowed for this player
			if(AC.allowed_sexes?.len && !(H.gender in AC.allowed_sexes))
				qdel(AC)
				continue
			if(AC.allowed_races?.len && !(H.dna.species.type in AC.allowed_races))
				qdel(AC)
				continue
			if(AC.min_pq != -100 && !(get_playerquality(M.client.ckey) >= AC.min_pq))
				qdel(AC)
				continue
			
			valid_classes[AC.name] = AC

		// If no valid classes found, something is wrong
		if(!length(valid_classes))
			to_chat(M, span_warning("No valid classes found! Please report this to an admin."))
			return

		var/datum/advclass/knight/chosen_class
		if(preferred_class && valid_classes[preferred_class])
			// Use preferred class if it's valid
			chosen_class = valid_classes[preferred_class]
			to_chat(M, span_notice("Using your preferred class: [preferred_class]"))
			// Clean up other classes
			for(var/name in valid_classes)
				if(name != preferred_class)
					qdel(valid_classes[name])
		else
			// Choose random class from valid options
			var/chosen_name = pick(valid_classes)
			chosen_class = valid_classes[chosen_name]
			to_chat(M, span_warning("No class preference set. You have been randomly assigned: [chosen_name]"))
			// Clean up other classes
			for(var/name in valid_classes)
				if(name != chosen_name)
					qdel(valid_classes[name])

		// Let the class handle everything through its own equipme()
		if(chosen_class)
			H.mind?.transfer_to(H) // Ensure mind is properly set up
			chosen_class.equipme(H)
			qdel(chosen_class)

		// Apply knight title after class setup
		var/prev_real_name = H.real_name
		var/prev_name = H.name
		var/honorary = "Ser"
		if(H.pronouns == SHE_HER || H.pronouns == THEY_THEM_F)
			honorary = "Dame"
		H.real_name = "[honorary] [prev_real_name]"
		H.name = "[honorary] [prev_name]"

		for(var/X in peopleknowme)
			for(var/datum/mind/MF in get_minds(X))
				if(MF.known_people)
					MF.known_people -= prev_real_name
					H.mind.person_knows_me(MF)

/datum/outfit/job/roguetown/knight
	head = /obj/item/clothing/head/roguetown/helmet/bascinet/pigface
	pants = /obj/item/clothing/under/roguetown/chainlegs
	cloak = /obj/item/clothing/cloak/stabard/surcoat/guard
	gloves = /obj/item/clothing/gloves/roguetown/chain
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	beltl = /obj/item/storage/keyring/guardcastle
	belt = /obj/item/storage/belt/rogue/leather/black
	backr = /obj/item/storage/backpack/rogue/satchel/black
	backpack_contents = list(/obj/item/signal_horn = 1)

/datum/advclass/knight/heavy
	name = "Heavy Knight"
	tutorial = "You are the indisputed master of man-on-man combat. Shockingly adept with massive swords, axes, and maces. People may fear the mounted knights, but they should truly fear those who come off their mount.."
	outfit = /datum/outfit/job/roguetown/knight/heavy
	category_tags = list(CTAG_ROYALGUARD)

/datum/outfit/job/roguetown/knight/heavy/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.mind)
		//Normal shared skill section.
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/bows, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
		ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_NOBLE, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_GUARDSMAN, TRAIT_GENERIC)
		H.dna.species.soundpack_m = new /datum/voicepack/male/knight()
		H.verbs |= /mob/proc/haltyell

	neck = /obj/item/clothing/neck/roguetown/bevor
	armor = /obj/item/clothing/suit/roguetown/armor/plate
	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1, /obj/item/rope/chain = 1)

/datum/advclass/knight/heavy/equipme(mob/living/carbon/human/H)
	if(!H)
		return FALSE
	
	// First equip the base outfit
	if(outfit)
		var/datum/outfit/O = new outfit
		O.equip(H)

	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/polearms, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/axes, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/maces, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/shields, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/riding, 1, TRUE)

		H.change_stat("strength", 2)
		H.change_stat("constitution", 2)
		H.change_stat("endurance", 2)
		H.change_stat("perception", 1)
		H.change_stat("speed", -2)

	// Wait for client to be ready (up to 5 seconds)
	spawn(0)
		var/tries = 0
		while(!H?.client && tries < 10)
			tries++
			sleep(5)
			
		if(!H?.client)
			var/classchoice = pick(list("Zweihander", "Great Mace", "Battle Axe", "Estoc"))
			apply_class_equipment(H, classchoice)
			return

		to_chat(H, span_notice("\n\nChoose your Heavy Knight weapon..."))
		var/list/choices = list("Zweihander", "Great Mace", "Battle Axe", "Estoc")
		var/classchoice = input(H, "Choose your Heavy Knight weapon (30 seconds to choose)", "Weapon Selection") as anything in choices
		
		spawn(30 SECONDS)
			if(!classchoice)
				classchoice = pick(choices)
				to_chat(H, span_warning("Time's up! Random weapon selected: [classchoice]"))
				apply_class_equipment(H, classchoice)
		
		if(!classchoice)
			classchoice = pick(choices)
			to_chat(H, span_warning("No selection made. Random weapon selected: [classchoice]"))
		
		apply_class_equipment(H, classchoice)
	
	return TRUE

/datum/advclass/knight/heavy/proc/apply_class_equipment(mob/living/carbon/human/H, classchoice)
	H.adjust_blindness(-3)
	switch(classchoice)
		if("Zweihander")
			H.set_blindness(0)
			to_chat(H, span_warning("You are a master of the mighty zweihander."))
			H.put_in_r_hand(new /obj/item/rogueweapon/greatsword/zwei(H))
		if("Great Mace")
			H.set_blindness(0)
			to_chat(H, span_warning("You wield a devastating great mace."))
			H.put_in_r_hand(new /obj/item/rogueweapon/mace/goden/steel(H))
		if("Battle Axe")
			H.set_blindness(0)
			to_chat(H, span_warning("You are skilled with the fearsome battle axe."))
			H.put_in_r_hand(new /obj/item/rogueweapon/stoneaxe/battle(H))
		if("Estoc")
			H.set_blindness(0)
			to_chat(H, span_warning("You are trained in the precise art of the estoc."))
			H.put_in_r_hand(new /obj/item/rogueweapon/estoc(H))

/datum/advclass/knight/footknight
	name = "Foot Knight"
	tutorial = "You are accustomed to traditional foot-soldier training in swords, flails, and shields. You are not as used to riding a mount as other knights, but you are the finest of all with the versatile combination of a shield and weapon!"
	outfit = /datum/outfit/job/roguetown/knight/footknight
	category_tags = list(CTAG_ROYALGUARD)

/datum/outfit/job/roguetown/knight/footknight/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.mind)
		//Normal shared skill section.
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/bows, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
		ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_NOBLE, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_GUARDSMAN, TRAIT_GENERIC)
		H.dna.species.soundpack_m = new /datum/voicepack/male/knight()
		H.verbs |= /mob/proc/haltyell

	neck = /obj/item/clothing/neck/roguetown/chaincoif
	armor = /obj/item/clothing/suit/roguetown/armor/brigandine/coatplates
	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1, /obj/item/rope/chain = 1)

/datum/advclass/knight/footknight/equipme(mob/living/carbon/human/H)
	if(!H)
		return FALSE
	
	// First equip the base outfit
	if(outfit)
		var/datum/outfit/O = new outfit
		O.equip(H)

	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/polearms, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/axes, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/maces, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/shields, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/riding, 2, TRUE)

		H.change_stat("strength", 2)
		H.change_stat("constitution", 1)
		H.change_stat("endurance", 2)
		H.change_stat("intelligence", 1)
		H.change_stat("speed", -1)

	// Wait for client to be ready (up to 5 seconds)
	spawn(0)
		var/tries = 0
		while(!H?.client && tries < 10)
			tries++
			sleep(5)
			
		if(!H?.client)
			var/classchoice = pick(list("Bastard Sword", "Flail"))
			apply_class_equipment(H, classchoice)
			return

		to_chat(H, span_notice("\n\nChoose your Foot Knight weapon..."))
		var/list/choices = list("Bastard Sword", "Flail")
		var/classchoice = input(H, "Choose your Foot Knight weapon (30 seconds to choose)", "Weapon Selection") as anything in choices
		
		spawn(30 SECONDS)
			if(!classchoice)
				classchoice = pick(choices)
				to_chat(H, span_warning("Time's up! Random weapon selected: [classchoice]"))
				apply_class_equipment(H, classchoice)
		
		if(!classchoice)
			classchoice = pick(choices)
			to_chat(H, span_warning("No selection made. Random weapon selected: [classchoice]"))
		
		apply_class_equipment(H, classchoice)
	
	return TRUE

/datum/advclass/knight/footknight/proc/apply_class_equipment(mob/living/carbon/human/H, classchoice)
	H.adjust_blindness(-3)
	switch(classchoice)
		if("Bastard Sword")
			H.set_blindness(0)
			to_chat(H, span_warning("You are a skilled swordsman with shield."))
			H.equip_to_slot_or_del(new /obj/item/rogueweapon/sword/long(H), SLOT_BELT_R)
			H.equip_to_slot_or_del(new /obj/item/rogueweapon/shield/tower/metal(H), SLOT_BACK_L)
		if("Flail")
			H.set_blindness(0)
			to_chat(H, span_warning("You are trained in the deadly art of flail and shield."))
			H.equip_to_slot_or_del(new /obj/item/rogueweapon/flail/sflail(H), SLOT_BELT_R)
			H.equip_to_slot_or_del(new /obj/item/rogueweapon/shield/tower/metal(H), SLOT_BACK_L)

/datum/advclass/knight/mountedknight
	name = "Mounted Knight"
	tutorial = "You are the picture-perfect knight from a high tale, knowledgeable in riding steeds into battle. You specialize in weapons most useful on a saiga including spears, swords and maces, but know your way around a shield."
	outfit = /datum/outfit/job/roguetown/knight/mountedknight
	category_tags = list(CTAG_ROYALGUARD)

/datum/outfit/job/roguetown/knight/mountedknight/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.mind)
		//Normal shared skill section.
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/bows, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
		ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_NOBLE, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_GUARDSMAN, TRAIT_GENERIC)
		H.dna.species.soundpack_m = new /datum/voicepack/male/knight()
		H.verbs |= /mob/proc/haltyell

	neck = /obj/item/clothing/neck/roguetown/chaincoif
	armor = /obj/item/clothing/suit/roguetown/armor/brigandine/coatplates
	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1, /obj/item/rope/chain = 1)

/datum/advclass/knight/mountedknight/equipme(mob/living/carbon/human/H)
	if(!H)
		return FALSE
	
	// First equip the base outfit
	if(outfit)
		var/datum/outfit/O = new outfit
		O.equip(H)

	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/polearms, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/axes, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/maces, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/shields, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/riding, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/bows, 1, TRUE)

		H.change_stat("strength", 1)
		H.change_stat("intelligence", 2)
		H.change_stat("constitution", 1)
		H.change_stat("endurance", 1)
		H.change_stat("perception", 2)

	// Wait for client to be ready (up to 5 seconds)
	spawn(0)
		var/tries = 0
		while(!H?.client && tries < 10)
			tries++
			sleep(5)
			
		if(!H?.client)
			var/classchoice = pick(list("Bastard Sword", "Spear"))
			apply_class_equipment(H, classchoice)
			return

		to_chat(H, span_notice("\n\nChoose your Mounted Knight weapon..."))
		var/list/choices = list("Bastard Sword", "Spear")
		var/classchoice = input(H, "Choose your Mounted Knight weapon (30 seconds to choose)", "Weapon Selection") as anything in choices
		
		spawn(30 SECONDS)
			if(!classchoice)
				classchoice = pick(choices)
				to_chat(H, span_warning("Time's up! Random weapon selected: [classchoice]"))
				apply_class_equipment(H, classchoice)
		
		if(!classchoice)
			classchoice = pick(choices)
			to_chat(H, span_warning("No selection made. Random weapon selected: [classchoice]"))
		
		apply_class_equipment(H, classchoice)
	
	return TRUE

/datum/advclass/knight/mountedknight/proc/apply_class_equipment(mob/living/carbon/human/H, classchoice)
	H.adjust_blindness(-3)
	switch(classchoice)
		if("Bastard Sword")
			H.set_blindness(0)
			to_chat(H, span_warning("You are a mounted swordsman, deadly with blade and shield."))
			H.equip_to_slot_or_del(new /obj/item/rogueweapon/sword/long(H), SLOT_BELT_R)
			H.equip_to_slot_or_del(new /obj/item/rogueweapon/shield/tower/metal(H), SLOT_BACK_L)
		if("Spear")
			H.set_blindness(0)
			to_chat(H, span_warning("You are a mounted lancer, master of the charge."))
			H.put_in_r_hand(new /obj/item/rogueweapon/spear(H))
			H.equip_to_slot_or_del(new /obj/item/rogueweapon/shield/tower/metal(H), SLOT_BACK_L)

// used for blackguards event
/datum/job/roguetown/blackguard_lieutenant
	title = "Blackguard Lieutenant"
	flag = KNIGHT
	department_flag = NOBLEMEN
	faction = "Station"
	total_positions = 0 
	spawn_positions = 0
