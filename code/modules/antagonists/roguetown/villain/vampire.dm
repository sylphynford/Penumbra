#ifdef TESTSERVER
/mob/living/carbon/human/verb/become_vampire()
	set category = "DEBUGTEST"
	set name = "VAMPIRETEST"
	if(mind)
		var/datum/antagonist/vampire/new_antag = new /datum/antagonist/vampire()
		mind.add_antag_datum(new_antag)
#endif

/datum/antagonist/vampire
	name = "Vampire"
	roundend_category = "Vampires"
	antagpanel_category = "Vampire"
	job_rank = ROLE_VAMPIRE
	antag_hud_type = ANTAG_HUD_TRAITOR
	antag_hud_name = "vampire"
	confess_lines = list(
		"I WANT YOUR BLOOD!",
		"DRINK THE BLOOD!",
		"CHILD OF KAIN!",
	)
	rogue_enabled = TRUE
	var/disguised = TRUE //just when the vamps eyes go red
	var/exposed = FALSE //vamp got burnt and revealed
	var/low_vitae = FALSE //vitae too low to disguise self
	var/vitae = 1000
	var/last_transform = 0
	var/is_lesser = FALSE
	var/cache_skin
	//got a lot of shit to cache
	var/cache_pigment
	var/cache_mcolor
	var/cache_mcolor2
	var/cache_mcolor3
	var/cache_ear_color
	var/cache_tail_color
	var/cache_tail_feature_color
	var/cache_frill_color
	var/cache_snout_color
	var/list/cache_chest_marking_color
	var/cache_eye_color
	var/cache_second_color
	var/cache_hair
	var/cache_facial
	var/cache_hair_nat
	var/cache_facial_nat
	var/starved = FALSE
	var/obj/effect/proc_holder/spell/targeted/shapeshift/bat/batform //attached to the datum itself to avoid cloning memes, and other duplicates

/datum/antagonist/vampire/proc/handle_vitae(change)
	var/tempcurrent = vitae
	if(change > 0)
		tempcurrent += change
		if(tempcurrent > 1666)
			tempcurrent = 1666 // to prevent overflow
	if(change < 0)
		tempcurrent += change
		if(tempcurrent < 0)
			tempcurrent = 0 // to prevent excessive negative
	vitae = tempcurrent
	if(vitae <= 20)
		if(!starved)
			to_chat(owner, span_userdanger("I starve, my power dwindles! I am so weak!"))
			starved = TRUE
			for(var/S in MOBSTATS)
				owner.current.change_stat(S, -5)
	else
		if(starved)
			starved = FALSE
			for(var/S in MOBSTATS)
				owner.current.change_stat(S, 5)

/datum/antagonist/vampire/examine_friendorfoe(datum/antagonist/examined_datum,mob/examiner,mob/examined)
	if(istype(examined_datum, /datum/antagonist/vampire/lesser))
		return span_boldnotice("A child of Kain.")
	if(istype(examined_datum, /datum/antagonist/vampire))
		return span_boldnotice("An elder Kin.")
	if(examiner.Adjacent(examined))
		if(istype(examined_datum, /datum/antagonist/werewolf/lesser))
			if(!disguised)
				return span_boldwarning("I sense a lesser Werewolf.")
		if(istype(examined_datum, /datum/antagonist/werewolf))
			if(!disguised)
				return span_boldwarning("THIS IS AN ELDER WEREWOLF! MY ENEMY!")
	if(istype(examined_datum, /datum/antagonist/zombie))
		return span_boldnotice("Another deadite.")
	if(istype(examined_datum, /datum/antagonist/skeleton))
		return span_boldnotice("Another deadite.")

/datum/antagonist/vampire/lesser //le shitcode faec
	name = "Lesser Vampire"
	is_lesser = TRUE
	increase_votepwr = FALSE

/datum/antagonist/vampire/lesser/roundend_report()
	return

