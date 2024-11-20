// Base roundstart event control
/datum/round_event_control/roundstart
	var/runnable = TRUE
	var/event_announcement = ""

/datum/round_event_control/roundstart/proc/can_spawn_event()
	if(SSticker.current_state != GAME_STATE_PLAYING)
		return FALSE
	return runnable

// Female Transformation event with late join support and complete organ modification

/mob/living/carbon/human/proc/update_shaved_facial_hair()
	// Remove any existing facial hair overlays
	for(var/image/overlay in overlays_standing)
		if(overlay.icon_state == "facial_hair" || overlay.icon_state == "facial_mask")
			overlays_standing -= overlay

	// If facial hairstyle is "Shaved", we don't need to add any new overlays
	if(facial_hairstyle == "Shaved")
		return

	// If facial hairstyle is not "Shaved", add the appropriate facial hair overlays
	var/icon/facial_hair_icon = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "[facial_hairstyle]_s")

	if(facial_hair_icon)
		facial_hair_icon.Blend(facial_hair_color, ICON_ADD)

		var/icon/mask_icon = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "facial_mask")
		if(mask_icon)
			facial_hair_icon.Blend(mask_icon, ICON_MULTIPLY)

		var/image/facial_overlay = image(facial_hair_icon)
		facial_overlay.icon_state = "facial_hair"
		overlays_standing += facial_overlay

	update_icons()

/datum/round_event/roundstart/female_transformation
	var/static/is_active = FALSE
	var/static/list/transformed_ckeys = list()
	
	proc/handle_organs(mob/living/carbon/human/H)
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

	proc/transform_human(mob/living/carbon/human/H)
		if(!H?.mind || H.gender == FEMALE)
			return FALSE
			
		handle_organs(H)
		
		// Gender, voice, and pronoun changes
		H.gender = FEMALE
		H.voice_type = "Feminine"
		H.pronouns = "she/her"
		H.facial_hairstyle = "Shaved"
		
		// Force a full icon update
		H.regenerate_icons()
		H.update_shaved_facial_hair()
		H.update_hair()
		H.update_body()
		H.update_body_parts()
		H.update_mutations_overlay()

		// Force client-side update
		if(H.client)
			addtimer(CALLBACK(H, TYPE_PROC_REF(/atom, update_icon)), 1)
			
		if(H.mind.key)
			transformed_ckeys += H.mind.key
		return TRUE

	proc/apply_effect()
		is_active = TRUE
		
		START_PROCESSING(SSprocessing, src)
		
		var/transformations = 0
		for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
			if(transform_human(H))
				transformations++
				
		if(transformations > 0)
			priority_announce("The Barony was always known as a matriarchy.. [transformations] individuals have been transformed!", "Praise PSYDON!")

	process()
		if(!is_active)
			STOP_PROCESSING(SSprocessing, src)
			return
			
		for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
			if(!H.mind || !H.mind.key)
				continue
			if(H.mind.key in transformed_ckeys)
				continue
			if(transform_human(H))
				priority_announce("[H.real_name] has been transformed by the lingering energies!", "Praise PSYDON!")

/datum/round_event_control/roundstart/female_transformation
	name = "Sisterhood"
	typepath = /datum/round_event/roundstart/female_transformation
	weight = 10
	event_announcement = "The Barony was always known as a matriarchy.."
	runnable = TRUE

// Great Lover event
/datum/round_event/roundstart/great_lover
	proc/apply_effect()
		var/list/valid_lovers = list()
		// Get all minded humans
		for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
			if(H.mind)
				valid_lovers += H
				
		if(!length(valid_lovers))
			return // No valid candidates
			
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
		priority_announce("The stars have aligned... [chosen_lover.real_name] has been blessed as a [chosen_title]!", "Praise PSYDON!")

/datum/round_event_control/roundstart/great_lover
	name = "Great Lover"
	typepath = /datum/round_event/roundstart/great_lover
	weight = 0
	event_announcement = ""  // Removed since we're doing the announcement in apply_effect
	runnable = TRUE

