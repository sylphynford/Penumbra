/datum/job/roguetown/prince
	title = "Heir"
	f_title = "Successor"
	flag = PRINCE
	department_flag = YOUNGFOLK
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	allowed_races = NOBLE_RACES_TYPES //Maybe a system to force-pick lineage based on king and queen should be implemented.
	allowed_sexes = list(MALE, FEMALE)
	allowed_ages = list(AGE_YOUNG, AGE_ADULT)
	advclass_cat_rolls = list(CTAG_HEIR = 20)
	tutorial = "You've never felt the gnawing of the winter, never known the bite of hunger and certainly have never known a honest day's work. You are as free as any bird in the sky, and you may revel in your debauchery for as long as your parents remain upon the throne: But someday you'll have to grow up, and that will be the day your carelessness will cost you more than a few mammons."
	display_order = JDO_PRINCE
	give_bank_account = 30
	noble_income = 20
	min_pq = 0
	max_pq = null
	round_contrib_points = 3
	cmode_music = 'sound/music/combat_fancy.ogg'
	family_blacklisted = TRUE
	lord_family = TRUE
	lord_rel_type = REL_TYPE_OFFSPRING
	outfit = null // Handled by classes

/datum/job/roguetown/prince/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	..()
	if(L && M?.client)
		var/mob/living/carbon/human/H = L
		var/list/valid_classes = list()
		var/preferred_class = M.client?.prefs?.heir_class

		// Build list of valid classes for this character
		for(var/type in subtypesof(/datum/advclass/heir))
			var/datum/advclass/heir/AC = new type()
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

		var/datum/advclass/heir/chosen_class
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

/datum/advclass/heir/daring
	name = "Daring Twit"
	tutorial = "You're a somebody, someone important. It only makes sense you want to make a name for yourself, to gain your own glory so people see how great you really are beyond your bloodline. Plus, if you're beloved by the people for your exploits you'll be chosen! Probably. Shame you're as useful and talented as a squire, despite your delusions to the contrary."
	outfit = /datum/outfit/job/roguetown/heir/daring
	category_tags = list(CTAG_HEIR)

/datum/outfit/job/roguetown/heir/daring
	pants = /obj/item/clothing/under/roguetown/tights
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/guard
	armor = /obj/item/clothing/suit/roguetown/armor/chainmail
	shoes = /obj/item/clothing/shoes/roguetown/nobleboot
	belt = /obj/item/storage/belt/rogue/leather
	beltl = /obj/item/rogueweapon/sword
	beltr = /obj/item/storage/keyring/heir
	neck = /obj/item/storage/belt/rogue/pouch/coins/rich
	backr = /obj/item/storage/backpack/rogue/satchel

/datum/advclass/heir/daring/equipme(mob/living/carbon/human/H)
	if(!H)
		return FALSE

	// First equip the base outfit
	if(outfit)
		var/datum/outfit/O = new outfit
		O.equip(H)

	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/maces, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/bows, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/swords, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/riding, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
		H.change_stat("strength", 1)
		H.change_stat("perception", 1)
		H.change_stat("constitution", 1)
		H.change_stat("speed", 1)
		H.change_stat("fortune", 1)
		ADD_TRAIT(H, TRAIT_NOBLE, TRAIT_GENERIC)

	return TRUE

/datum/advclass/heir/aristocrat
	name = "Sheltered Aristocrat"
	tutorial = "Life has been kind to you; you've an entire keep at your disposal, servants to wait on you, and a whole retinue of guards to guard you. You've nothing to prove; just live the good life and you'll be a lord someday, too. A lack of ambition translates into a lacking skillset beyond schooling, though, and your breaks from boredom consist of being a damsel or court gossip."
	outfit = /datum/outfit/job/roguetown/heir/aristocrat
	category_tags = list(CTAG_HEIR)

/datum/outfit/job/roguetown/heir/aristocrat
	belt = /obj/item/storage/belt/rogue/leather
	beltl = /obj/item/storage/keyring/heir
	beltr = /obj/item/storage/belt/rogue/pouch/coins/rich