/datum/antagonist/vampire/on_gain()
	if(!is_lesser)
		owner.adjust_skillrank(/datum/skill/combat/wrestling, 6, TRUE)
		owner.adjust_skillrank(/datum/skill/combat/unarmed, 6, TRUE)
		ADD_TRAIT(owner.current, TRAIT_NOBLE, TRAIT_GENERIC)
	owner.special_role = name
	ADD_TRAIT(owner.current, TRAIT_STRONGBITE, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_NOHUNGER, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_NOPAIN, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_TOXIMMUNE, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_STEELHEARTED, TRAIT_GENERIC)
	owner.current.cmode_music = 'sound/music/combat_vamp2.ogg'
	
	// Store original appearance before changes
	var/mob/living/carbon/human/H = owner.current
	if(istype(H))
		var/obj/item/organ/eyes/E = H.getorganslot(ORGAN_SLOT_EYES)
		if(E)
			cache_eye_color = E.eye_color
			cache_second_color = E.second_color
			message_admins("DEBUG: Base vampire on_gain() - Caching eye color from eyes organ: [cache_eye_color] [cache_second_color]")
		cache_skin = H.skin_tone
		var/datum/bodypart_feature/hair/head/Hair = H.get_bodypart_feature_of_slot(BODYPART_FEATURE_HAIR)
		if (Hair)
			cache_hair = Hair.accessory_colors
			cache_hair_nat = Hair.natural_color
		var/datum/bodypart_feature/hair/facial/Facial = H.get_bodypart_feature_of_slot(BODYPART_FEATURE_FACIAL_HAIR)
		if (Facial)
			cache_facial = Facial.accessory_colors
			cache_facial_nat = Facial.natural_color
		if (MUTCOLORS in H.dna.species.species_traits)
			cache_snout_color = H.get_organ_slot_color(ORGAN_SLOT_SNOUT)
			cache_frill_color = H.get_organ_slot_color(ORGAN_SLOT_FRILLS)
			cache_tail_feature_color = H.get_organ_slot_color(ORGAN_SLOT_TAIL_FEATURE)
			cache_chest_marking_color = H.get_chest_scales()
		if (H.dna)
			cache_mcolor = H.dna.features["mcolor"]
			cache_mcolor2 = H.dna.features["mcolor2"]
			cache_mcolor3 = H.dna.features["mcolor3"]
		cache_tail_color = H.get_organ_slot_color(ORGAN_SLOT_TAIL)
		cache_pigment = H.get_organ_slot_color(ORGAN_SLOT_PENIS) //hold on man gotta make sure the tiefling dicks are the right color
		cache_ear_color = H.get_organ_slot_color(ORGAN_SLOT_EARS)
	
	if(increase_votepwr)
		forge_vampire_objectives()
	finalize_vampire()

	// Basic vampire abilities
	owner.current.verbs |= /mob/living/carbon/human/proc/disguise_button
	owner.current.verbs |= /mob/living/carbon/human/proc/vamp_regenerate

	// Only vampire lords get these abilities
	if(owner.has_antag_datum(/datum/antagonist/vampirelord))
		owner.current.verbs |= /mob/living/carbon/human/proc/blood_strength
		owner.current.verbs |= /mob/living/carbon/human/proc/blood_celerity
		owner.current.verbs |= /mob/living/carbon/human/proc/blood_fortitude

	return ..()

/datum/antagonist/vampire/on_removal()
	if(!silent && owner.current)
		to_chat(owner.current,span_danger("I am no longer a [job_rank]!"))
	owner.special_role = null
	if(!isnull(batform))
		owner.current.RemoveSpell(batform)
		QDEL_NULL(batform)
	return ..()

/datum/antagonist/vampire/proc/add_objective(datum/objective/O)
	objectives += O

/datum/antagonist/vampire/proc/remove_objective(datum/objective/O)
	objectives -= O

/datum/antagonist/vampire/proc/forge_vampire_objectives()
	if(!(locate(/datum/objective/escape) in objectives))
		var/datum/objective/vampire/escape_objective = new
		escape_objective.owner = owner
		add_objective(escape_objective)
		return

/datum/antagonist/vampire/greet()
	to_chat(owner.current, span_userdanger("Ever since that bite, I have been a VAMPIRE."))
	owner.announce_objectives()
	..()

/datum/antagonist/vampire/proc/finalize_vampire()
	owner.current.playsound_local(get_turf(owner.current), 'sound/music/vampintro.ogg', 80, FALSE, pressure_affected = FALSE)



/datum/antagonist/vampire/proc/recover(mob/user)
	var/mob/living/carbon/human/H = user
	if (!H)
		return
	if(H.stat == DEAD)
		return
	to_chat(H, span_warning("I can once more assume a human visage."))
	exposed= FALSE

/datum/antagonist/vampire/on_life(mob/user)
	if(!user)
		return
	var/mob/living/carbon/human/H = user
	if(H.stat == DEAD)
		return
	if(H.advsetup)
		return

	// Add burn damage check
	if(H.getFireLoss() >= 150)
		to_chat(H, span_userdanger("The flames consume me completely!"))
		H.visible_message(span_warning("[H] crumbles to ash!"))
		H.dust(TRUE, FALSE, TRUE) // Force dusting, no gibbing, leave items
		return

	if(H.on_fire)
		if (!exposed)
			to_chat(H, span_notice("I cannot maintain my human visage!"))
			H.vampire_undisguise(src)
			exposed = TRUE
			if(disguised)
				to_chat(H, span_notice("My disguise fails!"))
		addtimer(CALLBACK(src, PROC_REF(recover), user), 30 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)
		//last_transform = world.time
		H.freak_out()

	if(H.stat)
		if(istype(H.loc, /obj/structure/closet/crate/coffin))
			H.fully_heal()

	vitae = CLAMP(vitae, 0, 1666)

	if(vitae >= 0)
		if (vitae > 0)
			H.blood_volume = BLOOD_VOLUME_NORMAL
		if(vitae < 200)
			if (!low_vitae)
				to_chat(H, span_notice("My vitae reserves are depleted. I cannot maintain my human visage!"))
				low_vitae = TRUE
				if(disguised)
					to_chat(H, span_notice("My disguise fails!"))
				H.vampire_undisguise(src)
		else
			low_vitae = FALSE

