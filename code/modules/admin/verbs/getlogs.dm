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
	var/first_letter = copytext(target_ckey, 1, 2)
	
	// Allow directory navigation starting from the player's log directory
	var/base_path = "data/logs/player_logs/[first_letter]/[target_ckey]/"
	var/path = browse_files(base_path)
	if(!path)
		return

	if(file_spam_check())
		return

	message_admins("[key_name_admin(src)] accessed player logs: [path] for ckey: [target_ckey]")
	show_key_logging_panel(target_ckey, "All Logs", path)

/proc/key_logging_panel_link(target_ckey, log_name, current_log, stored_path)
	var/selected = (log_name == current_log) ? "<b>\[[log_name]\]</b>" : "[log_name]"
	return "<a href='?_src_=holder;[HrefToken()];keylog=[target_ckey];log_name=[log_name];stored_path=[stored_path]'>[selected]</a>"

/proc/show_key_logging_panel(target_ckey, current_log = "All Logs", stored_path)
	if(!stored_path || !fexists(stored_path))
		return
		
	var/list/dat = list()
	
	dat += "<center><p>Round Logs</p></center>"
	dat += "<center><b>Viewing logs for: [target_ckey]</b></center>"
	dat += "<center><b>From: [stored_path]</b></center>"
	dat += "<hr style='background:#000000; border:0; height:1px'>"
	
	// Log type selection menu
	dat += "<center>"
	dat += key_logging_panel_link(target_ckey, "All Logs", current_log, stored_path)
	dat += " | "
	dat += key_logging_panel_link(target_ckey, "Attack Log", current_log, stored_path)
	dat += " | "
	dat += key_logging_panel_link(target_ckey, "Say Log", current_log, stored_path)
	dat += " | "
	dat += key_logging_panel_link(target_ckey, "Emote Log", current_log, stored_path)
	dat += " | "
	dat += key_logging_panel_link(target_ckey, "OOC Log", current_log, stored_path)
	dat += " | "
	dat += key_logging_panel_link(target_ckey, "Admin Log", current_log, stored_path)
	dat += "</center>"
	dat += "<hr style='background:#000000; border:0; height:1px'>"

	var/log_content = file2text(file(stored_path))
	var/list/filtered_lines = list()
	var/filter_pattern
	
	switch(current_log)
		if("Attack Log")
			filter_pattern = "ATTACK:"
		if("Say Log")
			filter_pattern = "SAY:"
		if("Emote Log")
			filter_pattern = "EMOTE:"
		if("OOC Log")
			filter_pattern = "OOC:"
		if("Admin Log")
			filter_pattern = "ADMIN:"
	
	for(var/line in splittext(log_content, "\n"))
		if(!filter_pattern || findtext(line, filter_pattern))
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

/proc/write_key_logs_for_round(target_ckey)
	if(!target_ckey)
		return
	
	target_ckey = lowertext(trim(target_ckey))
	
	// Create the directory structure with alphabetical subfolder
	var/realtime = world.realtime
	var/date_string = time2text(realtime, "YYYY/MM/DD")
	var/first_letter = copytext(target_ckey, 1, 2)
	var/log_directory = "data/logs/player_logs/[first_letter]/[target_ckey]/[date_string]"
	
	// Create base directories if they don't exist
	if(!fexists("data/logs/player_logs"))
		var/F = file("data/logs/player_logs/.keep")
		WRITE_FILE(F, "")
	
	if(!fexists("data/logs/player_logs/[first_letter]"))
		var/F = file("data/logs/player_logs/[first_letter]/.keep")
		WRITE_FILE(F, "")
	
	if(!fexists("data/logs/player_logs/[first_letter]/[target_ckey]"))
		var/F = file("data/logs/player_logs/[first_letter]/[target_ckey]/.keep")
		WRITE_FILE(F, "")
	
	if(!fexists(log_directory))
		var/F = file("[log_directory]/.keep")
		WRITE_FILE(F, "")

	// Gather all logs for this player
	var/list/all_logs = list()
	
	// Check each log type
	var/list/log_types = list(
		"Game Log" = "game.log",
		"Attack Log" = "attack.log",
		"Say Log" = "say.log",
		"OOC Log" = "ooc.log",
		"Telecomms Log" = "telecomms.log",
		"PDA Log" = "pda.log",
		"Mecha Log" = "mecha.log",
		"Admin Log" = "admin.log"
	)
	
	for(var/log_type in log_types)
		var/log_file = "[GLOB.log_directory]/[log_types[log_type]]"
		if(fexists(log_file))
			var/log_content = file2text(file(log_file))
			var/list/lines = splittext(log_content, "\n")
			for(var/line in lines)
				if(findtext(lowertext(line), target_ckey))
					all_logs += line
	
	// Sort logs by timestamp
	sortTim(all_logs, cmp = GLOBAL_PROC_REF(cmp_text_dsc))
	
	// Write to file
	if(length(all_logs))
		var/final_path = "[log_directory]/round_[GLOB.rogue_round_id].log"
		var/F = file(final_path)
		fdel(F)
		WRITE_FILE(F, all_logs.Join("\n"))

/world/proc/write_all_key_logs()
	for(var/client/C in GLOB.clients)
		if(C.ckey)
			write_key_logs_for_round(C.ckey)
