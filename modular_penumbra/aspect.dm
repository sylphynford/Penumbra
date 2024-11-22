GLOBAL_DATUM_INIT(SSroundstart_events, /datum/controller/subsystem/roundstart_events, new)
#define SSroundstart_events GLOB.SSroundstart_events

// Base types
/datum/round_event_control/roundstart
	var/runnable = TRUE
	var/event_announcement = ""
	var/selected_event_name = null 

/datum/round_event/roundstart
	var/static/is_active = FALSE
	
	proc/apply_effect()
		SHOULD_CALL_PARENT(TRUE)
		return

/datum/round_event_control/roundstart/proc/can_spawn_event()
	if(SSticker.current_state != GAME_STATE_PLAYING)
		return FALSE
	return runnable

// Eternal Night event
/datum/round_event/roundstart/eternal_night
	/datum/round_event/roundstart/eternal_night/apply_effect()
		. = ..()
		is_active = TRUE
		
		// Nullify existing sunlights
		for(var/obj/effect/sunlight/S in GLOB.sunlights)
			S.light_power = 0
			S.set_light(S.brightness, 0, S.light_color)
		
		START_PROCESSING(SSprocessing, src)

	/datum/round_event/roundstart/eternal_night/process()
		if(!is_active)
			STOP_PROCESSING(SSprocessing, src)
			return
		
		for(var/obj/effect/sunlight/S in GLOB.sunlights)
			if(S.light_power != 0)
				S.light_power = 0
				S.set_light(S.brightness, 0, S.light_color)

/datum/round_event_control/roundstart/eternal_night
	name = "Magician's Curse"
	typepath = /datum/round_event/roundstart/eternal_night
	weight = 5
	event_announcement = "The sky has been darkened by inhumen magicks..."
	runnable = TRUE

// Wealthy Benefactor event
/datum/round_event/roundstart/wealthy_benefactor
	var/static/list/rewarded_ckeys = list()

	/datum/round_event/roundstart/wealthy_benefactor/apply_effect()
		. = ..()
		is_active = TRUE
		START_PROCESSING(SSprocessing, src)

	/datum/round_event/roundstart/wealthy_benefactor/process()
		if(!is_active)
			STOP_PROCESSING(SSprocessing, src)
			return
			
		for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
			if(!H.mind || !H.mind.key)
				continue
			if(H.mind.key in rewarded_ckeys)
				continue
			if(H.mind.special_role in list("Vampire Lord", "Lich", "Bandit"))
				continue
				
			var/obj/item/storage/belt/rogue/pouch/coins/reallyrich/reward = new(get_turf(H))
			H.put_in_hands(reward)
			rewarded_ckeys += H.mind.key
			priority_announce("They say [H.real_name] recently had a large inheritence..", "Arcyne Phenomena")
			STOP_PROCESSING(SSprocessing, src)
			is_active = FALSE
			return

/datum/round_event_control/roundstart/wealthy_benefactor
	name = "Wealthy Benefactor"
	typepath = /datum/round_event/roundstart/wealthy_benefactor
	weight = 10
	event_announcement = ""
	runnable = TRUE

// Female Transformation event
/datum/round_event/roundstart/female_transformation
	var/static/list/transformed_ckeys = list()

	/datum/round_event/roundstart/female_transformation/apply_effect()
		. = ..()
		is_active = TRUE
		// Initial transformation of existing players
		for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
			transform_human(H)
		START_PROCESSING(SSprocessing, src)

	/datum/round_event/roundstart/female_transformation/process()
		if(!is_active)
			STOP_PROCESSING(SSprocessing, src)
			return
		
		// Check for new players to transform
		for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
			if(!H.mind || !H.mind.key)
				continue
			if(H.mind.key in transformed_ckeys)
				continue
			if(transform_human(H))
				priority_announce("[H.real_name] has been transformed by the lingering energies!", "Arcyne Phenomena")

	/datum/round_event/roundstart/female_transformation/proc/handle_organs(mob/living/carbon/human/H)
		if(!H.mind || H.gender == FEMALE)
			return
			
		// Remove male organs
		var/obj/item/organ/penis/P = H.internal_organs_slot["penis"]
		if(P)
			P.Remove(H, special = TRUE)
			qdel(P)
		
		var/obj/item/organ/testicles/T = H.internal_organs_slot["testicles"]
		if(T)
			T.Remove(H, special = TRUE)
			qdel(T)
			
		// Add female organs
		if(!H.internal_organs_slot["vagina"])
			var/obj/item/organ/vagina/V = new
			V.Insert(H, special = TRUE, drop_if_replaced = FALSE)
			
		if(!H.internal_organs_slot["breasts"])
			var/obj/item/organ/breasts/B = new
			B.Insert(H, special = TRUE, drop_if_replaced = FALSE)

	/datum/round_event/roundstart/female_transformation/proc/transform_human(mob/living/carbon/human/H)
		if(!H?.mind || H.gender == FEMALE)
			return FALSE
			
		handle_organs(H)
		
		// Gender, voice, and pronoun changes
		H.gender = FEMALE
		H.voice_type = "Feminine"
		H.pronouns = "she/her"
			
		// Force facial hair removal
		H.facial_hairstyle = "Shaved"
		H.update_facial_hair()
		H.overlays_standing[HAIR_LAYER] = null
			
		// Force full updates in correct order
		H.update_body()
		H.update_body_parts(TRUE)
		H.update_hair()
		H.update_facial_hair()
		H.dna?.species.handle_body(H)
		H.regenerate_icons()
		H.regenerate_clothes()

		// Force client-side update
		if(H.client)
			addtimer(CALLBACK(H, TYPE_PROC_REF(/atom, update_icon)), 1)
			
		if(H.mind.key)
			transformed_ckeys += H.mind.key
			
		return TRUE