/mob/living/carbon/human/proc/disguise_button()
	set name = "Toggle Disguise"
	set category = "VAMPIRE"
	
	var/datum/antagonist/vampire/V = mind.has_antag_datum(/datum/antagonist/vampire)
	var/datum/antagonist/vampirelord/VL = mind.has_antag_datum(/datum/antagonist/vampirelord)
	if(!V && !VL)
		return
	if (V)
		if (V.exposed)
			to_chat(src, span_warning("I am still recovering!"))
			return
		
		if(V.disguised)
			to_chat(src, span_warning("I reveal my true form."))
			V.disguised = FALSE
			
			if(dna)
				var/datum/organ_dna/eyes/eyes_dna = dna.organ_dna[ORGAN_SLOT_EYES]
				var/obj/item/organ/eyes/E = getorganslot(ORGAN_SLOT_EYES)
				if(E)
					E.eye_color = "#ff0000"
					E.second_color = "#ff0000"
					if(eyes_dna)
						E.imprint_organ_dna(eyes_dna)
					E.update_accessory_colors()
					E.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
		else
			if (V.low_vitae)
				to_chat(src, span_warning("My vitae is too low!"))
				return
			to_chat(src, span_warning("I conceal my vampiric nature."))
			V.disguised = TRUE
			if (MUTCOLORS in dna.species.species_traits)
				set_mutant_colors(V.cache_mcolor, V.cache_mcolor2, V.cache_mcolor3, V.cache_chest_marking_color, update = FALSE)
				set_organ_slot_color(ORGAN_SLOT_FRILLS, V.cache_frill_color)
				set_organ_slot_color(ORGAN_SLOT_SNOUT, V.cache_snout_color)
				set_organ_slot_color(ORGAN_SLOT_TAIL_FEATURE, V.cache_tail_feature_color)
			else
				set_skin_tone(V.cache_skin, V.cache_pigment, update = FALSE)
			if (!(MUTCOLORS_PARTSONLY in dna.species.species_traits))
				set_organ_slot_color(ORGAN_SLOT_TAIL, V.cache_tail_color)
				set_organ_slot_color(ORGAN_SLOT_EARS, V.cache_ear_color)
			set_hair_color(V.cache_hair, V.cache_hair_nat, update = FALSE)
			set_facial_hair_color(V.cache_facial, V.cache_facial_nat, update = FALSE)
			
			if(V.cache_eye_color && dna)
				var/datum/organ_dna/eyes/eyes_dna = dna.organ_dna[ORGAN_SLOT_EYES]
				var/obj/item/organ/eyes/E = getorganslot(ORGAN_SLOT_EYES)
				if(E)
					E.eye_color = V.cache_eye_color
					E.second_color = V.cache_second_color
					if(eyes_dna)
						E.imprint_organ_dna(eyes_dna)
					E.update_accessory_colors()
					E.lighting_alpha = null
	else if (VL)
		if (VL.exposed)
			to_chat(src, span_warning("I am still recovering!"))
			return
		
		if(VL.disguised)
			to_chat(src, span_warning("I reveal my true form."))
			VL.disguised = FALSE
			
			if(dna)
				var/datum/organ_dna/eyes/eyes_dna = dna.organ_dna[ORGAN_SLOT_EYES]
				var/obj/item/organ/eyes/E = getorganslot(ORGAN_SLOT_EYES)
				if(E)
					E.eye_color = "#ff0000"
					E.second_color = "#ff0000"
					if(eyes_dna)
						E.imprint_organ_dna(eyes_dna)
					E.update_accessory_colors()
		else
			if (VL.low_vitae)
				to_chat(src, span_warning("My vitae is too low!"))
				return
			to_chat(src, span_warning("I conceal my vampiric nature."))
			VL.disguised = TRUE
			if (MUTCOLORS in dna.species.species_traits)
				set_mutant_colors(VL.cache_mcolor, VL.cache_mcolor2, VL.cache_mcolor3, VL.cache_chest_marking_color, update = FALSE)
				set_organ_slot_color(ORGAN_SLOT_FRILLS, VL.cache_frill_color)
				set_organ_slot_color(ORGAN_SLOT_SNOUT, VL.cache_snout_color)
				set_organ_slot_color(ORGAN_SLOT_TAIL_FEATURE, VL.cache_tail_feature_color)
			else
				set_skin_tone(VL.cache_skin, VL.cache_pigment, update = FALSE)
			if (!(MUTCOLORS_PARTSONLY in dna.species.species_traits))
				set_organ_slot_color(ORGAN_SLOT_TAIL, VL.cache_tail_color)
				set_organ_slot_color(ORGAN_SLOT_EARS, VL.cache_ear_color)
			set_hair_color(VL.cache_hair, VL.cache_hair_nat, update = FALSE)
			set_facial_hair_color(VL.cache_facial, VL.cache_facial_nat, update = FALSE)
			
			if(VL.cache_eye_color && dna)
				var/datum/organ_dna/eyes/eyes_dna = dna.organ_dna[ORGAN_SLOT_EYES]
				var/obj/item/organ/eyes/E = getorganslot(ORGAN_SLOT_EYES)
				if(E)
					E.eye_color = VL.cache_eye_color
					E.second_color = VL.cache_second_color
					if(eyes_dna)
						E.imprint_organ_dna(eyes_dna)
					E.update_accessory_colors()
	dna?.species.handle_body(src)
	update_body()
	update_hair()
	update_body_parts(TRUE)
	regenerate_icons()
	update_sight()

