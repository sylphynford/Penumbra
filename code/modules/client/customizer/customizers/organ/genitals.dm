/datum/customizer/organ/penis
	abstract_type = /datum/customizer/organ/penis
	name = "Penis"
	allows_disabling = TRUE
	default_disabled = TRUE

/datum/customizer/organ/penis/is_allowed(datum/preferences/prefs)
	if(prefs.gender == MALE)
		allows_disabling = FALSE
		default_disabled = FALSE
		return TRUE
	// For females, check if vagina is enabled
	for(var/datum/customizer_entry/entry as anything in prefs.customizer_entries)
		if(istype(entry, /datum/customizer_entry/organ/vagina) && !entry.disabled)
			return FALSE  // Can't enable penis if vagina is enabled
	allows_disabling = TRUE
	default_disabled = FALSE  // Don't force disable for females
	return TRUE

/datum/customizer/organ/penis/validate_entry(datum/preferences/prefs, datum/customizer_entry/entry)
	. = ..()
	// If we're enabling penis
	if(!entry.disabled)
		for(var/datum/customizer_entry/other_entry as anything in prefs.customizer_entries)
			if(istype(other_entry, /datum/customizer_entry/organ/vagina))
				other_entry.disabled = TRUE
				break
	// If we're disabling penis and we're female, enable vagina
	else if(prefs.gender == FEMALE)
		for(var/datum/customizer_entry/other_entry as anything in prefs.customizer_entries)
			if(istype(other_entry, /datum/customizer_entry/organ/vagina))
				other_entry.disabled = FALSE
				break
	// Close latejoin menu and unready when genitals are changed
	if(prefs.parent?.mob)
		prefs.close_latejoin_menu(prefs.parent.mob)

/datum/customizer_choice/organ/penis
	abstract_type = /datum/customizer_choice/organ/penis
	name = "Penis"
	organ_type = /obj/item/organ/penis
	organ_slot = ORGAN_SLOT_PENIS
	organ_dna_type = /datum/organ_dna/penis
	customizer_entry_type = /datum/customizer_entry/organ/penis
	allows_accessory_color_customization = FALSE
	allows_dark_color = FALSE

	proc/is_allowed(datum/preferences/prefs)
		return TRUE

	proc/get_customizer_choice(datum/customizer_entry/entry)
		return CUSTOMIZER_CHOICE(entry.customizer_choice_type)

/datum/customizer_choice/organ/penis/validate_entry(datum/preferences/prefs, datum/customizer_entry/entry)
	..()
	var/datum/customizer_entry/organ/penis/penis_entry = entry
	// Only clamp the preferred size to the chooseable range (12 or 16)
	var/chooseable_max = (prefs.pref_species.id == "tiefling") ? 16.0 : 12.0
	penis_entry.preferred_size = clamp(penis_entry.preferred_size, MIN_PENIS_INCHES, chooseable_max)
	
	var/datum/customizer_choice/customizer_choice = get_customizer_choice(entry)
	if(!customizer_choice.allows_dark_color)
		penis_entry.dark_color = FALSE
	
	// Sync dark color with testicles
	for(var/datum/customizer_entry/other_entry as anything in prefs.customizer_entries)
		if(istype(other_entry, /datum/customizer_entry/organ/testicles))
			var/datum/customizer_entry/organ/testicles/testicles_entry = other_entry
			testicles_entry.dark_color = penis_entry.dark_color
			break

