/datum/job/roguetown/mercenary
	title = "Mercenary"
	flag = MERCENARY
	department_flag = MERCENARIES
	faction = "Station"
	total_positions = 5
	spawn_positions = 5
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	tutorial = "Blood stains your hands and the coins you hold. You are a sell-sword, a mercenary, a contractor of war. Where you come from, what you are, who you serve.. none of it matters. What matters is that the mammon flows to your pocket."
	display_order = JDO_MERCENARY
	selection_color = JCOLOR_MERCENARY
	min_pq = 0		//Will be handled by classes if PQ limiting is needed. --But Until then, learn escalation, mercs.
	max_pq = null
	round_contrib_points = 1
	outfit = null	//Handled by classes
	outfit_female = null
	advclass_cat_rolls = list(CTAG_MERCENARY = 20)

/datum/job/roguetown/mercenary/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	..()
	if(L && M?.client)  // Make sure we have both L and a client
		var/mob/living/carbon/human/H = L
		var/list/valid_classes = list()
		var/preferred_class = M.client?.prefs?.mercenary_class

		// Build list of valid classes for this character
		for(var/type in subtypesof(/datum/advclass/mercenary))
			var/datum/advclass/mercenary/AC = new type()
			if(!AC.name)
				qdel(AC)
				continue
			
			// Check if class is allowed for this player
			if(AC.allowed_sexes?.len && !(H.gender in AC.allowed_sexes))
				qdel(AC)
				continue
			if(AC.allowed_races?.len && !(H.dna.species.type in AC.allowed_races))
				qdel(AC)
				continue
			if(AC.min_pq != -100 && !(get_playerquality(M.client.ckey) >= AC.min_pq))
				qdel(AC)
				continue
			
			valid_classes[AC.name] = AC

		// If no valid classes found, something is wrong
		if(!length(valid_classes))
			to_chat(M, span_warning("No valid classes found! Please report this to an admin."))
			return

		var/datum/advclass/mercenary/chosen_class
		if(preferred_class && valid_classes[preferred_class])
			// Use preferred class if it's valid
			chosen_class = valid_classes[preferred_class]
			to_chat(M, span_notice("Using your preferred class: [preferred_class]"))
			// Clean up other classes
			for(var/name in valid_classes)
				if(name != preferred_class)
					qdel(valid_classes[name])
		else
			// Choose random class from valid options
			var/chosen_name = pick(valid_classes)
			chosen_class = valid_classes[chosen_name]
			to_chat(M, span_warning("No class preference set. You have been randomly assigned: [chosen_name]"))
			// Clean up other classes
			for(var/name in valid_classes)
				if(name != chosen_name)
					qdel(valid_classes[name])

		// Let the class handle everything through its own equipme()
		if(chosen_class)
			H.mind?.transfer_to(H) // Ensure mind is properly set up
			chosen_class.equipme(H)
			qdel(chosen_class)