/mob/living/carbon/human/proc/vampire_disguise(datum/antagonist/V)
	if(!V)
		return
	var/datum/antagonist/vampire/VD = mind.has_antag_datum(/datum/antagonist/vampire)
	var/datum/antagonist/vampirelord/VL = mind.has_antag_datum(/datum/antagonist/vampirelord)
	if(VD)
		VD.disguised = TRUE
		if (MUTCOLORS in dna.species.species_traits)
			set_mutant_colors(VD.cache_mcolor, VD.cache_mcolor2, VD.cache_mcolor3, VD.cache_chest_marking_color, update = FALSE)
			set_organ_slot_color(ORGAN_SLOT_FRILLS, VD.cache_frill_color)
			set_organ_slot_color(ORGAN_SLOT_SNOUT, VD.cache_snout_color)
			set_organ_slot_color(ORGAN_SLOT_TAIL_FEATURE, VD.cache_tail_feature_color)
		else
			set_skin_tone(VD.cache_skin, VD.cache_pigment, update = FALSE)
		if (!(MUTCOLORS_PARTSONLY in dna.species.species_traits))
			set_organ_slot_color(ORGAN_SLOT_TAIL, VD.cache_tail_color)
			set_organ_slot_color(ORGAN_SLOT_EARS, VD.cache_ear_color)
		set_hair_color(VD.cache_hair, VD.cache_hair_nat, update = FALSE)
		set_facial_hair_color(VD.cache_facial, VD.cache_facial_nat, update = FALSE)
		if(VD.cache_eye_color && dna)
			var/datum/organ_dna/eyes/eyes_dna = dna.organ_dna[ORGAN_SLOT_EYES]
			var/obj/item/organ/eyes/E = getorganslot(ORGAN_SLOT_EYES)
			if(E)
				E.eye_color = VD.cache_eye_color
				E.second_color = VD.cache_second_color
				if(eyes_dna)
					E.imprint_organ_dna(eyes_dna)
				E.update_accessory_colors()
				E.lighting_alpha = null
	if(VL)
		VL.disguised = TRUE
		if (MUTCOLORS in dna.species.species_traits)
			set_mutant_colors(VL.cache_mcolor, VL.cache_mcolor2, VL.cache_mcolor3, VL.cache_chest_marking_color, update = FALSE)
			set_organ_slot_color(ORGAN_SLOT_FRILLS, VL.cache_frill_color)
			set_organ_slot_color(ORGAN_SLOT_SNOUT, VL.cache_snout_color)
			set_organ_slot_color(ORGAN_SLOT_TAIL_FEATURE, VL.cache_tail_feature_color)
		else
			set_skin_tone(VL.cache_skin, VL.cache_pigment, update = FALSE)
		if (!(MUTCOLORS_PARTSONLY in dna.species.species_traits))
			set_organ_slot_color(ORGAN_SLOT_TAIL, VL.cache_tail_color)
			set_organ_slot_color(ORGAN_SLOT_EARS, VL.cache_ear_color)
		set_hair_color(VL.cache_hair, VL.cache_hair_nat, update = FALSE)
		set_facial_hair_color(VL.cache_facial, VL.cache_facial_nat, update = FALSE)
		if(VL.cache_eye_color && dna)
			var/datum/organ_dna/eyes/eyes_dna = dna.organ_dna[ORGAN_SLOT_EYES]
			var/obj/item/organ/eyes/E = getorganslot(ORGAN_SLOT_EYES)
			if(E)
				E.eye_color = VL.cache_eye_color
				E.second_color = VL.cache_second_color
				if(eyes_dna)
					E.imprint_organ_dna(eyes_dna)
				E.update_accessory_colors()
	dna?.species.handle_body(src)
	update_body()
	update_hair()
	update_body_parts(TRUE)
	regenerate_icons()
	update_sight()

