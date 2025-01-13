#define IRC_STATUS_THROTTLE 5

/datum/tgs_chat_command/ircstatus
	name = "status"
	help_text = "Gets the admincount, playercount, gamemode, and true game mode of the server"
	admin_only = TRUE
	var/last_irc_status = 0

/datum/tgs_chat_command/ircstatus/Run(datum/tgs_chat_user/sender, params)
	var/rtod = REALTIMEOFDAY
	if(rtod - last_irc_status < IRC_STATUS_THROTTLE)
		return
	last_irc_status = rtod
	var/list/adm = get_admin_counts()
	var/list/allmins = adm["total"]
	var/status = "Admins: [allmins.len] (Active: [english_list(adm["present"])] AFK: [english_list(adm["afk"])] Stealth: [english_list(adm["stealth"])] Skipped: [english_list(adm["noflags"])]). "
	status += "Players: [GLOB.clients.len] (Active: [get_active_player_count(0,1,0)]). Mode: [SSticker.mode ? SSticker.mode.name : "Not started"]."
	return status

/datum/tgs_chat_command/irccheck
	name = "check"
	help_text = "Gets the playercount, gamemode, and address of the server"
	var/last_irc_check = 0

/datum/tgs_chat_command/irccheck/Run(datum/tgs_chat_user/sender, params)
	var/rtod = REALTIMEOFDAY
	if(rtod - last_irc_check < IRC_STATUS_THROTTLE)
		return
	last_irc_check = rtod
	var/server = CONFIG_GET(string/server)
	return "[GLOB.round_id ? "Round #[GLOB.round_id]: " : ""][GLOB.clients.len] players on [SSmapping.config.map_name], Mode: [GLOB.master_mode]; Round [SSticker.HasRoundStarted() ? (SSticker.IsRoundInProgress() ? "Active" : "Finishing") : "Starting"] -- [server ? server : "[world.internet_address]:[world.port]"]" 

/datum/tgs_chat_command/ahelp
	name = "ahelp"
	help_text = "<ckey|ticket #> <message|ticket <close|resolve|icissue|reject|reopen <ticket #>|list>>"
	admin_only = TRUE

/datum/tgs_chat_command/ahelp/Run(datum/tgs_chat_user/sender, params)
	var/list/all_params = splittext(params, " ")
	if(all_params.len < 2)
		return "Insufficient parameters"
	var/target = all_params[1]
	all_params.Cut(1, 2)
	var/id = text2num(target)
	if(id != null)
		var/datum/admin_help/AH = GLOB.ahelp_tickets.TicketByID(id)
		if(AH)
			target = AH.initiator_ckey
		else
			return "Ticket #[id] not found!"
	var/res = IrcPm(target, all_params.Join(" "), sender.friendly_name)
	if(res != "Message Successful")
		return res

/datum/tgs_chat_command/namecheck
	name = "namecheck"
	help_text = "Returns info on the specified target"
	admin_only = TRUE

/datum/tgs_chat_command/namecheck/Run(datum/tgs_chat_user/sender, params)
	params = trim(params)
	if(!params)
		return "Insufficient parameters"
	log_admin("Chat Name Check: [sender.friendly_name] on [params]")
	message_admins("Name checking [params] from [sender.friendly_name]")
	return keywords_lookup(params, 1)

/datum/tgs_chat_command/adminwho
	name = "adminwho"
	help_text = "Lists administrators currently on the server"
	admin_only = TRUE

/datum/tgs_chat_command/adminwho/Run(datum/tgs_chat_user/sender, params)
	return ircadminwho()

GLOBAL_LIST(round_end_notifiees)

/datum/tgs_chat_command/endnotify
	name = "endnotify"
	help_text = "Pings the invoker when the round ends"
	admin_only = TRUE

/datum/tgs_chat_command/endnotify/Run(datum/tgs_chat_user/sender, params)
	if(!SSticker.IsRoundInProgress() && SSticker.HasRoundStarted())
		return "[sender.mention], the round has already ended!"
	LAZYINITLIST(GLOB.round_end_notifiees)
	GLOB.round_end_notifiees[sender.mention] = TRUE
	return "I will notify [sender.mention] when the round ends."

/datum/tgs_chat_command/sdql
	name = "sdql"
	help_text = "Runs an SDQL query"
	admin_only = TRUE

