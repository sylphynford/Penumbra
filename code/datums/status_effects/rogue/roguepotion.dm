/datum/status_effect/potion
	status_type = STATUS_EFFECT_UNIQUE
	duration = -1
	var/effect_quality // The alchemist's skill. Shouldn't be modified, use this for improving an effects quality based on reagent quality.

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