/datum/customizer_choice/organ/penis/imprint_organ_dna(datum/organ_dna/organ_dna, datum/customizer_entry/entry, datum/preferences/prefs)
	..()
	var/datum/organ_dna/penis/penis_dna = organ_dna
	var/datum/customizer_entry/organ/penis/penis_entry = entry
	
	// Check if we're in the preview window
	var/is_preview = winget(prefs.parent, "preferencess_window", "is-visible") == "true"
	
	// Use exact size for previews, roll for actual characters
	if(is_preview)
		penis_dna.penis_size = penis_entry.preferred_size
	else
		penis_dna.penis_size = roll_penis_size(prefs, penis_entry.preferred_size)
	
	var/datum/customizer_choice/customizer_choice = get_customizer_choice(entry)
	if(customizer_choice.allows_dark_color && penis_entry.dark_color)
		var/list/color_sources = color_key_source_list_from_prefs(prefs)
		var/skin_color = color_sources[KEY_SKIN_COLOR]
		// Darken the skin color
		var/darkened_color = BlendRGB(skin_color, "#000000", 0.5)
		organ_dna.accessory_colors = color_list_to_string(list(darkened_color, darkened_color))
	else
		var/datum/sprite_accessory/accessory = SPRITE_ACCESSORY(entry.accessory_type)
		organ_dna.accessory_colors = accessory.get_default_colors(color_key_source_list_from_prefs(prefs))

/datum/customizer_choice/organ/penis/generate_pref_choices(list/dat, datum/preferences/prefs, datum/customizer_entry/entry, customizer_type)
	..()
	var/datum/customizer_entry/organ/penis/penis_entry = entry
	dat += "<br>Preferred size: <a href='?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=preferred_size''>[penis_entry.preferred_size] inches</a>"
	
	var/datum/customizer_choice/customizer_choice = get_customizer_choice(entry)
	if(customizer_choice.allows_dark_color)
		dat += "<br>Pigmented: <a href='?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=dark_color'>[penis_entry.dark_color ? "Yes" : "No"]</a>"

/datum/customizer_choice/organ/penis/handle_topic(mob/user, list/href_list, datum/preferences/prefs, datum/customizer_entry/entry, customizer_type)
	..()
	var/datum/customizer_entry/organ/penis/penis_entry = entry
	switch(href_list["customizer_task"])
		if("preferred_size")
			var/chooseable_max = (prefs.pref_species.id == "tiefling") ? 16.0 : 12.0
			var/new_size = input(user, "Choose your preferred penis size (1.0-[chooseable_max] inches):", "Character Preference", "[penis_entry.preferred_size]") as num|null
			if(isnull(new_size))
				return
			penis_entry.preferred_size = clamp(new_size, MIN_PENIS_INCHES, chooseable_max)
			if(user && istype(user, /mob/dead/new_player))
				var/mob/dead/new_player/NP = user
				if(NP.ready == PLAYER_READY_TO_PLAY)
					NP.ready = PLAYER_NOT_READY
					to_chat(user, span_warning("Your ready status has been reset due to changing genital configuration."))
			prefs.close_latejoin_menu(user)
		if("dark_color")
			var/datum/customizer_choice/customizer_choice = get_customizer_choice(entry)
			if(!customizer_choice.allows_dark_color)
				return
			penis_entry.dark_color = !penis_entry.dark_color
			// Sync dark color with testicles
			for(var/datum/customizer_entry/other_entry as anything in prefs.customizer_entries)
				if(istype(other_entry, /datum/customizer_entry/organ/testicles))
					var/datum/customizer_entry/organ/testicles/testicles_entry = other_entry
					testicles_entry.dark_color = penis_entry.dark_color
					break
			if(user && istype(user, /mob/dead/new_player))
				var/mob/dead/new_player/NP = user
				if(NP.ready == PLAYER_READY_TO_PLAY)
					NP.ready = PLAYER_NOT_READY
					to_chat(user, span_warning("Your ready status has been reset due to changing genital configuration."))
			prefs.close_latejoin_menu(user)

/datum/customizer_entry/organ/penis
	var/dark_color = FALSE
	var/preferred_size = DEFAULT_PENIS_INCHES

/datum/customizer/organ/penis/human
	customizer_choices = list(/datum/customizer_choice/organ/penis/human)

/datum/customizer/organ/penis/anthro
	customizer_choices = list(
		/datum/customizer_choice/organ/penis/human_anthro
	)

