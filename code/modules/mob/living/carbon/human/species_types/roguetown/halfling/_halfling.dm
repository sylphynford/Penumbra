/mob/living/carbon/human/species/halfling
	race = /datum/species/halfling

/datum/species/halfling
	name = "Halfling"
	id = "halfling"
	//languages = list(
	//	/datum/language/common
	//)

/datum/species/halfling/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))
/*
/datum/species/halfling/after_creation(mob/living/carbon/C)
	..()
	to_chat(C, "<span class='info'>I can speak Dwarfish with ,d before my speech.</span>")
*/
/datum/species/halfling/on_species_loss(mob/living/carbon/C)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_SAY)

/datum/species/halfling/qualifies_for_rank(rank, list/features)
	return TRUE

/datum/species/halfling/get_skin_list()
	return sortList(list(
	"skin1" = "ffe0d1",
	"skin2" = "fcccb3"
	))

/datum/species/halfling/get_hairc_list()
	return sortList(list(
	"black - nightsky" = "0a0707",
	"brown - treebark" = "362e25",
	"blonde - moonlight" = "dfc999",
	"red - autumn" = "a34332"
	))