/datum/round_event_control/roundstart/female_transformation
	name = "Sisterhood"
	typepath = /datum/round_event/roundstart/female_transformation
	weight = 10
	event_announcement = "Some sort of curse has turned all the men into women.."
	runnable = TRUE

// Great Lover event
/datum/round_event/roundstart/great_lover
	/datum/round_event/roundstart/great_lover/apply_effect()
		. = ..()
		var/list/valid_lovers = list()
		for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
			if(H.mind)
				valid_lovers += H
				
		if(!length(valid_lovers))
			return
			
		var/mob/living/carbon/human/chosen_lover = pick(valid_lovers)
		ADD_TRAIT(chosen_lover, TRAIT_GOODLOVER, "great_lover_event")
		
		var/list/lover_titles = list(
			"legendary lover",
			"fabled seducer",
			"incomparable romantic",
			"extraordinary paramour",
			"illustrious heartbreaker"
		)
		
		var/chosen_title = pick(lover_titles)
		priority_announce("The stars have aligned... [chosen_lover.real_name] has been blessed as a [chosen_title]!", "Arcyne Phenomena")

/datum/round_event_control/roundstart/great_lover
	name = "Great Lover"
	typepath = /datum/round_event/roundstart/great_lover
	weight = 0
	event_announcement = ""
	runnable = TRUE

	// Throne execution event
/datum/round_event/roundstart/throne_execution
	proc/announce_execution(message, failed = FALSE)
		priority_announce(message, "Official Execution[failed ? " Failed" : ""]")
		// Play decree sound to all living mobs
		for(var/mob/living/L in GLOB.mob_list)
			SEND_SOUND(L, sound('sound/misc/royal_decree.ogg', volume = 100))

	proc/is_execution_immune(mob/living/carbon/human/H)
		if(!H)
			return FALSE
		// Check for werewolf species
		if(istype(H, /mob/living/carbon/human/species/werewolf))
			return TRUE
		// Check for vampire lord and lich special_roles
		if(H.mind?.special_role in list("Vampire Lord", "Lich"))
			return TRUE
		return FALSE

	proc/handle_throne_execution(mob/living/carbon/human/speaker, list/speech_args)
		if(!speaker || !(speaker.job in list("Baron", "Baroness")))
			return
		
		// Check if they're buckled to the throne
		if(!speaker.buckled || !istype(speaker.buckled, /obj/structure/roguethrone))
			return
			
		var/spoken_text = speech_args[SPEECH_MESSAGE]
		
		// Convert to lowercase and remove punctuation for comparison
		spoken_text = lowertext(spoken_text)
		spoken_text = replacetext(spoken_text, "!", "")
		spoken_text = replacetext(spoken_text, ".", "")
		spoken_text = replacetext(spoken_text, "?", "")
		spoken_text = replacetext(spoken_text, ",", "")
		
		// Check if the message starts with "execute" (case insensitive)
		if(!findtext(spoken_text, "execute ", 1, 9))
			return
			
		// Extract and clean the name after "execute "
		var/target_name = trim(copytext(spoken_text, 9))
		if(!length(target_name))
			return
			
		// Look for a mob matching the spoken name (case insensitive)
		for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
			if(lowertext(H.real_name) == target_name)
				// Check if target has a mind
				if(!H.mind)
					return
					
				// Check for execution immunity
				if(is_execution_immune(H))
					announce_execution("[H.real_name] resists the execution through supernatural power!", TRUE)
					// Optional: Add visual effect to show immunity
					var/turf/T = get_turf(H)
					if(T)
						new /obj/effect/temp_visual/dir_setting/bloodsplatter(T)
					return
				
				// If not immune and has mind, proceed with execution
				announce_execution("[H.real_name] has been violently executed by official decree!")
				var/turf/T = get_turf(H)
				if(T)
					new /obj/effect/temp_visual/dir_setting/bloodsplatter(T)
				H.gib(TRUE, TRUE, TRUE)  // Full gibbing with animation
				break

	/datum/round_event/roundstart/throne_execution/apply_effect()
		. = ..()
		// Add throne speech handling to all humans
		for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
			if(H.job in list("Baron", "Baronness"))
				RegisterSignal(H, COMSIG_MOB_SAY, PROC_REF(handle_throne_execution))
		
		// Make all titans announce the execution instructions with sound
		for(var/obj/structure/roguemachine/titan/T in world)
			T.say("Say EXECUTE followed by the criminal's name while sitting on the throne to destroy them.")
			playsound(T.loc, 'sound/misc/machinetalk.ogg', 50, FALSE)

