/datum/job/roguetown/partyleader
	title = "Party Leader"
	flag = PARTY_LEADER
	department_flag = PEASANTS
	faction = "Station"
	total_positions = 0
	spawn_positions = 0

	allowed_races = ALL_RACES_TYPES
	allowed_sexes = list(MALE, FEMALE)
	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD)
	tutorial = "You've received a quest with promise of great reward. Recruit Adventurers and Mercenaries to help you achieve it."
	display_order = JDO_PARTY_LEADER
	whitelist_req = FALSE

	spells = list(/obj/effect/proc_holder/spell/self/joinparty/partymember)
	outfit = /datum/outfit/job/roguetown/partyleader

	min_pq = 0
	max_pq = null
	round_contrib_points = 3

/datum/outfit/job/roguetown/partyleader/pre_equip(mob/living/carbon/human/H)
	..()
	neck = /obj/item/clothing/neck/roguetown/gorget
	armor = /obj/item/clothing/suit/roguetown/armor/plate
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
	pants = /obj/item/clothing/under/roguetown/chainlegs
	gloves = /obj/item/clothing/gloves/roguetown/plate
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/
	belt = /obj/item/storage/belt/rogue/leather/
	beltl = /obj/item/rogueweapon/sword/sabre
	cloak = /obj/item/clothing/cloak/cape
	backr = /obj/item/storage/backpack/rogue/satchel/black
	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1)
	if(H.mind)
		var/datum/antagonist/new_antag = new /datum/antagonist/partyleader()
		H.mind.add_antag_datum(new_antag)
		H.mind.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/polearms, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/maces, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/shields, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/bows, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
		H.change_stat("strength", 1)
		H.change_stat("perception", 1)
		H.change_stat("intelligence", 2)
		H.change_stat("constitution", 2)
		H.change_stat("endurance", 2)
		H.change_stat("fortune", 1)
	ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_PARTY_MEMBER, TRAIT_GENERIC)

/obj/effect/proc_holder/spell/self/joinparty
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

/obj/effect/proc_holder/spell/self/joinparty/cast(list/targets,mob/user = usr)
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

/obj/effect/proc_holder/spell/self/joinparty/proc/can_convert(mob/living/carbon/human/recruit)
	if(QDELETED(recruit))
		return FALSE
	if(!recruit.mind)
		return FALSE
	//only advs and mercs
	if(!(recruit.job in GLOB.party_positions))
		return FALSE
	if(!recruit.get_face_name(null))
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/self/joinparty/proc/convert(mob/living/carbon/human/recruit, mob/living/carbon/human/recruiter)
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
	ADD_TRAIT(recruit, TRAIT_PARTY_MEMBER, TRAIT_GENERIC)
	return TRUE

/obj/effect/proc_holder/spell/self/joinparty/partymember
	name = "Recruit Party Member"
	new_role = "Party Member"
	overlay_state = "recruit_guard"
	recruitment_faction = "Adventuring party"
	recruitment_message = "Join my party, %RECRUIT!"
	accept_message = "I'm in!"
	refuse_message = "I refuse."

/datum/antagonist/partyleader
	name = "Party Leader"
	roundend_category = "Party Members"
	antagpanel_category = "Party Leader"
	antag_hud_type = ANTAG_HUD_TRAITOR
	rogue_enabled = TRUE

/datum/antagonist/partyleader/on_gain()
	owner.special_role = "Party Leader"
	add_objective()
	. = ..()


/* /datum/antagonist/bandit/greet()
	to_chat(owner.current, span_alertsyndie("I am a BANDIT!"))
	to_chat(owner.current, span_info("Long ago I did a crime worthy of my bounty being hung on the wall outside of the local inn. I must feed the idol money and valuable metals to satisfy my greed!"))
	owner.announce_objectives()
	..() */ //commenting out until they get a proper objective implementation or whatever.

/*
	if(!(locate(/datum/objective/bandit) in objectives))
		var/datum/objective/bandit/bandit_objective = new
		bandit_objective.owner = owner
		objectives += bandit_objective
	if(!(locate(/datum/objective/escape) in objectives))
		var/datum/objective/escape/boat/escape_objective = new
		escape_objective.owner = owner
		objectives += escape_objective*/



/datum/antagonist/partyleader/roundend_report()
	if(owner?.current)
		var/the_name = owner.name
		if(ishuman(owner.current))
			var/mob/living/carbon/human/H = owner.current
			the_name = H.real_name
			to_chat(world, "[the_name] was the party leader.")

/datum/antagonist/partyleader/proc/add_objective(datum/objective/O)
	var/datum/objective/steal/steal_objective = new O
	objectives += steal_objective