/datum/customizer/organ/penis/demihuman
	customizer_choices = list(
		/datum/customizer_choice/organ/penis/human,
		/datum/customizer_choice/organ/penis/knotted
	)

/datum/customizer_choice/organ/penis/human
	name = "Plain Penis"
	organ_type = /obj/item/organ/penis
	sprite_accessories = list(/datum/sprite_accessory/penis/human)
	allows_accessory_color_customization = FALSE
	allows_dark_color = FALSE

/datum/customizer_choice/organ/penis/human_anthro
	name = "Plain Penis"
	organ_type = /obj/item/organ/penis
	sprite_accessories = list(/datum/sprite_accessory/penis/human)
	allows_accessory_color_customization = FALSE
	allows_dark_color = TRUE

/datum/customizer_choice/organ/penis/knotted
	name = "Knotted Penis"
	organ_type = /obj/item/organ/penis/knotted
	sprite_accessories = list(/datum/sprite_accessory/penis/knotted)
	allows_accessory_color_customization = FALSE
	allows_dark_color = FALSE

/datum/customizer_choice/organ/penis/knotted/is_allowed(datum/preferences/prefs)
	return istype(prefs.pref_species, /datum/species/demihuman)

/datum/customizer/organ/testicles
	abstract_type = /datum/customizer/organ/testicles
	name = "Testicles"
	allows_disabling = FALSE
	default_disabled = FALSE
	gender_enabled = null

/datum/customizer/organ/testicles/is_allowed(datum/preferences/prefs)
	// Males should always have testicles if they have a penis
	if(prefs.gender == MALE)
		for(var/datum/customizer_entry/entry as anything in prefs.customizer_entries)
			if(istype(entry, /datum/customizer_entry/organ/penis))
				return !entry.disabled
		return TRUE

	// For non-males, check both penis and vagina status
	var/has_vagina = FALSE
	var/has_enabled_penis = FALSE
	
	for(var/datum/customizer_entry/entry as anything in prefs.customizer_entries)
		if(istype(entry, /datum/customizer_entry/organ/penis) && !entry.disabled)
			has_enabled_penis = TRUE
		if(istype(entry, /datum/customizer_entry/organ/vagina) && !entry.disabled)
			has_vagina = TRUE
	
	return has_enabled_penis && !has_vagina

/datum/customizer_choice/organ/testicles
	abstract_type = /datum/customizer_choice/organ/testicles
	name = "Testicles"
	organ_type = /obj/item/organ/testicles
	organ_dna_type = /datum/organ_dna/testicles
	customizer_entry_type = /datum/customizer_entry/organ/testicles
	organ_slot = ORGAN_SLOT_TESTICLES
	var/can_customize_size = TRUE
	allows_accessory_color_customization = FALSE
	allows_dark_color = FALSE

	proc/get_customizer_choice(datum/customizer_entry/entry)
		return CUSTOMIZER_CHOICE(entry.customizer_choice_type)

/datum/customizer_choice/organ/testicles/validate_entry(datum/preferences/prefs, datum/customizer_entry/entry)
	..()
	var/datum/customizer_entry/organ/testicles/testicles_entry = entry
	testicles_entry.ball_size = sanitize_integer(testicles_entry.ball_size, MIN_TESTICLES_SIZE, MAX_TESTICLES_SIZE, DEFAULT_TESTICLES_SIZE)
	
	var/datum/customizer_choice/customizer_choice = get_customizer_choice(entry)
	if(!customizer_choice.allows_dark_color)
		testicles_entry.dark_color = FALSE
	
	// Sync dark color with penis
	for(var/datum/customizer_entry/other_entry as anything in prefs.customizer_entries)
		if(istype(other_entry, /datum/customizer_entry/organ/penis))
			var/datum/customizer_entry/organ/penis/penis_entry = other_entry
			penis_entry.dark_color = testicles_entry.dark_color
			break

