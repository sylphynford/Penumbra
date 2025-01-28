/datum/reagent/medicine/healthpot
	name = "Dated Health Potion"
	description = "Gradually regenerates all types of damage, is past it's shelf-life."
	reagent_state = LIQUID
	color = "#A20000"
	taste_description = "red"
	overdose_threshold = 45
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	alpha = 173
	value = 0.5 // 23. Oz is bigger than volume.

/datum/reagent/medicine/healthpot/on_mob_life(mob/living/carbon/M)
	if(volume >= 60)
		M.reagents.remove_reagent(/datum/reagent/medicine/healthpot, 2) //No overhealing.
	var/list/wCount = M.get_wounds()
	if(M.blood_volume < BLOOD_VOLUME_NORMAL)
		M.blood_volume = min(M.blood_volume+50, BLOOD_VOLUME_MAXIMUM)
	else
		//can overfill you with blood, but at a slower rate
		M.blood_volume = min(M.blood_volume+10, BLOOD_VOLUME_MAXIMUM)
	if(wCount.len > 0)
		//some peeps dislike the church, this allows an alternative thats not a doctor or sleep.
		M.heal_wounds(3) //at a motabalism of .5 U a tick this translates to 120WHP healing with 20 U Most wounds are unsewn 15-100. This is powerful on single wounds but rapidly weakens at multi wounds.
		M.update_damage_overlays()
	M.adjustBruteLoss(-0.7*REM, 0)
	M.adjustFireLoss(-0.7*REM, 0)
	M.adjustOxyLoss(-0.7, 0)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, -0.7*REM)
	M.adjustCloneLoss(-0.7*REM, 0)
	..()
	. = 1

/datum/reagent/medicine/healthpot/overdose_start(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!istype(H.dna.species, /datum/species/werewolf))
			H.playsound_local(H, 'sound/misc/heroin_rush.ogg', 100, FALSE)
			H.visible_message(span_warning("Blood runs from [H]'s nose."))
	. = 1

/datum/reagent/medicine/healthpot/overdose_process(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!istype(H.dna.species, /datum/species/werewolf))
			M.adjustToxLoss(2, 0)
	..()
	. = 1

/datum/reagent/medicine/healthpotnew
	name = "Health Potion"
	description = "Gradually regenerates all types of damage."
	reagent_state = LIQUID
	color = "#ff0000"
	taste_description = "red"
	overdose_threshold = 45
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	alpha = 173
	value = 1 // 45

/datum/reagent/medicine/healthpotnew/on_mob_life(mob/living/carbon/M)
	M.reagents.remove_reagent(/datum/reagent/medicine/healthpot, 100) //removes old health pot so you can't double-up
	if(volume >= 60)
		M.reagents.remove_reagent(/datum/reagent/medicine/healthpotnew, 2) //No overhealing.
	var/list/wCount = M.get_wounds()
	if(M.blood_volume < BLOOD_VOLUME_NORMAL)
		M.blood_volume = min(M.blood_volume+50, BLOOD_VOLUME_MAXIMUM)
	else
		//can overfill you with blood, but at a slower rate
		M.blood_volume = min(M.blood_volume+10, BLOOD_VOLUME_MAXIMUM)
	if(wCount.len > 0)
		//some peeps dislike the church, this allows an alternative thats not a doctor or sleep.
		for(var/datum/wound/W in wCount)
			if(!istype(W, /datum/wound/fracture)) // Skip fractures
				W.heal_wound(3) // Heal non-fracture wounds
		M.update_damage_overlays()
	M.adjustBruteLoss(-1.4*REM, 0)
	M.adjustFireLoss(-1.4*REM, 0)
	M.adjustOxyLoss(-1.4, 0)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, -1.4*REM)
	M.adjustCloneLoss(-1.4*REM, 0)
	..()
	. = 1

/datum/reagent/medicine/healthpotnew/overdose_start(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!istype(H.dna.species, /datum/species/werewolf))
			H.playsound_local(H, 'sound/misc/heroin_rush.ogg', 100, FALSE)
			H.visible_message(span_warning("Blood runs from [H]'s nose."))
	. = 1

/datum/reagent/medicine/healthpotnew/overdose_process(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!istype(H.dna.species, /datum/species/werewolf))
			M.adjustToxLoss(2, 0)
	..()
	. = 1

/datum/reagent/medicine/manapot
	name = "Mana Potion"
	description = "Gradually regenerates stamina."
	reagent_state = LIQUID
	color = "#0000ff"
	taste_description = "manna"
	overdose_threshold = 45
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	alpha = 173
	value = 0.5 // 23

/datum/reagent/medicine/manapot/on_mob_life(mob/living/carbon/M)
	M.rogstam_add(10)
	..()
	. = 1

/datum/reagent/medicine/manapot/overdose_start(mob/living/M)
	M.playsound_local(M, 'sound/misc/heroin_rush.ogg', 100, FALSE)
	M.visible_message(span_warning("Blood runs from [M]'s nose."))
	. = 1

/datum/reagent/medicine/manapot/overdose_process(mob/living/M)
	M.adjustToxLoss(3, 0)
	..()
	. = 1

