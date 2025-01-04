/datum/job/roguetown/Huskar
	title = "Huskar"
	flag = HUSKAR
	department_flag = NOBLEMEN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	allowed_races = OTAVAN_RACE_TYPES
	allowed_sexes = list(MALE, FEMALE)
	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED)
	tutorial = "The Huskar is the Baron's most devoted servant, a position of trust earned through a lifetime of unwavering loyalty and proven skill. Answering only to the nobility, they oversee the defense of the realm and the enforcement of the court's decrees with ruthless efficiency. Among the commoners, they are both feared and respected as an incorruptible force, but it is also well known that their dedication has led them to commit terrible acts in the name of the Barony, deeds they view not as atrocities, but as necessary measures to uphold the order they believe in."
	display_order = JDO_HUSKAR
	whitelist_req = TRUE
	outfit = /datum/outfit/job/roguetown/huskar
	zizo_roll = 100
	give_bank_account = 26
	noble_income = 16
	min_pq = 0
	max_pq = null
	round_contrib_points = 2

	cmode_music = 'sound/music/combat_knight.ogg'
	family_blacklisted = TRUE

/datum/job/roguetown/captain/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	. = ..()
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
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

/datum/outfit/job/roguetown/huskar/pre_equip(mob/living/carbon/human/H)
	..()
	belt = /obj/item/storage/belt/rogue/leather
	beltl = /obj/item/rogueweapon/sword/sabre
	beltr = /obj/item/rogueweapon/mace/steel
	neck = /obj/item/clothing/neck/roguetown/fencerguard
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/otavan
	head = /obj/item/clothing/head/roguetown/helmet/otavan
	armor = /obj/item/clothing/suit/roguetown/armor/otavan
	pants = /obj/item/clothing/under/roguetown/trou/otavan
	shoes = /obj/item/clothing/shoes/roguetown/otavan
	gloves = /obj/item/clothing/gloves/roguetown/otavan
	backr = /obj/item/storage/backpack/rogue/satchel/black
	backl = /obj/item/rogueweapon/shield/tower/metal
	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1, /obj/item/storage/keyring/sheriff, /obj/item/storage/belt/rogue/pouch/coins/rich = 1)
	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/maces, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 5, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/swords, 5, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/shields, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/polearms, 5, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/riding, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
		H.change_stat("strength", 4)
		H.change_stat("endurance", 2)
		H.change_stat("constitution", 3)
		H.change_stat("perception", 1)
		H.change_stat("speed", -1)
	H.dna.species.soundpack_m = new /datum/voicepack/male/knight()
	ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_NOBLE, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)
	H.verbs |= /mob/proc/haltyell

	/obj/effect/proc_holder/spell/self/convertrole
		name = "Recruit Beggar"
		desc = "Recruit someone to your cause."
		overlay_state = "recruit_bog"
		antimagic_allowed = TRUE
		charge_max = 100
		/// Role given if recruitment is accepted
		var/new_role = "Beggar"
		/// Faction shown to the user in the recruitment prompt
		var/recruitment_faction = "Beggars"
		/// Message the recruiter gives
		var/recruitment_message = "Serve the beggars, %RECRUIT!"
		/// Range to search for potential recruits
		var/recruitment_range = 3
		/// Say message when the recruit accepts
		var/accept_message = "I will serve!"
		/// Say message when the recruit refuses
		var/refuse_message = "I refuse."

	/obj/effect/proc_holder/spell/self/convertrole/cast(list/targets,mob/user = usr)
		. = ..()
		var/list/recruitment = list()
		for(var/mob/living/carbon/human/recruit in (get_hearers_in_view(recruitment_range, user) - user))
			//not allowed
			if(!can_convert(recruit))
				continue
			recruitment[recruit.name] = recruit
		if(!length(recruitment))
			to_chat(user, span_warning("There are no potential recruits in range."))
			return
		var/inputty = input(user, "Select a potential recruit!", "[name]") as anything in recruitment
		if(inputty)
			var/mob/living/carbon/human/recruit = recruitment[inputty]
			if(!QDELETED(recruit) && (recruit in get_hearers_in_view(recruitment_range, user)))
				INVOKE_ASYNC(src, PROC_REF(convert), recruit, user)
			else
				to_chat(user, span_warning("Recruitment failed!"))
		else
			to_chat(user, span_warning("Recruitment cancelled."))

	/obj/effect/proc_holder/spell/self/convertrole/proc/can_convert(mob/living/carbon/human/recruit)
		//wtf
		if(QDELETED(recruit))
			return FALSE
		//need a mind
		if(!recruit.mind)
			return FALSE
		//only migrants and peasants
		if(!(recruit.job in GLOB.peasant_positions) && \
			!(recruit.job in GLOB.yeoman_positions) && \
			!(recruit.job in GLOB.allmig_positions) && \
			!(recruit.job in GLOB.mercenary_positions))
			return FALSE
		//need to see their damn face
		if(!recruit.get_face_name(null))
			return FALSE
		return TRUE

	/obj/effect/proc_holder/spell/self/convertrole/proc/convert(mob/living/carbon/human/recruit, mob/living/carbon/human/recruiter)
		if(QDELETED(recruit) || QDELETED(recruiter))
			return FALSE
		recruiter.say(replacetext(recruitment_message, "%RECRUIT", "[recruit]"), forced = "[name]")
		var/prompt = alert(recruit, "Do you wish to become a [new_role]?", "[recruitment_faction] Recruitment", "Yes", "No")
		if(QDELETED(recruit) || QDELETED(recruiter) || !(recruiter in get_hearers_in_view(recruitment_range, recruit)))
			return FALSE
		if(prompt != "Yes")
			if(refuse_message)
				recruit.say(refuse_message, forced = "[name]")
			return FALSE
		if(accept_message)
			recruit.say(accept_message, forced = "[name]")
		if(new_role)
			recruit.job = new_role
		return TRUE

	/obj/effect/proc_holder/spell/self/convertrole/guard
		name = "Recruit Guardsmen"
		new_role = "Town Guard"
		overlay_state = "recruit_guard"
		recruitment_faction = "Watchman"
		recruitment_message = "Serve the town guard, %RECRUIT!"
		accept_message = "FOR THE BARON!"
		refuse_message = "I refuse."

	/obj/effect/proc_holder/spell/self/convertrole/guard/convert(mob/living/carbon/human/recruit, mob/living/carbon/human/recruiter)
		. = ..()
		if(!.)
			return
		recruit.verbs |= /mob/proc/haltyell
