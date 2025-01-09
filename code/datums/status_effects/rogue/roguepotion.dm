/datum/status_effect/potion
	status_type = STATUS_EFFECT_UNIQUE
	duration = -1
	var/effect_quality = 1 // The alchemist's skill. Shouldn't be modified, use this for improving an effects quality based on reagent quality.

/datum/status_effect/potion/on_creation(mob/living/new_owner, quality)
	effect_quality = quality
	return ..()

/datum/status_effect/potion/high_jump
	id = "High Jumper"
	alert_type = /atom/movable/screen/alert/status_effect/buff/high_jump

/atom/movable/screen/alert/status_effect/buff/high_jump
	name = "High Jumper"
	desc = "Your legs feel powerful."
	icon_state = "buff"

/datum/status_effect/potion/high_jump/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_ZJUMP, "[type]")

/datum/status_effect/potion/high_jump/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_ZJUMP, "[type]")

/datum/status_effect/potion/penis
	id = "Vigor"
	alert_type = /atom/movable/screen/alert/status_effect/buff/penis
	var/old_size
	var/obj/item/organ/penis/genital

/datum/status_effect/potion/penis/on_apply()
	. = ..()
	genital = owner.getorganslot(ORGAN_SLOT_PENIS)
	if(genital)
		old_size = genital.penis_size
		genital.penis_size += (effect_quality)


/datum/status_effect/potion/penis/on_remove()
	. = ..()
	genital.penis_size = old_size

/atom/movable/screen/alert/status_effect/buff/penis
	name = "Vigor"
	desc = "You feel vigorous."
	icon_state = "buff"