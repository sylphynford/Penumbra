/mob/proc/check_subtler(message, forced)
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
	if(copytext_char(message, 1, 2) == "@")
		emote("subtle", message = copytext_char(message, 2), intentional = !forced, custom_me = TRUE)
		return 1
