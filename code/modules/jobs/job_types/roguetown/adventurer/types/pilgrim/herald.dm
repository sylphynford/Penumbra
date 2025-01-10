/datum/advclass/herald
	name = "Herald"
	tutorial = "As a Herald, you are a messenger and storyteller. Use your voice to spread news, warnings, and tales across the land. Your announcements can reach all ears, but use this power wisely."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/adventurer/herald
	traits_applied = list(TRAIT_NOBLE)
	category_tags = list(CTAG_TOWNER)

/mob/living/carbon/human/var/last_herald_announce = 0

/mob/living/carbon/human/proc/heraldannouncement()
	set name = "Announcement"
	set category = "Herald"
	if(stat)
		return
	var/inputty = input("Make an announcement", "Herald's Call") as text|null
	if(inputty)
		if(world.time < last_herald_announce + 600 SECONDS)
			to_chat(src, span_warning("You must wait [round((last_herald_announce + 600 SECONDS - world.time)/600, 0.1)] minutes before making another announcement!"))
			return FALSE
		priority_announce("[inputty]", "The Herald Proclaims", 'sound/misc/bell.ogg')
		last_herald_announce = world.time

/datum/outfit/job/roguetown/adventurer/herald/pre_equip(mob/living/carbon/human/H)
	..()
	H.verbs += /mob/living/carbon/human/proc/heraldannouncement
	H.mind.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
	
	head = /obj/item/clothing/head/roguetown/bardhat
	shoes = /obj/item/clothing/shoes/roguetown/boots
	pants = /obj/item/clothing/under/roguetown/tights/random
	shirt = /obj/item/clothing/suit/roguetown/shirt/shortshirt
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	belt = /obj/item/storage/belt/rogue/leather
	armor = /obj/item/clothing/suit/roguetown/armor/leather/vest
	cloak = /obj/item/clothing/cloak/raincloak/blue
	if(prob(50))
		cloak = /obj/item/clothing/cloak/raincloak/red
	backl = /obj/item/storage/backpack/rogue/satchel
	beltl = /obj/item/storage/belt/rogue/pouch/coins/poor
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/message)
	
	
	H.change_stat("constitution", -1)
	H.change_stat("speed", -4)

/datum/action/innate/crier
	name = "Crier Tab"
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "voice"
	var/last_announcement = 0
	var/announcement_cooldown = 600 SECONDS // 10 minutes

/datum/action/innate/crier/Trigger()
	if(!target)
		return
	var/mob/living/carbon/human/H = target
	if(!H)
		return
	if(!H.canUseTopic(H, BE_CLOSE, FALSE, NO_TK))
		return

	var/dat = ""
	dat += "<center><B>Herald's Crier Powers</B></center><BR>"
	dat += "<BR>"
	if(world.time < last_announcement + announcement_cooldown)
		dat += "Time until next announcement: [round((last_announcement + announcement_cooldown - world.time)/600, 0.1)] minutes<BR>"
	else
		dat += "<A href='?src=[REF(src)];announce=1'>Make Announcement</A><BR>"

	var/datum/browser/popup = new(H, "crierpower", "Crier Powers", 300, 400)
	popup.set_content(dat)
	popup.set_title_image(H.browse_rsc_icon(button_icon, button_icon_state))
	popup.open(FALSE)

/datum/action/innate/crier/Topic(href, href_list)
	var/mob/living/carbon/human/H = target
	if(!H.canUseTopic(src, BE_CLOSE))
		return

	if(href_list["announce"])
		if(world.time < last_announcement + announcement_cooldown)
			to_chat(H, span_warning("You must wait before making another announcement!"))
			return
			
		var/message = stripped_input(H, "What would you like to announce?", "Herald's Call")
		if(!message)
			return
			
		last_announcement = world.time
		H.say("HEAR YE, HEAR YE! [message]", forced = "herald announcement")
		playsound(H, 'sound/misc/bell.ogg', 50, FALSE)
	
	Trigger() // Refresh the interface