/datum/outfit/job/roguetown/heir/aristocrat/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(!H)
		return

	if(H.gender == MALE)
		pants = /obj/item/clothing/under/roguetown/tights
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/guard
		belt = /obj/item/storage/belt/rogue/leather
		shoes = /obj/item/clothing/shoes/roguetown/nobleboot
	else if(H.gender == FEMALE)
		belt = /obj/item/storage/belt/rogue/leather/cloth/lady
		head = /obj/item/clothing/head/roguetown/hennin
		armor = /obj/item/clothing/suit/roguetown/armor/silkcoat
		shirt = /obj/item/clothing/suit/roguetown/shirt/dress/silkdress/princess
		shoes = /obj/item/clothing/shoes/roguetown/shortboots
		pants = /obj/item/clothing/under/roguetown/tights/stockings/silk/random

/datum/advclass/heir/aristocrat/equipme(mob/living/carbon/human/H)
	if(!H)
		return FALSE

	// First equip the base outfit
	if(outfit)
		var/datum/outfit/O = new outfit
		O.equip(H)

	if(H.mind)
		ADD_TRAIT(H, TRAIT_NOBLE, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_SEEPRICES_SHITTY, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_GOODLOVER, TRAIT_GENERIC)

		H.mind.adjust_skillrank(/datum/skill/combat/bows, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/crossbows, pick(0,1), TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, pick(0,1), TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/riding, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/cooking, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/sewing, 1, TRUE)
		H.change_stat("perception", 2)
		H.change_stat("strength", -1)
		H.change_stat("intelligence", 2)
		H.change_stat("fortune", 1)
		H.change_stat("speed", 1)

	return TRUE

/datum/advclass/heir/inbred
	name = "Inbred wastrel"
	tutorial = "Your bloodline ensures Psydon smiles upon you by divine right, the blessing of nobility... until you were born, anyway. You are a child forsaken, and even though your body boils as you go about your day, your spine creaks, and your drooling form needs to be waited on tirelessly you are still considered more important then the peasant that keeps the town fed and warm. Remind them of that fact when your lungs are particularly pus free."
	outfit = /datum/outfit/job/roguetown/heir/inbred
	category_tags = list(CTAG_HEIR)

/datum/outfit/job/roguetown/heir/inbred
	belt = /obj/item/storage/belt/rogue/leather
	beltl = /obj/item/storage/keyring/heir
	beltr = /obj/item/storage/belt/rogue/pouch/coins/rich

/datum/outfit/job/roguetown/heir/inbred/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(!H)
		return

	if(H.pronouns == HE_HIM || H.pronouns == THEY_THEM || H.pronouns == IT_ITS)
		pants = /obj/item/clothing/under/roguetown/tights
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/guard
		belt = /obj/item/storage/belt/rogue/leather
		shoes = /obj/item/clothing/shoes/roguetown/nobleboot
	else if(H.pronouns == SHE_HER || H.pronouns == THEY_THEM_F)
		belt = /obj/item/storage/belt/rogue/leather/cloth/lady
		head = /obj/item/clothing/head/roguetown/hennin
		armor = /obj/item/clothing/suit/roguetown/armor/silkcoat
		shirt = /obj/item/clothing/suit/roguetown/shirt/dress/silkdress/princess
		shoes = /obj/item/clothing/shoes/roguetown/shortboots
		pants = /obj/item/clothing/under/roguetown/tights/stockings/silk/random

/datum/advclass/heir/inbred/equipme(mob/living/carbon/human/H)
	if(!H)
		return FALSE

	// First equip the base outfit
	if(outfit)
		var/datum/outfit/O = new outfit
		O.equip(H)

	if(H.mind)
		ADD_TRAIT(H, TRAIT_NOBLE, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_CRITICAL_WEAKNESS, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_NORUN, TRAIT_GENERIC)

		H.mind.adjust_skillrank(/datum/skill/combat/bows, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/crossbows, pick(0,1), TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, pick(0,0,1), TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, pick(0,1), TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/riding, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/cooking, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/sewing, 1, TRUE)
		H.change_stat("strength", -2)
		H.change_stat("perception", -2)
		H.change_stat("intelligence", -2)
		H.change_stat("constitution", -2)
		H.change_stat("endurance", -2)
		H.change_stat("fortune", -2)

	return TRUE