/datum/reagent/berrypoison
	name = "Berry Poison"
	description = "Contains a poisonous thick, dark purple liquid."
	reagent_state = LIQUID
	color = "#00B4FF"
	metabolization_rate = 0.1

/datum/reagent/berrypoison/on_mob_life(mob/living/carbon/M)
	if(!HAS_TRAIT(M, TRAIT_NASTY_EATER))
		M.add_nausea(9)
		M.adjustToxLoss(3, 0)
	return ..()

/datum/reagent/organpoison
	name = "Organ Poison"
	description = "A viscous black liquid clings to the glass."
	reagent_state = LIQUID
	color = "#ff2f00"
	metabolization_rate = 0.1

/datum/reagent/organpoison/on_mob_life(mob/living/carbon/M)
	if(!HAS_TRAIT(M, TRAIT_NASTY_EATER) && !HAS_TRAIT(M, TRAIT_ORGAN_EATER))
		M.add_nausea(9)
		M.adjustToxLoss(3, 0)
	return ..()

//pyro flower nectar - stonekeep port
/datum/reagent/toxin/fyritiusnectar
	name = "fyritius nectar"
	description = "oh no"
	reagent_state = LIQUID
	color = "#ffc400"
	metabolization_rate = 0.5

/datum/reagent/toxin/fyritiusnectar/on_mob_life(mob/living/carbon/M)
	if(volume > 0.99)
		M.add_nausea(9)
		M.adjustFireLoss(2, 0)
		M.adjust_fire_stacks(1)
		M.IgniteMob()
	return ..()

/datum/reagent/infection
	name = "excess choleric humour"
	description = "Red-yellow pustulence - the carrier of disease, the enemy of all Pestrans."
	reagent_state = LIQUID
	color = "#dfe36f"
	metabolization_rate = 0.1
	var/damage_tick = 0.3
	var/lethal_fever = FALSE
	var/fever_multiplier = 1

/datum/reagent/infection/on_mob_life(mob/living/carbon/M)
	var/heat = (BODYTEMP_AUTORECOVERY_MINIMUM + clamp(volume, 3, 15)) * fever_multiplier
	M.adjustToxLoss(damage_tick, 0)
	if (lethal_fever)
		M.adjust_bodytemperature(heat, 0)
		if (prob(5))
			to_chat(M, span_warning("A wicked heat settles within me... I feel ill. Very ill."))
	else
		M.adjust_bodytemperature(heat, 0, BODYTEMP_HEAT_DAMAGE_LIMIT - 1)
		if (prob(5))
			to_chat(M, span_warning("I feel a horrible chill despite the sweat rolling from my brow..."))
	return ..()

/datum/reagent/infection/minor
	name = "disrupted choleric humor"
	description = "Symptomatic of disrupted humours."
	damage_tick = 0.1
	lethal_fever = FALSE

/datum/reagent/infection/major
	name = "excess melancholic humour"
	description = "Kingsfield's Bane. Excess melancholic has killed thousands, and even Pestra's greatest struggle against its insidious advance."
	damage_tick = 1
	lethal_fever = TRUE
	fever_multiplier = 3

/datum/reagent/infection/major/on_mob_life(mob/living/carbon/M)
	if (M.badluck(1))
		M.reagents.add_reagent(src, rand(1,3))
		to_chat(M, span_small("I feel even worse..."))
	return ..()

// Applies a status effect that expires when the reagent is done metabolizing.
// Quality is currently only set by mortar.
/datum/reagent/potion
	name = "Generic Potion"
	description = "You shouldn't be seeing this."
	reagent_state = LIQUID
	color = "#f2eb22"
	metabolization_rate = 0.7 // Default yield for potions is usually 45, this is how many units are metabolized per second.
	var/min_volume // How much volume is needed for this potion to work.
	var/effect_type // What effect is given when metabolized?

	var/quality = 1
	var/datum/status_effect/potion/status

/datum/reagent/potion/on_mob_end_metabolize(mob/living/M)
	qdel(status)
	return ..()

/datum/reagent/potion/on_mob_life(mob/living/carbon/M)
	if(!status && volume >= min_volume)
		status = M.apply_status_effect(effect_type, quality)
	return ..()

/datum/reagent/potion/on_new(list/data)
	. = ..()
	if(!data)
		return
	quality = data["quality"]

/datum/reagent/potion/high_jump
	name = "Jump Potion"
	description = "A yellow fluid. When consumed it lets the drinker jump higher."
	reagent_state = LIQUID
	color = "#f2eb22"
	metabolization_rate = 0.7
	min_volume = 5
	effect_type = /datum/status_effect/potion/high_jump

/datum/reagent/potion/penis
	name = "Bone Potion"
	description = "A white fluid. A popular concotion used to make bones larger."
	reagent_state = LIQUID
	color = "#ededeb"
	metabolization_rate = 0.3
	min_volume = 15
	effect_type = /datum/status_effect/potion/penis

/datum/reagent/potion/penis/on_mob_life(mob/living/carbon/M)
	if(!status && volume >= min_volume && M.getorganslot(ORGAN_SLOT_PENIS))
		status = M.apply_status_effect(effect_type, quality)
	return ..()
