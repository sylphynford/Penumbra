/datum/status_effect/potion
	status_type = STATUS_EFFECT_UNIQUE
	var/effect_quality

/datum/status_effect/potion/high_jump
	id = "High Jumper"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/hungryt1

/datum/status_effect/potion/high_jump/on_apply()
	. = ..()
	ADD_TRAIT(M, TRAIT_ZJUMP, "[type]")

/datum/status_effect/potion/high_jump/on_remove()
	. = ..()
	REMOVE_TRAIT(M, TRAIT_ZJUMP, "[type]")