/mob/living/carbon/human/proc/vampire_undisguise(datum/antagonist/V)
	if(!V)
		return
	
	if(istype(V, /datum/antagonist/vampirelord))
		var/datum/antagonist/vampirelord/VD = V
		VD.disguised = FALSE
	else if(istype(V, /datum/antagonist/vampire))
		var/datum/antagonist/vampire/VD = V
		VD.disguised = FALSE
	else
		return
	
	if (MUTCOLORS in dna.species.species_traits)
		if(istype(V, /datum/antagonist/vampirelord))
			var/datum/antagonist/vampirelord/VD = V
			set_mutant_colors("c9d3de", "c9d3de", "c9d3de", vampirized_scale_colors(VD.cache_chest_marking_color, FALSE), update = FALSE)
		else if(istype(V, /datum/antagonist/vampire))
			var/datum/antagonist/vampire/VD = V
			set_mutant_colors("c9d3de", "c9d3de", "c9d3de", vampirized_scale_colors(VD.cache_chest_marking_color, FALSE), update = FALSE)
		set_organ_slot_color(ORGAN_SLOT_FRILLS, vampire_organ_scales_color(ORGAN_SLOT_FRILLS))
		set_organ_slot_color(ORGAN_SLOT_SNOUT, vampire_organ_scales_color(ORGAN_SLOT_SNOUT))
		set_organ_slot_color(ORGAN_SLOT_TAIL, vampire_organ_scales_color(ORGAN_SLOT_TAIL))
		set_organ_slot_color(ORGAN_SLOT_TAIL_FEATURE, vampire_organ_scales_color(ORGAN_SLOT_TAIL_FEATURE))
	else
		set_skin_tone("c9d3de", update = FALSE)
		if (!(MUTCOLORS_PARTSONLY in dna.species.species_traits))
			set_organ_slot_color(ORGAN_SLOT_TAIL, "c9d3de")
			set_organ_slot_color(ORGAN_SLOT_EARS, "c9d3de")
	set_hair_color("#181a1d", "#181a1d", update = FALSE) //dye not affected
	set_facial_hair_color("#181a1d", "#181a1d", update = FALSE)
	
	if(dna)
		var/datum/organ_dna/eyes/eyes_dna = dna.organ_dna[ORGAN_SLOT_EYES]
		var/obj/item/organ/eyes/E = getorganslot(ORGAN_SLOT_EYES)
		if(E)
			E.eye_color = "#ff0000"
			E.second_color = "#ff0000"
			if(eyes_dna)
				E.imprint_organ_dna(eyes_dna)
			E.update_accessory_colors()
			if (istype(V, /datum/antagonist/vampire))
				E.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	
	dna?.species.handle_body(src)
	update_body()
	update_hair()
	update_body_parts(TRUE)
	regenerate_icons()
	update_sight()

