// Eleven unique mercenary type; should be scary in a way solo but easy to kill with a group or bow.
/datum/advclass/mercenary/blackoak
	name = "Black Oak's Guardian"
	tutorial = "A shady guardian of the Black Oaks. Half mercenary band, half irregular militia fighting for control of their ancestral elven homeland of the Peaks. Thankfully, you are not here today to shed the blood of the Baron's men- unless someone pays you to.."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = list(
		/datum/species/human/halfelf,
		/datum/species/elf/wood,
	)
	outfit = /datum/outfit/job/roguetown/mercenary/blackoak
	category_tags = list(CTAG_MERCENARY)

/datum/outfit/job/roguetown/mercenary/blackoak/pre_equip(mob/living/carbon/human/H)
	..()
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	cloak = /obj/item/clothing/cloak/half/red
	head = /obj/item/clothing/head/roguetown/helmet/sallet/elven
	gloves = /obj/item/clothing/gloves/roguetown/angle
	belt = /obj/item/storage/belt/rogue/leather/black
	armor = /obj/item/clothing/suit/roguetown/armor/plate/half/elven
	backl = /obj/item/storage/backpack/rogue/satchel
	beltl = /obj/item/rogueweapon/huntingknife/idagger/steel/special
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/black
	pants = /obj/item/clothing/under/roguetown/trou/leather
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	backpack_contents = list(/obj/item/roguekey/mercenary, /obj/item/storage/belt/rogue/pouch/coins/poor)
	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/polearms, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/swimming, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/tracking, 2, TRUE)
		H.change_stat("endurance", 2)
		H.change_stat("constitution", 2)
		H.change_stat("strength", 1)
		H.change_stat("speed", 1)
	ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)

/datum/advclass/mercenary/blackoak/equipme(mob/living/carbon/human/H)
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
			
		if(!H?.client)
			var/classchoice = pick(list("Bardiche Master", "Infiltrator"))
			apply_class_equipment(H, classchoice)
			return

		to_chat(H, span_notice("\n\nChoose your Black Oak archetype..."))
		var/classchoice = alert(H, "Choose your Black Oak archetype (30 seconds to choose)", "Class Selection", "Bardiche Master", "Infiltrator")
		
		spawn(30 SECONDS)
			if(!classchoice)
				classchoice = pick(list("Bardiche Master", "Infiltrator"))
				to_chat(H, span_warning("Time's up! Random archetype selected: [classchoice]"))
				apply_class_equipment(H, classchoice)
		
		if(!classchoice)
			classchoice = pick(list("Bardiche Master", "Infiltrator"))
			to_chat(H, span_warning("No selection made. Random archetype selected: [classchoice]"))
		
		apply_class_equipment(H, classchoice)
	
	return TRUE

/datum/advclass/mercenary/blackoak/proc/apply_class_equipment(mob/living/carbon/human/H, classchoice)
	switch(classchoice)
		if("Bardiche Master")
			H.set_blindness(0)
			to_chat(H, span_warning("You are a Bardiche Master of the Black Oaks, skilled with heavy polearms."))
			var/obj/item/rogueweapon/halberd/bardiche/bardiche = new(get_turf(H))
			H.put_in_hands(bardiche)
		if("Infiltrator")
			H.set_blindness(0)
			to_chat(H, span_warning("You are an Infiltrator of the Black Oaks, skilled with daggers and stealth."))
			var/obj/item/rogueweapon/huntingknife/idagger/steel/special/dagger = new(get_turf(H))
			H.put_in_hands(dagger)