/datum/customizer_choice/organ/testicles/imprint_organ_dna(datum/organ_dna/organ_dna, datum/customizer_entry/entry, datum/preferences/prefs)
	..()
	var/datum/organ_dna/testicles/testicles_dna = organ_dna
	var/datum/customizer_entry/organ/testicles/testicles_entry = entry
	if(can_customize_size)
		testicles_dna.ball_size = testicles_entry.ball_size
	testicles_dna.virility = testicles_entry.virility
	
	var/datum/customizer_choice/customizer_choice = get_customizer_choice(entry)
	if(customizer_choice.allows_dark_color && testicles_entry.dark_color)
		var/list/color_sources = color_key_source_list_from_prefs(prefs)
		var/skin_color = color_sources[KEY_SKIN_COLOR]
		// Darken the skin color
		var/darkened_color = BlendRGB(skin_color, "#000000", 0.5)
		organ_dna.accessory_colors = color_list_to_string(list(darkened_color, darkened_color))
	else
		var/datum/sprite_accessory/accessory = SPRITE_ACCESSORY(entry.accessory_type)
		organ_dna.accessory_colors = accessory.get_default_colors(color_key_source_list_from_prefs(prefs))

/datum/customizer_choice/organ/testicles/generate_pref_choices(list/dat, datum/preferences/prefs, datum/customizer_entry/entry, customizer_type)
	..()
	var/datum/customizer_entry/organ/testicles/testicles_entry = entry
	if(can_customize_size)
		dat += "<br>Ball size: <a href='?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=ball_size''>[find_key_by_value(GLOB.named_ball_sizes, testicles_entry.ball_size)]</a>"
	dat += "<br>Virile: <a href='?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=virile''>[testicles_entry.virility ? "Virile" : "Sterile"]</a>"
	
	var/datum/customizer_choice/customizer_choice = get_customizer_choice(entry)
	if(customizer_choice.allows_dark_color)
		dat += "<br>Pigmented: <a href='?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=dark_color'>[testicles_entry.dark_color ? "Yes" : "No"]</a>"

/datum/customizer_choice/organ/testicles/handle_topic(mob/user, list/href_list, datum/preferences/prefs, datum/customizer_entry/entry, customizer_type)
	..()
	var/datum/customizer_entry/organ/testicles/testicles_entry = entry
	switch(href_list["customizer_task"])
		if("ball_size")
			var/named_size = input(user, "Choose your ball size:", "Character Preference", find_key_by_value(GLOB.named_ball_sizes, testicles_entry.ball_size)) as anything in GLOB.named_ball_sizes
			if(isnull(named_size))
				return
			var/new_size = GLOB.named_ball_sizes[named_size]
			testicles_entry.ball_size = sanitize_integer(new_size, MIN_TESTICLES_SIZE, MAX_TESTICLES_SIZE, DEFAULT_TESTICLES_SIZE)
			if(user && istype(user, /mob/dead/new_player))
				var/mob/dead/new_player/NP = user
				if(NP.ready == PLAYER_READY_TO_PLAY)
					NP.ready = PLAYER_NOT_READY
					to_chat(user, span_warning("Your ready status has been reset due to changing genital configuration."))
			prefs.close_latejoin_menu(user)
		if("virile")
			testicles_entry.virility = !testicles_entry.virility
			if(user && istype(user, /mob/dead/new_player))
				var/mob/dead/new_player/NP = user
				if(NP.ready == PLAYER_READY_TO_PLAY)
					NP.ready = PLAYER_NOT_READY
					to_chat(user, span_warning("Your ready status has been reset due to changing genital configuration."))
			prefs.close_latejoin_menu(user)
		if("dark_color")
			var/datum/customizer_choice/customizer_choice = get_customizer_choice(entry)
			if(!customizer_choice.allows_dark_color)
				return
			testicles_entry.dark_color = !testicles_entry.dark_color
			// Sync dark color with penis
			for(var/datum/customizer_entry/other_entry as anything in prefs.customizer_entries)
				if(istype(other_entry, /datum/customizer_entry/organ/penis))
					var/datum/customizer_entry/organ/penis/penis_entry = other_entry
					penis_entry.dark_color = testicles_entry.dark_color
					break
			if(user && istype(user, /mob/dead/new_player))
				var/mob/dead/new_player/NP = user
				if(NP.ready == PLAYER_READY_TO_PLAY)
					NP.ready = PLAYER_NOT_READY
					to_chat(user, span_warning("Your ready status has been reset due to changing genital configuration."))
			prefs.close_latejoin_menu(user)