/datum/round_event_control/roundstart/throne_execution
	name = "Throne Execution Power"
	typepath = /datum/round_event/roundstart/throne_execution
	weight = 0
	event_announcement = "The throne crackles with newfound power..."
	runnable = TRUE

// Admin verb for managing roundstart events
/client/proc/force_roundstart_event()
	set category = "Admin"
	set name = "Force Roundstart Event"
	set desc = "Triggers a specific roundstart event"

	if(!check_rights(R_ADMIN))
		return

	var/list/event_choices = list()
	for(var/event_path in subtypesof(/datum/round_event_control/roundstart))
		var/datum/round_event_control/roundstart/event = new event_path()
		if(event.runnable)  // Only show events that are marked as runnable
			event_choices[event.name] = event  // Store the actual event object

	var/choice = input(usr, "Choose an event to trigger", "Force Roundstart Event") as null|anything in event_choices
	if(!choice)
		return
	
	var/datum/round_event_control/roundstart/chosen_event = event_choices[choice]
	var/confirm = alert(usr, "Trigger [chosen_event.name]? \nAnnouncement: [chosen_event.event_announcement]", "Confirm Event", "Yes", "No")
	if(confirm != "Yes")
		return
		
	var/datum/round_event/roundstart/E = new chosen_event.typepath()
	if(E && istype(E))
		if(chosen_event.event_announcement)
			priority_announce(chosen_event.event_announcement, "Arcyne Phenomena")
		if(chosen_event.runnable)
			E.apply_effect()
			
		message_admins("[key_name_admin(usr)] forced the roundstart event: [chosen_event.name]")
		log_admin("[key_name(usr)] forced the roundstart event: [chosen_event.name]")

// Roundstart events subsystem
/datum/controller/subsystem/roundstart_events
	name = "Roundstart Events"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_EVENTS
	
	var/list/datum/round_event_control/roundstart/roundstart_events = list()
	var/datum/round_event_control/roundstart/selected_event
	var/has_fired = FALSE
	var/list/active_events = list()

	Initialize(timeofday)
		. = ..()
		for(var/path in subtypesof(/datum/round_event_control/roundstart))
			var/datum/round_event_control/roundstart/RE = new path()
			roundstart_events += RE
		START_PROCESSING(SSprocessing, src)

	process()
		if(!has_fired && SSticker.current_state == GAME_STATE_PLAYING)
			has_fired = TRUE
			pick_roundstart_event()
			fire_event()
			STOP_PROCESSING(SSprocessing, src)

	proc/pick_roundstart_event()
		var/list/possible_events = list()
		
		for(var/datum/round_event_control/roundstart/RE as anything in roundstart_events)
			if(RE.runnable && RE.can_spawn_event())
				possible_events[RE] = RE.weight
				
		if(!length(possible_events))
			return FALSE

		selected_event = pickweight(possible_events)
		return TRUE

	proc/fire_event()
		if(!selected_event || !selected_event.typepath)
			return

		if(selected_event.event_announcement)
			priority_announce(selected_event.event_announcement, "Arcyne Phenomena")
			
		var/datum/round_event/roundstart/E = new selected_event.typepath()
		if(E && istype(E))
			active_events += E
			if(selected_event.runnable)
				E.apply_effect()