/datum/tgs_chat_command/sdql/Run(datum/tgs_chat_user/sender, params)
	if(GLOB.AdminProcCaller)
		return "Unable to run query, another admin proc call is in progress. Try again later."
	GLOB.AdminProcCaller = "CHAT_[sender.friendly_name]"	//_ won't show up in ckeys so it'll never match with a real admin
	var/list/results = world.SDQL2_query(params, GLOB.AdminProcCaller, GLOB.AdminProcCaller)
	GLOB.AdminProcCaller = null
	if(!results)
		return "Query produced no output"
	var/list/text_res = results.Copy(1, 3)
	var/list/refs = results.len > 3 ? results.Copy(4) : null
	. = "[text_res.Join("\n")][refs ? "\nRefs: [refs.Join(" ")]" : ""]"
	
/datum/tgs_chat_command/reload_admins
	name = "reload_admins"
	help_text = "Forces the server to reload admins."
	admin_only = TRUE

/datum/tgs_chat_command/reload_admins/Run(datum/tgs_chat_user/sender, params)
	ReloadAsync()
	log_admin("[sender.friendly_name] reloaded admins via chat command.")
	return "Admins reloaded."

/datum/tgs_chat_command/reload_admins/proc/ReloadAsync()
	set waitfor = FALSE
	load_admins()

GLOBAL_LIST(round_end_role_notifiees)

/datum/tgs_chat_command/endrole
	name = "endrole"
	help_text = "Sets a Discord role to be pinged when the round ends. Usage: endrole <role ID>"
	admin_only = TRUE

/datum/tgs_chat_command/endrole/Run(datum/tgs_chat_user/sender, params)
	if(!params)
		return "Please provide a role ID"
		
	// Clear existing role if no parameters
	if(params == "clear")
		LAZYINITLIST(GLOB.round_end_role_notifiees)
		GLOB.round_end_role_notifiees.Cut()
		return "Cleared all role notifications for round end"

	// Validate that params contains only numbers
	var/regex/number_check = regex(@"^\d+$")
	if(!number_check.Find(params))
		return "Invalid role ID. Please provide only the numeric role ID"

	// Store the role ID
	LAZYINITLIST(GLOB.round_end_role_notifiees) 
	GLOB.round_end_role_notifiees[params] = TRUE
	return "Role <@&[params]> will be notified when the round ends."

GLOBAL_LIST_EMPTY(permanent_round_end_role_notifiees)

/proc/load_round_end_roles()
	var/json_file = file("data/round_end_roles.json")
	if(fexists(json_file))
		var/list/json_data = json_decode(file2text(json_file))
		if(islist(json_data))
			GLOB.permanent_round_end_role_notifiees = json_data.Copy()

/proc/save_round_end_roles()
	var/json_file = file("data/round_end_roles.json")
	if(GLOB.permanent_round_end_role_notifiees)
		fdel(json_file)
		WRITE_FILE(json_file, json_encode(GLOB.permanent_round_end_role_notifiees))

/datum/tgs_chat_command/endrole
	name = "endrole"
	help_text = "Sets a Discord role to be pinged after every round ends. Usage: endrole <role ID>"
	admin_only = TRUE

/datum/tgs_chat_command/endrole/Run(datum/tgs_chat_user/sender, params)
	if(!params)
		return "Please provide a role ID"
		
	// Clear existing roles if requested
	if(params == "clear")
		GLOB.permanent_round_end_role_notifiees = list()
		save_round_end_roles()
		return "Cleared all role notifications for round end"

	// List current roles if requested
	if(params == "list")
		if(!length(GLOB.permanent_round_end_role_notifiees))
			return "No roles are currently set to be pinged at round end"
		var/list/role_list = list()
		for(var/role_id in GLOB.permanent_round_end_role_notifiees)
			role_list += "<@&[role_id]>"
		return "Current round end ping roles: [role_list.Join(", ")]"

	// Validate that params contains only numbers
	var/regex/number_check = regex(@"^\d+$")
	if(!number_check.Find(params))
		return "Invalid role ID. Please provide only the numeric role ID"

	// Remove role if it already exists
	if(params in GLOB.permanent_round_end_role_notifiees)
		GLOB.permanent_round_end_role_notifiees -= params
		save_round_end_roles()
		return "Role <@&[params]> will no longer be notified when rounds end."

	// Add the new role
	GLOB.permanent_round_end_role_notifiees |= params
	save_round_end_roles()
	return "Role <@&[params]> will be notified when rounds end. Use '!tgs endrole list' to see all roles, or '!tgs endrole clear' to remove all roles."