/datum/customizer_entry/organ/testicles
	var/ball_size = DEFAULT_TESTICLES_SIZE
	var/virility = TRUE
	var/dark_color = FALSE

/datum/customizer/organ/testicles/external
	customizer_choices = list(/datum/customizer_choice/organ/testicles/external)

/datum/customizer/organ/testicles/human
	customizer_choices = list(/datum/customizer_choice/organ/testicles/human)

/datum/customizer/organ/testicles/anthro
	customizer_choices = list(/datum/customizer_choice/organ/testicles/anthro)

/datum/customizer_choice/organ/testicles/external
	name = "Testicles"
	sprite_accessories = list(/datum/sprite_accessory/testicles/pair)
	allows_accessory_color_customization = FALSE
	allows_dark_color = FALSE

/datum/customizer_choice/organ/testicles/human
	name = "Testicles"
	sprite_accessories = list(/datum/sprite_accessory/testicles/pair)
	allows_accessory_color_customization = FALSE
	allows_dark_color = FALSE

/datum/customizer_choice/organ/testicles/anthro
	name = "Testicles"
	sprite_accessories = list(/datum/sprite_accessory/testicles/pair)
	allows_accessory_color_customization = FALSE
	allows_dark_color = TRUE

/datum/customizer/organ/breasts
	abstract_type = /datum/customizer/organ/breasts
	name = "Breasts"
	allows_disabling = TRUE
	default_disabled = TRUE
	gender_enabled = FEMALE

/datum/customizer/organ/breasts/is_allowed(datum/preferences/prefs)
	return (prefs.gender == FEMALE)

/datum/customizer_choice/organ/breasts
	abstract_type = /datum/customizer_choice/organ/breasts
	name = "Breasts"
	customizer_entry_type = /datum/customizer_entry/organ/breasts
	organ_type = /obj/item/organ/breasts
	organ_slot = ORGAN_SLOT_BREASTS
	organ_dna_type = /datum/organ_dna/breasts

/datum/customizer_choice/organ/breasts/validate_entry(datum/preferences/prefs, datum/customizer_entry/entry)
	..()
	var/datum/customizer_entry/organ/breasts/breasts_entry = entry
	breasts_entry.breast_size = sanitize_integer(breasts_entry.breast_size, MIN_BREASTS_SIZE, MAX_BREASTS_SIZE, DEFAULT_BREASTS_SIZE)

/datum/customizer_choice/organ/breasts/imprint_organ_dna(datum/organ_dna/organ_dna, datum/customizer_entry/entry, datum/preferences/prefs)
	..()
	var/datum/organ_dna/breasts/breasts_dna = organ_dna
	var/datum/customizer_entry/organ/breasts/breasts_entry = entry
	breasts_dna.breast_size = breasts_entry.breast_size
	breasts_dna.lactating = breasts_entry.lactating

/datum/customizer_choice/organ/breasts/generate_pref_choices(list/dat, datum/preferences/prefs, datum/customizer_entry/entry, customizer_type)
	..()
	var/datum/customizer_entry/organ/breasts/breasts_entry = entry
	dat += "<br>Breast size: <a href='?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=breast_size''>[find_key_by_value(GLOB.named_breast_sizes, breasts_entry.breast_size)]</a>"
	dat += "<br>Lactation: <a href='?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=lactating''>[breasts_entry.lactating ? "Enabled" : "Disabled"]</a>"

