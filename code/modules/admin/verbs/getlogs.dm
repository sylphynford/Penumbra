//This proc allows download of past server logs saved within the data/logs/ folder.
/client/proc/getserverlogs()
	set name = "Get Server Logs"
	set desc = ""
	set category = "GameMaster"

	browseserverlogs()

/client/proc/getcurrentlogs()
	set name = "Get Current Logs"
	set desc = ""
	set category = "GameMaster"

	browseserverlogs("[GLOB.log_directory]/")

/client/proc/browseserverlogs(path = "data/logs/")
	path = browse_files(path)
	if(!path)
		return

	if(file_spam_check())
		return

	message_admins("[key_name_admin(src)] accessed file: [path]")
	switch(alert("View (in game), Open (in your system's text editor), or Download?", path, "View", "Open", "Download"))
		if ("View")
			src << browse("<pre style='word-wrap: break-word;'>[html_encode(file2text(file(path)))]</pre>", list2params(list("window" = "viewfile.[path]")))
		if ("Open")
			src << run(file(path))
		if ("Download")
			src << ftp(file(path))
		else
			return
	to_chat(src, "Attempting to send [path], this may take a fair few minutes if the file is very large.")
	return

/client/proc/getkeyserverlogs()
	set name = "Get Key Logs"
	set desc = "View logs filtered by a specific ckey"
	set category = "GameMaster"

	var/target_ckey = input(src, "Enter the ckey to search for:", "Search Logs") as text|null
	if(!target_ckey)
		return
	
	target_ckey = lowertext(trim(target_ckey))
	
	// Allow directory navigation until a round directory is selected
	var/path = browse_files("data/logs/", directory_only = TRUE)
	if(!path)
		return

	if(file_spam_check())
		return

	message_admins("[key_name_admin(src)] accessed round logs: [path] searching for ckey: [target_ckey]")
	show_key_logging_panel(target_ckey, "Game Log", path)

/proc/key_logging_panel_link(target_ckey, log_name, current_log, stored_path)
	var/selected = (log_name == current_log) ? "<b>\[[log_name]\]</b>" : "[log_name]"
	return "<a href='?_src_=holder;[HrefToken()];keylog=[target_ckey];log_name=[log_name];stored_path=[stored_path]'>[selected]</a>"

/proc/show_key_logging_panel(target_ckey, current_log = "Game Log", stored_path)
	if(!stored_path)
		return
		
	var/list/dat = list()
	
	dat += "<center><p>Round Logs</p></center>"
	dat += "<center><b>Viewing logs for: [target_ckey]</b></center>"
	dat += "<center><b>From: [stored_path]</b></center>"
	dat += "<hr style='background:#000000; border:0; height:1px'>"
	
	// Log type selection menu
	dat += "<center>"
	dat += key_logging_panel_link(target_ckey, "Game Log", current_log, stored_path)
	dat += " | "
	dat += key_logging_panel_link(target_ckey, "Attack Log", current_log, stored_path)
	dat += " | "
	dat += key_logging_panel_link(target_ckey, "Say Log", current_log, stored_path)
	dat += " | "
	dat += key_logging_panel_link(target_ckey, "Emote Log", current_log, stored_path)
	dat += " | "
	dat += key_logging_panel_link(target_ckey, "Telecomms Log", current_log, stored_path)
	dat += " | "
	dat += key_logging_panel_link(target_ckey, "OOC Log", current_log, stored_path)
	dat += " | "
	dat += key_logging_panel_link(target_ckey, "Admin Log", current_log, stored_path)
	dat += "</center>"
	dat += "<hr style='background:#000000; border:0; height:1px'>"

	// Determine which log file to read based on current_log
	var/log_path
	var/filter_pattern
	switch(current_log)
		if("Game Log")
			log_path = "[stored_path]game.log"
		if("Attack Log")
			log_path = "[stored_path]attack.log"
		if("Say Log")
			log_path = "[stored_path]game.log"
			filter_pattern = "SAY: [target_ckey]/"
		if("Emote Log")
			log_path = "[stored_path]game.log"
			filter_pattern = "EMOTE: [target_ckey]/"
		if("Telecomms Log")
			log_path = "[stored_path]telecomms.log"
		if("OOC Log")
			log_path = "[stored_path]game.log"
			filter_pattern = "OOC: [target_ckey]:"
		if("Admin Log")
			log_path = "[stored_path]game.log"
			filter_pattern = "ADMIN: [target_ckey]"
	
	if(fexists(log_path))
		var/log_content = file2text(file(log_path))
		var/list/filtered_lines = list()
		for(var/line in splittext(log_content, "\n"))
			var/should_show = FALSE
			if(filter_pattern)
				if(findtext(line, filter_pattern))
					should_show = TRUE
			else
				if(findtext(lowertext(line), target_ckey))
					should_show = TRUE
			
			if(should_show)
				filtered_lines += line
		
		if(length(filtered_lines))
			dat += "<font size=2px>"
			// Sort the lines in descending order (newest first)
			sortTim(filtered_lines, cmp = GLOBAL_PROC_REF(cmp_text_dsc))
			for(var/line in filtered_lines)
				// Format each line with bold timestamp
				var/list/split_line = splittext(line, "] ")
				if(length(split_line) >= 2)
					dat += "<b>[split_line[1]]]</b> [split_line[2]]<br>"
				else
					dat += "<b>[line]</b><br>"
			dat += "</font>"
		else
			dat += "<br><center>No entries found for [target_ckey] in [current_log]</center>"
	else
		dat += "<br><center>Log file not found: [log_path]</center>"

	var/datum/browser/popup = new(usr, "keylogviewer_[target_ckey]", "Key Logs - [target_ckey]", 600, 600)
	popup.set_content(dat.Join())
	popup.open()

/client/Topic(href, href_list)
	. = ..()
	if(href_list["keylog"])
		var/target_ckey = href_list["keylog"]
		var/log_name = href_list["log_name"]
		var/stored_path = href_list["stored_path"]
		show_key_logging_panel(target_ckey, log_name, stored_path)

// Helper procs for path manipulation
/proc/dirname(path)
	var/idx = findlasttext(path, "/")
	if(idx)
		return copytext(path, 1, idx)
	return "."

/proc/basename(path)
	var/idx = findlasttext(path, "/")
	if(idx)
		return copytext(path, idx + 1)
	return path
