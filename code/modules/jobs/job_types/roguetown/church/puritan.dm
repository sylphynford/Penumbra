/datum/job/roguetown/puritan
	title = "Inquisitor"
	flag = PURITAN
	department_flag = CHURCHMEN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	allowed_patrons = ALL_DIVINE_PATRONS
	tutorial = "You worship and pay credence to the Gods. Both the crown and church have emboldened your radical ideals. Your fervor allows you to root out cultists, the cursed night beasts, and other agents of the abyss, as you are entrusted with the ability of extracting involuntary 'sin confessions.'"
	whitelist_req = TRUE
	advclass_cat_rolls = list(CTAG_INQUISITOR = 20)

	outfit = /datum/outfit/job/roguetown/puritan
	display_order = JDO_PURITAN
	give_bank_account = 36
	max_pq = null
	min_pq = 0
	round_contrib_points = 2


/datum/job/roguetown/puritan/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	..()
	if(!L.mind)
		return
	if(L.mind.has_antag_datum(/datum/antagonist))
		return
	var/datum/antagonist/new_antag = new /datum/antagonist/purishep()
	L.mind.add_antag_datum(new_antag)
	var/mob/living/carbon/human/H = L
	H.advsetup = 1
	H.invisibility = INVISIBILITY_MAXIMUM
	H.become_blind("advsetup")


/datum/outfit/job/roguetown/puritan
	name = "Inquisitor"
	jobtype = /datum/job/roguetown/puritan

/datum/outfit/job/roguetown/puritan/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.mind)
		H.verbs |= /mob/living/carbon/human/proc/faith_test
		H.verbs |= /mob/living/carbon/human/proc/torture_victim
		ADD_TRAIT(H, TRAIT_NOSEGRAB, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)


/datum/advclass/inquisitor/confessor
	name = "Confessor"
	tutorial = "Bathed in rays of gold, you sing the melody of a self-proclaimed savior, the Confessor. Armed with the lightening-infused stun mace and the ability to flush the corruption from the unclean, you may just be able to back up these claims. Unfortunately, however, your over-reliance on the power of the stun mace has left you rusty in genuine skill. And yet, it does not seem to matter."
	outfit = /datum/outfit/job/roguetown/inquisitor/confessor

	category_tags = list(CTAG_INQUISITOR)

/datum/outfit/job/roguetown/inquisitor/confessor/pre_equip(mob/living/carbon/human/H)
	..()
	H.verbs += /datum/job/roguetown/confessor/verb/ConvertToDivine
	H.mind.adjust_skillrank(/datum/skill/combat/swords, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/bows, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/maces, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/sewing, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/medicine, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/tracking, 1, TRUE)
	H.change_stat("strength", 1)
	H.change_stat("endurance", 1)
	H.change_stat("constitution", 1)
	H.change_stat("speed", 1)
	H.change_stat("intelligence", 2)

	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/white
	belt = /obj/item/storage/belt/rogue/leather/plaquegold
	neck = /obj/item/clothing/neck/roguetown/psicross/g
	shoes = /obj/item/clothing/shoes/roguetown/boots
	pants = /obj/item/clothing/under/roguetown/tights/black
	cloak = /obj/item/clothing/cloak/cape/puritan
	backr = /obj/item/storage/backpack/rogue/satchel/black
	beltr = /obj/item/storage/belt/rogue/pouch/coins/mid
	mask = /obj/item/clothing/mask/rogue/facemask/goldmask
	gloves = /obj/item/clothing/gloves/roguetown/leather
	backpack_contents = list(/obj/item/storage/keyring/puritan = 1, /obj/item/rogueweapon/huntingknife/idagger/silver)
	beltl = /obj/item/rogueweapon/mace/stunmace
	ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)

/datum/advclass/inquisitor/zealot
	name = "Zealot"
	tutorial = "Once master warrior-monk turned Zealot. Your journey of self-perfection has ended in great success, leaving you with the skill and strength of legend. Yet, you feel as though your journey has just begun. It seems to you that the power to eradicate the abyssal corruption with such finesse must surely be put to use in tribute to the Gods whom led you down this path so long ago."
	outfit = /datum/outfit/job/roguetown/inquisitor/zealot

	category_tags = list(CTAG_INQUISITOR)

/datum/outfit/job/roguetown/inquisitor/zealot/pre_equip(mob/living/carbon/human/H)
	..()
	H.mind.adjust_skillrank(/datum/skill/combat/swords, 5, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 5, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 5, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/bows, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/maces, 5, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/sewing, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/medicine, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/tracking, 2, TRUE)
	H.change_stat("strength", 2)
	H.change_stat("endurance", 1)
	H.change_stat("constitution", 2)
	H.change_stat("speed", 1)

	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
	belt = /obj/item/storage/belt/rogue/leather
	neck = /obj/item/clothing/neck/roguetown/psicross/silver
	shoes = /obj/item/clothing/shoes/roguetown/sandals
	cloak = /obj/item/clothing/cloak/cape/puritan
	backr = /obj/item/storage/backpack/rogue/satchel/black
	beltr = /obj/item/storage/belt/rogue/pouch/coins/rich
	armor = /obj/item/clothing/suit/roguetown/shirt/robe
	head = /obj/item/clothing/head/roguetown/headband
	gloves = /obj/item/clothing/gloves/roguetown/leather
	backpack_contents = list(/obj/item/storage/keyring/puritan = 1, /obj/item/rogueweapon/huntingknife/idagger/silver)
	beltl = /obj/item/rogueweapon/sword/rapier
	ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_DODGEEXPERT, TRAIT_GENERIC)