/datum/customizer_choice/organ/breasts/handle_topic(mob/user, list/href_list, datum/preferences/prefs, datum/customizer_entry/entry, customizer_type)
	..()
	var/datum/customizer_entry/organ/breasts/breasts_entry = entry
	switch(href_list["customizer_task"])
		if("breast_size")
			var/named_size = input(user, "Choose your breast size:", "Character Preference", find_key_by_value(GLOB.named_breast_sizes, breasts_entry.breast_size)) as anything in GLOB.named_breast_sizes
			if(isnull(named_size))
				return
			var/new_size = GLOB.named_breast_sizes[named_size]
			breasts_entry.breast_size = sanitize_integer(new_size, MIN_BREASTS_SIZE, MAX_BREASTS_SIZE, DEFAULT_BREASTS_SIZE)
			if(user && istype(user, /mob/dead/new_player))
				var/mob/dead/new_player/NP = user
				if(NP.ready == PLAYER_READY_TO_PLAY)
					NP.ready = PLAYER_NOT_READY
					to_chat(user, span_warning("Your ready status has been reset due to changing genital configuration."))
			prefs.close_latejoin_menu(user)
		if("lactating")
			breasts_entry.lactating = !breasts_entry.lactating
			if(user && istype(user, /mob/dead/new_player))
				var/mob/dead/new_player/NP = user
				if(NP.ready == PLAYER_READY_TO_PLAY)
					NP.ready = PLAYER_NOT_READY
					to_chat(user, span_warning("Your ready status has been reset due to changing genital configuration."))
			prefs.close_latejoin_menu(user)

/datum/customizer_entry/organ/breasts
	var/breast_size = DEFAULT_BREASTS_SIZE
	var/lactating = FALSE

/datum/customizer/organ/breasts/human
	customizer_choices = list(/datum/customizer_choice/organ/breasts/human)

/datum/customizer_choice/organ/breasts/human
	sprite_accessories = list(/datum/sprite_accessory/breasts/pair)
	allows_accessory_color_customization = FALSE

/datum/customizer/organ/breasts/animal
	customizer_choices = list(/datum/customizer_choice/organ/breasts/animal)


/datum/customizer_choice/organ/breasts/animal
	sprite_accessories = list(
		/datum/sprite_accessory/breasts/pair,
		)
	allows_accessory_color_customization = FALSE

/datum/customizer/organ/vagina
	abstract_type = /datum/customizer/organ/vagina
	name = "Vagina"
	allows_disabling = TRUE
	default_disabled = TRUE
	gender_enabled = FEMALE

/datum/customizer/organ/vagina/is_allowed(datum/preferences/prefs)
	if(prefs.gender == MALE)
		return FALSE
	if(prefs.gender == FEMALE)
		allows_disabling = TRUE
		default_disabled = FALSE
		return TRUE
	for(var/datum/customizer_entry/entry as anything in prefs.customizer_entries)
		if(istype(entry, /datum/customizer_entry/organ/penis))
			return entry.disabled
	return TRUE

/datum/customizer/organ/vagina/validate_entry(datum/preferences/prefs, datum/customizer_entry/entry)
	. = ..()
	// If we're enabling vagina
	if(!entry.disabled)
		for(var/datum/customizer_entry/other_entry as anything in prefs.customizer_entries)
			if(istype(other_entry, /datum/customizer_entry/organ/penis))
				other_entry.disabled = TRUE
				break
	// If we're disabling vagina
	else
		for(var/datum/customizer_entry/other_entry as anything in prefs.customizer_entries)
			if(istype(other_entry, /datum/customizer_entry/organ/penis))
				other_entry.disabled = FALSE
				break
	// Close latejoin menu and unready when genitals are changed
	if(prefs.parent?.mob)
		prefs.close_latejoin_menu(prefs.parent.mob)

/datum/customizer_choice/organ/vagina
	abstract_type = /datum/customizer_choice/organ/vagina
	name = "Vagina"
	customizer_entry_type = /datum/customizer_entry/organ/vagina
	organ_type = /obj/item/organ/vagina
	organ_slot = ORGAN_SLOT_VAGINA
	organ_dna_type = /datum/organ_dna/vagina

