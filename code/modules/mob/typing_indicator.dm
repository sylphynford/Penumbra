#define TYPING_INDICATOR_LIFETIME 3 * 5

/mob
	var/hud_typing = FALSE //set when typing in an input window instead of chatline
	var/typing
	var/last_typed
	var/last_typed_time

	var/static/mutable_appearance/typing_indicator

/mob/proc/set_typing_indicator(state, hudt)
	if(!typing_indicator)
		typing_indicator = mutable_appearance('icons/mob/talk.dmi', "default0", HUD_LAYER, HUD_PLANE-1)
		typing_indicator.alpha = 175

	if(state)
		if(!typing)
			if(hudt)
				hud_typing = TRUE
			add_overlay(typing_indicator)
			typing = TRUE
			update_vision_cone()
		if(hudt)
			hud_typing = TRUE
	else
		if(typing)
			cut_overlay(typing_indicator)
			typing = FALSE
			hud_typing = FALSE
			update_vision_cone()
	return state

/mob/living/key_down(_key, client/user)
	if(stat == CONSCIOUS)
//		var/list/binds = user.prefs?.key_bindings[_key]
//		if(binds)
/*			if("Say" in binds)
				set_typing_indicator(TRUE, TRUE)
			if("Me" in binds)
				set_typing_indicator(TRUE, TRUE)*/
		if(_key == "M")
			set_typing_indicator(TRUE, TRUE)
		if(_key == ",")
			set_typing_indicator(TRUE, TRUE)
	return ..()

/mob/proc/handle_typing_indicator()
	if(!client || !istype(client))
		set_typing_indicator(FALSE)
		return

	if(isnull(client.mob))
		set_typing_indicator(FALSE)
		return

	if(stat)
		set_typing_indicator(FALSE)
		return

	try
		var/temp = winget(client, "input", "text")
		
		// For me verbs, keep the indicator up while hud_typing is true
		if(hud_typing)
			set_typing_indicator(TRUE)
			return

		// For regular chat
		if(temp != last_typed)  // Only update if the text has changed
			last_typed = temp
			last_typed_time = world.time
			if(temp != "")  // If there's text, show the indicator
				set_typing_indicator(TRUE)
		else if(world.time > last_typed_time + TYPING_INDICATOR_LIFETIME)  // Clear if we haven't typed recently
			set_typing_indicator(FALSE)

	catch
		set_typing_indicator(FALSE)
		return

/mob/Move(NewLoc, direct)
	. = ..()
	if(.)  // If the move succeeded
		set_typing_indicator(FALSE)  // Clear typing indicator when moving