/datum/advclass/inquisitor/puritanclass
	name = "Puritan"
	tutorial = "Future monster hunters will look upon the work of the Puritan with adoration. A heavy heart and steady hand guide your crusade against the creatures of the night. It may be your experience or superstition that keeps you alive, however you believe the true answer lies in the cold metal that separates the teeth of your enemies from your flesh."
	outfit = /datum/outfit/job/roguetown/inquisitor/puritanclass

	category_tags = list(CTAG_INQUISITOR)

/datum/outfit/job/roguetown/inquisitor/puritanclass/pre_equip(mob/living/carbon/human/H)
	..()
	H.mind.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 5, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/bows, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/maces, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/sewing, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/medicine, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/tracking, 4, TRUE)
	H.change_stat("strength", 1)
	H.change_stat("endurance", 1)
	H.change_stat("constitution", 3)
	H.change_stat("perception", 2)
	H.change_stat("speed", 1)
	H.change_stat("intelligence", 1)

	armor = /obj/item/clothing/suit/roguetown/armor/plate
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/puritan
	belt = /obj/item/storage/belt/rogue/leather
	neck = /obj/item/clothing/neck/roguetown/chaincoif/full
	wrists = /obj/item/clothing/neck/roguetown/psicross/silver
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	pants = /obj/item/clothing/under/roguetown/trou/leather
	cloak = /obj/item/clothing/cloak/cape/puritan
	backr = /obj/item/storage/backpack/rogue/satchel/black
	backl = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
	beltr = /obj/item/quiver/bolts
	head = /obj/item/clothing/head/roguetown/puritan
	gloves = /obj/item/clothing/gloves/roguetown/leather
	mask = /obj/item/clothing/mask/rogue/eyepatch
	backpack_contents = list(/obj/item/storage/keyring/puritan = 1, /obj/item/rogueweapon/huntingknife/idagger/silver, /obj/item/storage/belt/rogue/pouch/coins/mid = 1)
	beltl = /obj/item/rogueweapon/sword/falchion
	ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)


/mob/living/carbon/human/proc/torture_victim()
	set name = "Extract Confession"
	set category = "Inquisition"

	var/obj/item/grabbing/I = get_active_held_item()
	var/mob/living/carbon/human/H
	if(!istype(I) || !ishuman(I.grabbed))
		return
	H = I.grabbed
	if(H == src)
		to_chat(src, span_warning("I already torture myself."))
		return
	var/painpercent = (H.get_complex_pain() / (H.STAEND * 10)) * 100
	if(H.add_stress(/datum/stressevent/tortured))
		if(!H.stat)
			var/static/list/torture_lines = list(
				"CONFESS!",
				"TELL ME YOUR SECRETS!",
				"SPEAK!",
				"YOU WILL SPEAK!",
				"TELL ME!",
				"THE PAIN HAS ONLY BEGUN, CONFESS!",
			)
			say(pick(torture_lines), spans = list("torture"))
			if(painpercent >= 100)
				H.emote("painscream")
				H.confession_time("antag")
				return
	to_chat(src, span_warning("Not ready to speak yet."))

/mob/living/carbon/human/proc/faith_test()
	set name = "Test Faith"
	set category = "Inquisition"

	var/obj/item/grabbing/I = get_active_held_item()
	var/mob/living/carbon/human/H
	if(!istype(I) || !ishuman(I.grabbed))
		return
	H = I.grabbed
	if(H == src)
		to_chat(src, span_warning("I already torture myself."))
		return
	var/painpercent = (H.get_complex_pain() / (H.STAEND * 10)) * 100
	if(H.add_stress(/datum/stressevent/tortured))
		if(!H.stat)
			var/static/list/faith_lines = list(
				"DO YOU DENY PSYDON?",
				"WHO IS YOUR GOD?",
				"ARE YOU FAITHFUL?",
				"WHO IS YOUR SHEPHERD?",
			)
			say(pick(faith_lines), spans = list("torture"))
			if(painpercent >= 100)
				H.emote("painscream")
				H.confession_time("patron")
				return
	to_chat(src, span_warning("Not ready to speak yet."))

/mob/living/carbon/human/proc/confession_time(confession_type = "antag")
	var/timerid = addtimer(CALLBACK(src, PROC_REF(confess_sins)), 6 SECONDS, TIMER_STOPPABLE)
	var/responsey = alert(src, "Resist torture? (1 TRI)", "TORTURE", "Yes","No")
	if(!responsey)
		responsey = "No"
	if(SStimer.timer_id_dict[timerid])
		deltimer(timerid)
	else
		to_chat(src, span_warning("Too late..."))
		return
	if(responsey == "Yes")
		adjust_triumphs(-1)
		confess_sins(confession_type, resist = TRUE)
	else
		confess_sins(confession_type)

/mob/living/carbon/human/proc/confess_sins(confession_type = "antag", resist)
	var/static/list/innocent_lines = list(
		"I DON'T KNOW!",
		"STOP THE PAIN!!",
		"I DON'T DESERVE THIS!",
		"THE PAIN!",
		"I HAVE NOTHING TO SAY...!",
		"WHY ME?!",
	)
	if(!resist)
		var/list/confessions = list()
		switch(confession_type)
			if("patron")
				if(length(patron?.confess_lines))
					confessions += patron.confess_lines
			if("antag")
				for(var/datum/antagonist/antag in mind?.antag_datums)
					if(!length(antag.confess_lines))
						continue
					confessions += antag.confess_lines
		if(length(confessions))
			say(pick(confessions), spans = list("torture"))
			return
	say(pick(innocent_lines), spans = list("torture"))