/datum/customizer_entry/organ/vagina
	var/fertility = TRUE

/datum/customizer_choice/organ/vagina/imprint_organ_dna(datum/organ_dna/organ_dna, datum/customizer_entry/entry, datum/preferences/prefs)
	..()
	var/datum/organ_dna/vagina/vagina_dna = organ_dna
	var/datum/customizer_entry/organ/vagina/vagina_entry = entry
	vagina_dna.fertility = vagina_entry.fertility

/datum/customizer_choice/organ/vagina/generate_pref_choices(list/dat, datum/preferences/prefs, datum/customizer_entry/entry, customizer_type)
	..()
	var/datum/customizer_entry/organ/vagina/vagina_entry = entry
	dat += "<br>Fertile: <a href='?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=fertile''>[vagina_entry.fertility ? "Fertile" : "Sterile"]</a>"

/datum/customizer_choice/organ/vagina/handle_topic(mob/user, list/href_list, datum/preferences/prefs, datum/customizer_entry/entry, customizer_type)
	..()
	var/datum/customizer_entry/organ/vagina/vagina_entry = entry
	switch(href_list["customizer_task"])
		if("fertile")
			vagina_entry.fertility = !vagina_entry.fertility
			if(user && istype(user, /mob/dead/new_player))
				var/mob/dead/new_player/NP = user
				if(NP.ready == PLAYER_READY_TO_PLAY)
					NP.ready = PLAYER_NOT_READY
					to_chat(user, span_warning("Your ready status has been reset due to changing genital configuration."))
			prefs.close_latejoin_menu(user)

/datum/customizer/organ/vagina/human
	customizer_choices = list(/datum/customizer_choice/organ/vagina/human)

/datum/customizer_choice/organ/vagina/human
	sprite_accessories = list(
		/datum/sprite_accessory/vagina/human,
		/datum/sprite_accessory/vagina/hairy,
		)
	allows_accessory_color_customization = FALSE

/datum/customizer/organ/vagina/human_anthro
	customizer_choices = list(/datum/customizer_choice/organ/vagina/human_anthro)

/datum/customizer_choice/organ/vagina/human_anthro
	sprite_accessories = list(
		/datum/sprite_accessory/vagina/human,
		/datum/sprite_accessory/vagina/hairy,
		)
	allows_accessory_color_customization = TRUE

/datum/customizer/organ/vagina/animal
	customizer_choices = list(/datum/customizer_choice/organ/vagina/animal)

/datum/customizer_choice/organ/vagina/animal
	sprite_accessories = list(
		/datum/sprite_accessory/vagina/human,
		/datum/sprite_accessory/vagina/hairy,
		)
	allows_accessory_color_customization = FALSE

/datum/customizer/organ/vagina/anthro
	customizer_choices = list(/datum/customizer_choice/organ/vagina/anthro)

/datum/customizer_choice/organ/vagina/anthro
	sprite_accessories = list(
		/datum/sprite_accessory/vagina/human,
		/datum/sprite_accessory/vagina/gaping,
		/datum/sprite_accessory/vagina/hairy,
		/datum/sprite_accessory/vagina/spade,
		/datum/sprite_accessory/vagina/furred,
		/datum/sprite_accessory/vagina/cloaca,
		)

/datum/customizer_choice/organ/penis/proc/roll_penis_size(datum/preferences/prefs, preferred = DEFAULT_PENIS_INCHES)
	// Get species-appropriate max size for the final roll
	var/max_size = (prefs.pref_species.id == "tiefling") ? MAX_PENIS_INCHES_TIEFLING : MAX_PENIS_INCHES
	
	// Roll for variance between -1.5 and +1.5 inches
	var/variance = (rand(-15, 15) * 0.1) // Generates -1.5 to +1.5 in 0.1 increments
	
	// Apply variance to preferred size and clamp to the maximum possible size
	return CLAMP(preferred + variance, MIN_PENIS_INCHES, max_size)
