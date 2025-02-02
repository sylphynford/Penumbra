/mob/living/carbon/human/species/gnome
	race = /datum/species/gnome

/datum/species/gnome
	name = "Gnome"
	id = "gnome"
	max_age = 200
	languages = list(
		/datum/language/common,
		/datum/language/elvish
	)

/datum/species/gnome/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/species/gnome/after_creation(mob/living/carbon/C)
	..()
	to_chat(C, "<span class='info'>I can speak Elfish with ,e before my speech.</span>")

/datum/species/gnome/on_species_loss(mob/living/carbon/C)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_SAY)

/datum/species/gnome/qualifies_for_rank(rank, list/features)
	return TRUE

/datum/species/gnome/get_skin_list()
	return sortList(list(
	"skin1" = "ffe0d1",
	"skin2" = "fcccb3"
	))

/datum/species/gnome/get_hairc_list()
	return sortList(list(
	"black - nightsky" = "0a0707",
	"brown - treebark" = "362e25",
	"blonde - moonlight" = "dfc999",
	"red - autumn" = "a34332"
	))

