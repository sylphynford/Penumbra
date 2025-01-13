#define COMSIG_MOB_ATTACK "mob_attack"
#define COMSIG_MOB_SAY "mob_say"
#define COMSIG_MOB_CLICKON "mob_clickon"
#define COMSIG_ITEM_PRE_UNEQUIP "item_pre_unequip"
#define COMPONENT_CANCEL_ATTACK "cancel_attack"
#define COMPONENT_CANCEL_SAY "cancel_say"
#define COMPONENT_ITEM_BLOCK_UNEQUIP (1<<0)

/obj/item/clothing/neck/roguetown
	name = "necklace"
	desc = ""
	icon = 'icons/roguetown/clothing/neck.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/neck.dmi'
	bloody_icon_state = "bodyblood"

/obj/item/clothing/neck/roguetown/coif
	name = "coif"
	icon_state = "coif"
	item_state = "coif"
	flags_inv = HIDEHAIR
	slot_flags = ITEM_SLOT_NECK|ITEM_SLOT_HEAD
	blocksound = SOFTHIT
	body_parts_covered = NECK|HAIR|EARS|HEAD
	armor = list("blunt" = 33, "slash" = 12, "stab" = 22, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	prevent_crits = list(BCLASS_CUT, BCLASS_BLUNT)
	adjustable = CAN_CADJUST
	toggle_icon_state = TRUE
	sewrepair = TRUE

/obj/item/clothing/neck/roguetown/coif/AdjustClothes(mob/user)
	if(loc == user)
		if(adjustable == CAN_CADJUST)
			adjustable = CADJUSTED
			if(toggle_icon_state)
				icon_state = "[initial(icon_state)]_t"
			flags_inv = null
			body_parts_covered = NECK
			if(ishuman(user))
				var/mob/living/carbon/H = user
				H.update_inv_neck()
				H.update_inv_head()
		else if(adjustable == CADJUSTED)
			ResetAdjust(user)
			flags_inv = HIDEHAIR
			if(user)
				if(ishuman(user))
					var/mob/living/carbon/H = user
					H.update_inv_neck()
					H.update_inv_head()



/obj/item/clothing/neck/roguetown/chaincoif
	name = "chain coif"
	icon_state = "chaincoif"
	item_state = "chaincoif"
	flags_inv = HIDEHAIR
	armor = list("blunt" = 30, "slash" = 60, "stab" = 45, "bullet" = 10, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

	max_integrity = 200
	resistance_flags = FIRE_PROOF
	slot_flags = ITEM_SLOT_NECK|ITEM_SLOT_HEAD
	body_parts_covered = NECK|HAIR|EARS|HEAD
	prevent_crits = list(BCLASS_CUT, BCLASS_STAB, BCLASS_CHOP, BCLASS_BLUNT)
	adjustable = CAN_CADJUST
	toggle_icon_state = TRUE
	blocksound = CHAINHIT
	anvilrepair = /datum/skill/craft/armorsmithing
	smeltresult = /obj/item/ingot/steel

/obj/item/clothing/neck/roguetown/chaincoif/fakegold
	name = "golden chain coif"
	desc = "A normal steel coif painted yellow in an attempt to mimic gold."
	color = COLOR_ASSEMBLY_FAKEGOLD

/obj/item/clothing/neck/roguetown/chaincoif/AdjustClothes(mob/user)
	if(loc == user)
		if(adjustable == CAN_CADJUST)
			adjustable = CADJUSTED
			if(toggle_icon_state)
				icon_state = "[initial(icon_state)]_t"
			flags_inv = null
			body_parts_covered = NECK
			if(ishuman(user))
				var/mob/living/carbon/H = user
				H.update_inv_neck()
				H.update_inv_head()
		else if(adjustable == CADJUSTED)
			ResetAdjust(user)
			flags_inv = HIDEHAIR
			if(user)
				if(ishuman(user))
					var/mob/living/carbon/H = user
					H.update_inv_neck()
					H.update_inv_head()

/obj/item/clothing/neck/roguetown/chaincoif/iron
	name = "iron chain coif"
	icon_state = "ichaincoif"
	anvilrepair = /datum/skill/craft/armorsmithing
	smeltresult = /obj/item/ingot/iron
	max_integrity = 150

/obj/item/clothing/neck/roguetown/chaincoif/full
	name = "full chain coif"
	icon_state = "fchaincoif"
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	resistance_flags = FIRE_PROOF
	body_parts_covered = NECK|MOUTH|NOSE|HAIR|EARS|HEAD
	adjustable = CAN_CADJUST

/obj/item/clothing/neck/roguetown/chaincoif/full/AdjustClothes(mob/user)
	if(loc == user)
		if(adjustable == CAN_CADJUST)
			adjustable = CADJUSTED
			if(toggle_icon_state)
				icon_state = "chaincoif"
			flags_inv = HIDEHAIR
			body_parts_covered = NECK|HAIR|EARS|HEAD
			if(ishuman(user))
				var/mob/living/carbon/H = user
				H.update_inv_neck()
				H.update_inv_head()
		else if(adjustable == CADJUSTED)
			adjustable = CADJUSTED_MORE
			if(toggle_icon_state)
				icon_state = "chaincoif_t"
			flags_inv = null
			body_parts_covered = NECK
			if(ishuman(user))
				var/mob/living/carbon/H = user
				H.update_inv_neck()
				H.update_inv_head()
		else if(adjustable == CADJUSTED_MORE)
			ResetAdjust(user)
		if(ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_neck()
			H.update_inv_head()


/obj/item/clothing/neck/roguetown/bevor
	name = "bevor"
	icon_state = "bevor"
	armor = list("blunt" = 90, "slash" = 100, "stab" = 80, "bullet" = 100, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	anvilrepair = /datum/skill/craft/armorsmithing
	smeltresult = /obj/item/ingot/steel

	max_integrity = 300
	resistance_flags = FIRE_PROOF
	slot_flags = ITEM_SLOT_NECK
	body_parts_covered = NECK|MOUTH|NOSE
	prevent_crits = list(BCLASS_CUT, BCLASS_STAB, BCLASS_CHOP, BCLASS_BLUNT, BCLASS_TWIST)
	blocksound = PLATEHIT

/obj/item/clothing/neck/roguetown/gorget
	name = "gorget"
	icon_state = "gorget"
	armor = list("blunt" = 90, "slash" = 100, "stab" = 80, "bullet" = 100, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	smeltresult = /obj/item/ingot/iron
	anvilrepair = /datum/skill/craft/armorsmithing
	max_integrity = 150
	resistance_flags = FIRE_PROOF
	slot_flags = ITEM_SLOT_NECK
	body_parts_covered = NECK
	prevent_crits = list(BCLASS_CUT, BCLASS_STAB, BCLASS_CHOP, BCLASS_BLUNT, BCLASS_TWIST)
	blocksound = PLATEHIT

/obj/item/clothing/neck/roguetown/fencerguard
	name = "fencer neckguard"
	icon_state = "fencercollar"
	armor = list("blunt" = 90, "slash" = 100, "stab" = 80, "bullet" = 100, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	smeltresult = /obj/item/ingot/iron
	anvilrepair = /datum/skill/craft/armorsmithing
	max_integrity = 150
	resistance_flags = FIRE_PROOF
	slot_flags = ITEM_SLOT_NECK
	body_parts_covered = NECK
	prevent_crits = list(BCLASS_CUT, BCLASS_STAB, BCLASS_CHOP, BCLASS_BLUNT, BCLASS_TWIST)
	blocksound = PLATEHIT
	allowed_race = NON_DWARVEN_RACE_TYPES

/obj/item/clothing/neck/roguetown/gorget/prisoner/Initialize()
	. = ..()
	name = "cursed collar"
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/neck/roguetown/gorget/prisoner/dropped(mob/living/carbon/human/user)
	. = ..()
	if(QDELETED(src))
		return
	qdel(src)

/obj/item/clothing/neck/roguetown/psicross
	name = "psycross"
	desc = ""
	icon_state = "psicross"
	//dropshrink = 0.75
	resistance_flags = FIRE_PROOF
	slot_flags = ITEM_SLOT_NECK|ITEM_SLOT_HIP|ITEM_SLOT_WRISTS
	sellprice = 10
	experimental_onhip = TRUE
	anvilrepair = /datum/skill/craft/armorsmithing

/obj/item/clothing/neck/roguetown/psicross/astrata
	name = "amulet of day"
	desc = ""
	icon_state = "astrata"

/obj/item/clothing/neck/roguetown/psicross/noc
	name = "amulet of night"
	desc = ""
	icon_state = "noc"

/obj/item/clothing/neck/roguetown/psicross/dendor
	name = "amulet of nature"
	desc = ""
	icon_state = "dendor"

/obj/item/clothing/neck/roguetown/psicross/necra
	name = "amulet of death"
	desc = ""
	icon_state = "necra"

/obj/item/clothing/neck/roguetown/psicross/pestra
	name = "amulet of pestilence"
	desc = ""
	icon_state = "pestra"

/obj/item/clothing/neck/roguetown/psicross/ravox
	name = "amulet of war"
	desc = ""
	icon_state = "ravox"

/obj/item/clothing/neck/roguetown/psicross/malum
	name = "amulet of fire"
	desc = ""
	icon_state = "malum"

/obj/item/clothing/neck/roguetown/psicross/eora
	name = "amulet of love"
	desc = ""
	icon_state = "eora"

/obj/item/clothing/neck/roguetown/psicross/wood
	name = "wooden psycross"
	icon_state = "psicrossw"
	sellprice = 0

/obj/item/clothing/neck/roguetown/psicross/silver
	name = "silver psycross"
	icon_state = "psicrosssteel"
	sellprice = 50

/obj/item/clothing/neck/roguetown/psicross/silver/pickup(mob/user)
	. = ..()
	var/mob/living/carbon/human/H = user
	if(!H.mind)
		return
	var/datum/antagonist/vampirelord/V_lord = H.mind.has_antag_datum(/datum/antagonist/vampirelord/)
	var/datum/antagonist/werewolf/W = H.mind.has_antag_datum(/datum/antagonist/werewolf/)
	if(ishuman(H))
		if(H.mind.has_antag_datum(/datum/antagonist/vampirelord/lesser))
			to_chat(H, span_userdanger("I can't pick up the silver, it is my BANE!"))
			H.Knockdown(20)
			H.adjustFireLoss(60)
			H.Paralyze(20)
			H.fire_act(1,5)
		if(V_lord)
			if(V_lord.vamplevel < 4 && !H.mind.has_antag_datum(/datum/antagonist/vampirelord/lesser))
				to_chat(H, span_userdanger("I can't pick up the silver, it is my BANE!"))
				H.Knockdown(10)
				H.Paralyze(10)
		if(W && W.transformed == TRUE)
			to_chat(H, span_userdanger("I can't equip the silver, it is my BANE!"))
			H.Knockdown(20)
			H.Paralyze(20)

/obj/item/clothing/neck/roguetown/psicross/silver/mob_can_equip(mob/living/M, mob/living/equipper, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	. = ..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!H.mind)
			return TRUE
		var/datum/antagonist/vampirelord/V_lord = H.mind.has_antag_datum(/datum/antagonist/vampirelord/)
		var/datum/antagonist/werewolf/W = H.mind.has_antag_datum(/datum/antagonist/werewolf/)
		if(H.mind.has_antag_datum(/datum/antagonist/vampirelord/lesser))
			to_chat(H, span_userdanger("I can't equip the silver, it is my BANE!"))
			H.Knockdown(20)
			H.adjustFireLoss(60)
			H.Paralyze(20)
			H.fire_act(1,5)
		if(V_lord)
			if(V_lord.vamplevel < 4 && !H.mind.has_antag_datum(/datum/antagonist/vampirelord/lesser))
				to_chat(H, span_userdanger("I can't equip the silver, it is my BANE!"))
				H.Knockdown(10)
				H.Paralyze(10)
		if(W && W.transformed == TRUE)
			to_chat(H, span_userdanger("I can't equip the silver, it is my BANE!"))
			H.Knockdown(20)
			H.Paralyze(20)

/obj/item/clothing/neck/roguetown/psicross/g
	name = "golden psycross"
	desc = ""
	icon_state = "psicrossg"
	//dropshrink = 0.75
	resistance_flags = FIRE_PROOF
	sellprice = 100

/obj/item/clothing/neck/roguetown/talkstone
	name = "talkstone"
	desc = ""
	icon_state = "talkstone"
	item_state = "talkstone"
	//dropshrink = 0.75
	resistance_flags = FIRE_PROOF
	allowed_race = CLOTHED_RACES_TYPES
	sellprice = 98
	anvilrepair = /datum/skill/craft/armorsmithing

/obj/item/clothing/neck/roguetown/horus
	name = "eye of horuz"
	desc = ""
	icon_state = "horus"
	//dropshrink = 0.75
	resistance_flags = FIRE_PROOF
	sellprice = 30
	anvilrepair = /datum/skill/craft/armorsmithing

/obj/item/clothing/neck/roguetown/shalal
	name = "desert rider medal"
	desc = ""
	icon_state = "shalal"
	//dropshrink = 0.75
	resistance_flags = FIRE_PROOF
	sellprice = 15
	anvilrepair = /datum/skill/craft/armorsmithing

/obj/item/clothing/neck/roguetown/ornateamulet
	name = "Ornate Amulet"
	desc = "A beautiful amulet, made of solid gold."
	icon_state = "ornateamulet"
	//dropshrink = 0.75
	resistance_flags = FIRE_PROOF
	sellprice = 100
	anvilrepair = /datum/skill/craft/armorsmithing

/obj/item/clothing/neck/roguetown/skullamulet
	name = "Skull Amulet"
	desc = "Gold shaped into the form of a skull, made into an amulet."
	icon_state = "skullamulet"
	//dropshrink = 0.75
	resistance_flags = FIRE_PROOF
	sellprice = 100
	anvilrepair = /datum/skill/craft/armorsmithing

/obj/item/clothing/neck/roguetown/cursed_collar
	name = "cursed collar"
	desc = "A sinister looking collar with emerald studs. It seems to radiate a dark energy."
	icon_state = "listenstone"
	item_state = "listenstone"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_NECK
	body_parts_covered = NECK
	var/mob/living/carbon/human/victim = null
	var/mob/living/carbon/human/collar_master = null
	var/listening = FALSE
	var/silenced = FALSE
	resistance_flags = INDESTRUCTIBLE
	armor = list("blunt" = 0, "slash" = 0, "stab" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

/obj/item/clothing/neck/roguetown/cursed_collar/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	if(silenced)
		speech_args[SPEECH_MESSAGE] = ""
		var/mob/living/carbon/human/H = source
		if(istype(H))
			H.say("*[pick(list(
				"whines softly.",
				"makes a pitiful noise.",
				"whimpers.",
				"lets out a submissive bark.",
				"mewls pathetically."
			))]")
		return COMPONENT_CANCEL_SAY
	return NONE

/obj/item/clothing/neck/roguetown/cursed_collar/proc/check_attack(datum/source, atom/target)
	SIGNAL_HANDLER
	if(!istype(target, /mob/living/carbon/human))
		return NONE
	
	if(target == collar_master)
		to_chat(source, span_warning("The collar sends painful shocks through your body as you try to attack your master!"))
		var/mob/living/carbon/human/H = source
		H.electrocute_act(25, src, flags = SHOCK_NOGLOVES)
		H.Paralyze(600) // 1 minute stun
		playsound(H, 'sound/blank.ogg', 50, TRUE)
		return COMPONENT_CANCEL_ATTACK
	return NONE

/obj/item/clothing/neck/roguetown/cursed_collar/attack(mob/living/carbon/human/M, mob/living/carbon/human/user)
	if(!istype(M) || !istype(user))
		return ..()
	
	if(M.get_item_by_slot(SLOT_NECK))
		to_chat(user, span_warning("[M] is already wearing something around their neck!"))
		return
	
	if(!do_mob(user, M, 50))
		return
	
	victim = M
	collar_master = user
	if(!M.equip_to_slot_if_possible(src, SLOT_NECK, 0, 0, 1))
		to_chat(user, span_warning("You fail to collar [M]!"))
		victim = null
		collar_master = null
		return
	
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)
	to_chat(M, span_userdanger("The collar snaps shut around your neck!"))
	to_chat(user, span_notice("You successfully collar [M]."))
	
	var/datum/antagonist/collar_master/CM = new
	CM.my_collar = src
	user.mind.add_antag_datum(CM)

/obj/item/clothing/neck/roguetown/cursed_collar/Destroy()
	victim = null
	collar_master = null
	return ..()

/obj/item/clothing/neck/roguetown/cursed_collar/equipped(mob/user, slot)
	. = ..()
	if(slot == SLOT_NECK && user == victim)
		RegisterSignal(src, COMSIG_ITEM_PRE_UNEQUIP, PROC_REF(prevent_removal))
		RegisterSignal(user, COMSIG_MOB_SAY, PROC_REF(handle_speech))
		RegisterSignal(user, COMSIG_MOB_CLICKON, PROC_REF(check_attack))

/obj/item/clothing/neck/roguetown/cursed_collar/proc/prevent_removal(datum/source, mob/living/carbon/human/user)
	SIGNAL_HANDLER
	if(user == victim)
		to_chat(user, span_userdanger("The collar's magic holds it firmly in place! You can't remove it!"))
		playsound(user, 'sound/blank.ogg', 50, TRUE)
		return COMPONENT_ITEM_BLOCK_UNEQUIP
	return NONE