// Throne execution event
/datum/round_event/roundstart/throne_execution
	proc/announce_execution(message, failed = FALSE)
		priority_announce(message, "Official Execution[failed ? " Failed" : ""]")
		// Play decree sound to all living mobs
		for(var/mob/living/L in GLOB.mob_list)
			SEND_SOUND(L, sound('sound/misc/royal_decree.ogg', volume = 100))

	proc/apply_effect()
		// Add throne speech handling to all humans
		for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
			if(H.job in list("Baron", "Baronness"))
				RegisterSignal(H, COMSIG_MOB_SAY, PROC_REF(handle_throne_execution))
		
		// Make all titans announce the execution instructions with sound
		for(var/obj/structure/roguemachine/titan/T in world)
			T.say("Say EXECUTE followed by the criminal's name to destroy them.")
			playsound(T.loc, 'sound/misc/machinetalk.ogg', 50, FALSE)

	// Helper proc to check if someone is immune to execution
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
		var/datum/round_event_control/roundstart/event = event_path
		var/event_name = initial(event.name)
		event_choices[event_name] = event_path

	var/choice = input(usr, "Choose an event to trigger", "Force Roundstart Event") as null|anything in event_choices
	
	if(!choice)
		return
	
	var/event_path = event_choices[choice]
	var/datum/round_event_control/roundstart/chosen_event = new event_path()
	
	// Create and trigger the event
	if(chosen_event)
		var/confirm = alert(usr, "Trigger [chosen_event.name]? \nAnnouncement: [chosen_event.event_announcement]", "Confirm Event", "Yes", "No")
		if(confirm != "Yes")
			return
			
		var/datum/round_event/roundstart/E = new chosen_event.typepath()
		if(E && istype(E))
			if(chosen_event.event_announcement)
				priority_announce(chosen_event.event_announcement, "Praise PSYDON!")
			if(istype(E, /datum/round_event/roundstart/female_transformation))
				var/datum/round_event/roundstart/female_transformation/FT = E
				FT.apply_effect()
			else if(istype(E, /datum/round_event/roundstart/throne_execution))
				var/datum/round_event/roundstart/throne_execution/TE = E
				TE.apply_effect()
			else if(istype(E, /datum/round_event/roundstart/great_lover))
				var/datum/round_event/roundstart/great_lover/GL = E
				GL.apply_effect()
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
		for(var/datum/round_event_control/roundstart/RE in roundstart_events)
			if(RE.can_spawn_event())
				possible_events[RE] = RE.weight
		if(length(possible_events))
			selected_event = pickweight(possible_events)
			return TRUE
		return FALSE

	proc/fire_event()
		if(!selected_event || !selected_event.typepath)
			return

		if(selected_event.event_announcement)
			priority_announce(selected_event.event_announcement, "Praise PSYDON!")
			
		var/datum/round_event/roundstart/E = new selected_event.typepath()
		if(E && istype(E))
			active_events += E
			if(istype(E, /datum/round_event/roundstart/female_transformation))
				var/datum/round_event/roundstart/female_transformation/FT = E
				FT.apply_effect()
			else if(istype(E, /datum/round_event/roundstart/throne_execution))
				var/datum/round_event/roundstart/throne_execution/TE = E
				TE.apply_effect()
			else if(istype(E, /datum/round_event/roundstart/great_lover))
				var/datum/round_event/roundstart/great_lover/GL = E
				GL.apply_effect()

// Define GLOB var
GLOBAL_DATUM(SSroundstart_events, /datum/controller/subsystem/roundstart_events)

// Add roundstart event subsystem initialization
SUBSYSTEM_DEF(roundstart_events)
	name = "Roundstart Events"
	init_order = INIT_ORDER_EVENTS
	flags = SS_NO_FIRE

	Initialize(timeofday)
		if(!GLOB.SSroundstart_events)
			GLOB.SSroundstart_events = src
		return ..()