/mob/living/carbon/human/proc/blood_strength()
	set name = "Night Muscles"
	set category = "VAMPIRE"

	var/datum/antagonist/vampirelord/VD = mind.has_antag_datum(/datum/antagonist/vampirelord)
	if(!VD)
		to_chat(src, span_warning("I am not a vampire lord."))
		return
	if(VD.disguised)
		to_chat(src, span_warning("I cannot use Night Muscles while disguised."))
		return
	if(VD.vitae < 100)
		to_chat(src, span_warning("I need at least 100 vitae to use Night Muscles. (Current: [VD.vitae])"))
		return
	if(has_status_effect(/datum/status_effect/buff/bloodstrength))
		to_chat(src, span_warning("Night Muscles is already active."))
		return
	VD.handle_vitae(-100)
	apply_status_effect(/datum/status_effect/buff/bloodstrength)
	to_chat(src, span_greentext("! NIGHT MUSCLES !"))
	src.playsound_local(get_turf(src), 'sound/misc/vampirespell.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/status_effect/buff/bloodstrength
	id = "bloodstrength"
	alert_type = /atom/movable/screen/alert/status_effect/buff/bloodstrength
	effectedstats = list("strength" = 6)
	duration = 1 MINUTES

/atom/movable/screen/alert/status_effect/buff/bloodstrength
	name = "Night Muscles"
	desc = ""
	icon_state = "bleed1"

/mob/living/carbon/human/proc/blood_celerity()
	set name = "Quickening"
	set category = "VAMPIRE"

	var/datum/antagonist/vampirelord/VD = mind.has_antag_datum(/datum/antagonist/vampirelord)
	if(!VD)
		to_chat(src, span_warning("I am not a vampire lord."))
		return
	if(VD.disguised)
		to_chat(src, span_warning("I cannot use Quickening while disguised."))
		return
	if(VD.vitae < 100)
		to_chat(src, span_warning("I need at least 100 vitae to use Quickening. (Current: [VD.vitae])"))
		return
	if(has_status_effect(/datum/status_effect/buff/celerity))
		to_chat(src, span_warning("Quickening is already active."))
		return
	VD.handle_vitae(-100)
	rogstam_add(2000)
	apply_status_effect(/datum/status_effect/buff/celerity)
	to_chat(src, span_greentext("! QUICKENING !"))
	src.playsound_local(get_turf(src), 'sound/misc/vampirespell.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/status_effect/buff/celerity
	id = "celerity"
	alert_type = /atom/movable/screen/alert/status_effect/buff/celerity
	effectedstats = list("speed" = 15,"perception" = 10)
	duration = 30 SECONDS

/datum/status_effect/buff/celerity/nextmove_modifier()
	return 0.60

/atom/movable/screen/alert/status_effect/buff/celerity
	name = "Quickening"
	desc = ""
	icon_state = "bleed1"

/mob/living/carbon/human/proc/blood_fortitude()
	set name = "Armor of Darkness"
	set category = "VAMPIRE"

	var/datum/antagonist/vampire/VD = mind.has_antag_datum(/datum/antagonist/vampire)
	if(!VD)
		to_chat(src, span_warning("I am not a vampire lord."))
		return
	if(VD.disguised)
		to_chat(src, span_warning("I cannot use Armor of Darkness while disguised."))
		return
	if(VD.vitae < 100)
		to_chat(src, span_warning("I need at least 100 vitae to use Armor of Darkness. (Current: [VD.vitae])"))
		return
	if(has_status_effect(/datum/status_effect/buff/fortitude))
		to_chat(src, span_warning("Armor of Darkness is already active."))
		return
	VD.vitae -= 100
	rogstam_add(2000)
	apply_status_effect(/datum/status_effect/buff/fortitude)
	to_chat(src, span_greentext("! ARMOR OF DARKNESS !"))
	src.playsound_local(get_turf(src), 'sound/misc/vampirespell.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/status_effect/buff/fortitude
	id = "fortitude"
	alert_type = /atom/movable/screen/alert/status_effect/buff/fortitude
	effectedstats = list("endurance" = 20,"constitution" = 20)
	duration = 30 SECONDS

/atom/movable/screen/alert/status_effect/buff/fortitude
	name = "Armor of Darkness"
	desc = ""
	icon_state = "bleed1"

/datum/status_effect/buff/fortitude/on_apply()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		QDEL_NULL(H.skin_armor)
		H.skin_armor = new /obj/item/clothing/suit/roguetown/armor/skin_armor/vampire_fortitude(H)
	owner.add_stress(/datum/stressevent/weed)

/datum/status_effect/buff/fortitude/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(istype(H.skin_armor, /obj/item/clothing/suit/roguetown/armor/skin_armor/vampire_fortitude))
			QDEL_NULL(H.skin_armor)
	. = ..()

/obj/item/clothing/suit/roguetown/armor/skin_armor/vampire_fortitude
	slot_flags = null
	name = "vampire's skin"
	desc = ""
	icon_state = null
	body_parts_covered = FULL_BODY
	armor = list("blunt" = 100, "slash" = 100, "stab" = 90, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	prevent_crits = list(BCLASS_CUT, BCLASS_STAB, BCLASS_BLUNT, BCLASS_TWIST)
	blocksound = SOFTHIT
	blade_dulling = DULLING_BASHCHOP
	sewrepair = TRUE
	max_integrity = 0

/mob/living/carbon/human/proc/vamp_regenerate()
	set name = "Regenerate"
	set category = "VAMPIRE"
	
	var/silver_curse_status = FALSE
	for(var/datum/status_effect/debuff/silver_curse/silver_curse in status_effects)
		silver_curse_status = TRUE
		break
	
	var/datum/antagonist/vampire/VD = mind.has_antag_datum(/datum/antagonist/vampire)
	var/datum/antagonist/vampirelord/VL = mind.has_antag_datum(/datum/antagonist/vampirelord)
	if(!VD && !VL)
		to_chat(src, span_warning("I am not a vampire."))
		return
	
	var/vitae_check = 0
	var/is_disguised = FALSE
	if(VD)
		vitae_check = VD.vitae
		is_disguised = VD.disguised
	else if(VL)
		vitae_check = VL.vitae
		is_disguised = VL.disguised
	
	if(is_disguised)
		to_chat(src, span_warning("I cannot regenerate while disguised."))
		return
	if(silver_curse_status)
		to_chat(src, span_warning("The silver curse prevents regeneration!"))
		return
	if(vitae_check < 500)
		to_chat(src, span_warning("I need at least 500 vitae to regenerate. (Current: [vitae_check])"))
		return
	
	to_chat(src, span_greentext("! REGENERATE !"))
	src.playsound_local(get_turf(src), 'sound/misc/vampirespell.ogg', 100, FALSE, pressure_affected = FALSE)
	if(VD)
		VD.handle_vitae(-500)
	else if(VL)
		VL.handle_vitae(-500)
	fully_heal()
	regenerate_limbs()

/mob/living/carbon/human/proc/vampire_infect()
	if(!mind)
		return
	if(mind.has_antag_datum(/datum/antagonist/vampire))
		return
	if(mind.has_antag_datum(/datum/antagonist/werewolf))
		return
	if(mind.has_antag_datum(/datum/antagonist/zombie))
		return
	if(mob_timers["becoming_vampire"])
		return
	mob_timers["becoming_vampire"] = world.time
	addtimer(CALLBACK(src, TYPE_PROC_REF(/mob/living/carbon/human, vampire_finalize)), 2 MINUTES)
	to_chat(src, span_danger("I feel sick..."))
	src.playsound_local(get_turf(src), 'sound/music/horror.ogg', 80, FALSE, pressure_affected = FALSE)
	flash_fullscreen("redflash3")

/mob/living/carbon/human/proc/vampire_finalize()
	if(!mind)
		mob_timers["becoming_vampire"] = null
		return
	if(mind.has_antag_datum(/datum/antagonist/vampire))
		mob_timers["becoming_vampire"] = null
		return
	if(mind.has_antag_datum(/datum/antagonist/werewolf))
		mob_timers["becoming_vampire"] = null
		return
	if(mind.has_antag_datum(/datum/antagonist/zombie))
		mob_timers["becoming_vampire"] = null
		return
	var/datum/antagonist/vampire/new_antag = new /datum/antagonist/vampire/lesser()
	mind.add_antag_datum(new_antag)
	Sleeping(100)
//	stop_all_loops()
	src.playsound_local(src, 'sound/misc/deth.ogg', 100)
	if(client)
		SSdroning.kill_rain(client)
		SSdroning.kill_loop(client)
		SSdroning.kill_droning(client)
		client.move_delay = initial(client.move_delay)
		var/atom/movable/screen/gameover/hog/H = new()
		H.layer = SPLASHSCREEN_LAYER+0.1
		client.screen += H
		H.Fade()
		addtimer(CALLBACK(H, TYPE_PROC_REF(/atom/movable/screen/gameover, Fade), TRUE), 100)

/*


	All the code below was written while figuring out how to alter player appearances ingame,
	it's intended to be rewritten it in the future


*/
/mob/living/carbon/human/proc/set_chest_scales(list/chest_colors)
	var/obj/item/bodypart/chest = get_bodypart(BODY_ZONE_CHEST)
	if(!chest)
		return null
	var/counter = 1
	for(var/marking_name in chest.markings)
		var/datum/body_marking/marking = GLOB.body_markings[marking_name]
		if(!marking.covers_chest)
			continue
		chest.markings[marking_name] = chest_colors[counter]
		counter++
	return null

/mob/living/carbon/human/proc/get_chest_scales()
	var/obj/item/bodypart/chest = get_bodypart(BODY_ZONE_CHEST)
	if(!chest)
		return null
	var/list/all_markings = list()
	for(var/marking_name in chest.markings)
		var/datum/body_marking/marking = GLOB.body_markings[marking_name]
		if(!marking.covers_chest)
			continue
		all_markings += chest.markings[marking_name]
	if (all_markings.len == 0)
		return null
	return all_markings
/mob/living/carbon/human/proc/set_organ_slot_color(organ_slot, organ_color)
	if (!organ_color)
		return
	var/obj/item/organ/Organ = getorganslot(organ_slot)
	if (!Organ)
		return
	if (!Organ.accessory_type)
		return
	Organ.accessory_colors = organ_color

/mob/living/carbon/human/proc/get_organ_slot_color(organ_slot)
	var/obj/item/organ/Organ = getorganslot(organ_slot)
	if (!Organ)
		return
	if (!Organ.accessory_type)
		return
	return Organ.accessory_colors

//right now the whole list gets populated with the normal vampire skin color, in the future you can use stuff like MixRGB to apply color transforms onto the base ones
/proc/vampirized_scale_colors(list/colors, include_crunch = TRUE)
	if (!colors)
		return null
	var/list/v_colors = list()
	for (var/col in colors)
		if (include_crunch)
			v_colors += "#c9d3de"
		else
			v_colors += "c9d3de"
	return v_colors

/mob/living/carbon/human/proc/vampire_organ_scales_color(organ_slot)
	var/base_color_packed = get_organ_slot_color(organ_slot)
	if (!base_color_packed)
		return
	var/list/base_color_unpacked = color_string_to_list(base_color_packed)
	var/list/vamp_color_unpacked = vampirized_scale_colors(base_color_unpacked)
	return color_list_to_string(vamp_color_unpacked)

/mob/living/carbon/human/proc/set_skin_tone(n_skin_tone, n_pigmented, update = TRUE)
	skin_tone = n_skin_tone
	var/san_skin_tone = sanitize_hexcolor(skin_tone, 6, 1) //prepend # to hex
	if (n_pigmented)
		set_organ_slot_color(ORGAN_SLOT_PENIS, n_pigmented) //fuck your weird penis
	else
		set_organ_slot_color(ORGAN_SLOT_PENIS, list(san_skin_tone, san_skin_tone))
	set_organ_slot_color(ORGAN_SLOT_BREASTS, san_skin_tone)
	if (update)
		update_body_parts(TRUE)

//for lizards and kobolds
/mob/living/carbon/human/proc/set_mutant_colors(mcolor, mcolor2, mcolor3, list/chest_color, update = TRUE)
	if (!dna)
		return
	dna.features["mcolor"] = mcolor
	dna.features["mcolor2"] = mcolor2
	dna.features["mcolor3"] = mcolor3
	if (chest_color)
		set_chest_scales(chest_color)
	var/san_mcolor = sanitize_hexcolor(mcolor, 6, 1)
	if (chest_color)
		var/san_chestcolor = sanitize_hexcolor(chest_color[1], 6, 1)
		set_organ_slot_color(ORGAN_SLOT_PENIS, color_list_to_string(list(san_chestcolor, san_chestcolor)))
		set_organ_slot_color(ORGAN_SLOT_BREASTS, color_list_to_string(list(san_chestcolor, san_chestcolor)))
	else
		set_organ_slot_color(ORGAN_SLOT_PENIS, color_list_to_string(list(san_mcolor, san_mcolor)))
		set_organ_slot_color(ORGAN_SLOT_BREASTS, color_list_to_string(list(san_mcolor, san_mcolor)))
	if (update)
		update_body_parts(TRUE)

/datum/bodypart_feature/hair/proc/set_color(n_hair_color, n_natural_color, n_dye_color)
	if (n_hair_color)
		accessory_colors = n_hair_color
	if (n_natural_color)
		natural_color = n_natural_color
	if (n_dye_color)
		hair_dye_color = n_dye_color

/datum/bodypart_feature/hair/proc/set_gradient(n_natural_gradient, n_dye_gradient)
	if (n_natural_gradient)
		natural_gradient = n_natural_gradient
	if (n_dye_gradient)
		hair_dye_gradient = n_dye_gradient

/mob/living/carbon/human/proc/set_hair_color(n_hair_color, n_natural_color, n_dye_color, update = TRUE)
	var/datum/bodypart_feature/hair/head/Hair = get_bodypart_feature_of_slot(BODYPART_FEATURE_HAIR)
	if (Hair)
		Hair.set_color(n_hair_color, n_natural_color, n_dye_color)
	if (update)
		update_hair()

/mob/living/carbon/human/proc/set_hair_gradient(natural_gradient, dye_gradient, update = TRUE)
	var/datum/bodypart_feature/hair/head/Hair = get_bodypart_feature_of_slot(BODYPART_FEATURE_HAIR)
	if (Hair)
		Hair.set_gradient(natural_gradient, dye_gradient)
	if (update)
		update_hair()

/mob/living/carbon/human/proc/set_facial_hair_color(n_hair_color, n_natural_color, n_dye_color, update = TRUE)
	var/datum/bodypart_feature/hair/facial/Facial = get_bodypart_feature_of_slot(BODYPART_FEATURE_FACIAL_HAIR)
	if (Facial)
		Facial.set_color(n_hair_color, n_natural_color, n_dye_color)
	if (update)
		update_hair()

/mob/living/carbon/human/proc/set_facial_hair_gradient(n_natural_gradient, n_dye_gradient, update = TRUE)
	var/datum/bodypart_feature/hair/facial/Facial = get_bodypart_feature_of_slot(BODYPART_FEATURE_FACIAL_HAIR)
	if (Facial)
		Facial.set_gradient(n_natural_gradient, n_dye_gradient)
	if (update)
		update_hair()
