/obj/item/reagent_containers/lux
	name = "lux"
	desc = "Lux is believed to be a vital essence of the soul, a fragment that can be extracted from a living donor through advanced surgical techniques pioneered by necromantic scholars. This extraction has opened new avenues in medical and arcane practices, most notably the revival of the deceased.\
	However, the Church of Psydon condemns the extraction and use of lux as heretical. According to their doctrine, the act of removing lux defiles the soul, rendering it unworthy of the afterlife. They assert that individuals who have undergone lux extraction will be barred from greeting Psydon after death.\
	Furthermore, they claim that those revived through this method will suffer eternal torment unless they end their own lives immediately to return to Psydon.\
	the Disciples of Zizo advocate for the safety and harmlessness of lux extraction. They argue that the procedure is benign, with individuals typically recovering within a few days, with no real downsides."
	icon = 'icons/roguetown/items/produce.dmi'
	icon_state = "lux"
	item_state = "lux"
	possible_transfer_amounts = list()
	volume = 15
	list_reagents = list(/datum/reagent/vitae = 5)
	grind_results = list(/datum/reagent/vitae = 5)
	sellprice = 500

/datum/reagent/vitae
	name = "Vitae"
	description = "The extracted and processed essence of life."
	color = "#7d8e98" // rgb: 96, 165, 132
	overdose_threshold = 10
	metabolization_rate = 0.1

/datum/reagent/vitae/overdose_process(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_HEART, 0.25*REM)
	M.adjustFireLoss(0.25*REM, 0)
	..()
	. = 1

/datum/reagent/vitae/on_mob_life(mob/living/carbon/M)
	if(M.has_flaw(/datum/charflaw/addiction/junkie))
		M.sate_addiction()
	M.apply_status_effect(/datum/status_effect/buff/vitae)
	..()
