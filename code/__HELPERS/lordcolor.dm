GLOBAL_LIST_EMPTY(lordcolor)

GLOBAL_VAR(lordprimary)
GLOBAL_VAR(lordsecondary)

/obj/proc/lordcolor(primary,secondary)
	color = primary

/obj/item/clothing/cloak/lordcolor(primary,secondary)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_cloak()


/turf/proc/lordcolor(primary,secondary)
	color = primary

/mob/proc/lord_color_choice()
	if(!client)
		addtimer(CALLBACK(src, PROC_REF(lord_color_choice)), 50)
		return
	var/list/lordcolors = list(
"PURPLE"="#865c9c", //RED AND BLACK
"RED"="#933030", 	//	 I DRESS
"BLACK"="#2f352f", 	//	  EAGLE
"BROWN"="#685542", 	// ON MY CHEST
"GREEN"="#79763f", 	//IT'S GOOD TO BE
"BLUE"="#395480", 	// AN ALBANIAN
"YELLOW"="#b5b004", // KEEP MY HEAD
"TEAL"="#249589", 	//	 UP HIGH
"AZURE"="#007fff", 	// FOR THE FLAG
"WHITE"="#ffffff",	//	  I DIE
"ORANGE"="#b86f0c",	//I'M PROUD TO BE
"MAJENTA"="#962e5c", // AN ALBANIAN
"CUSTOM")
	var/prim
	var/sec
	var/choice = input(src, "Choose a Primary Color", "ROGUETOWN") as anything in lordcolors
	if(choice)
		if(choice == "CUSTOM")
			var/custom_lord_color = color_pick_sanitized_lumi(src, "Custom banner primary color:", "Banner Color")
			if(custom_lord_color)
				prim = "#" + custom_lord_color
		else
			prim = lordcolors[choice]
		lordcolors -= choice
	GLOB.lordprimary = prim
	lordcolors += "CUSTOM"
	choice = input(src, "Choose a Secondary Color", "ROGUETOWN") as anything in lordcolors
	if(choice)
		if(choice == "CUSTOM")
			var/custom_lord_color = color_pick_sanitized_lumi(src, "Custom banner secondary color:", "Banner Color")
			if(custom_lord_color)
				sec = "#" + custom_lord_color
		else
			sec = lordcolors[choice]
	if(!prim || !sec)
		GLOB.lordcolor = list()
		return
	GLOB.lordsecondary = sec
	for(var/obj/O in GLOB.lordcolor)
		O.lordcolor(prim,sec)
		GLOB.lordcolor -= O
	for(var/turf/T in GLOB.lordcolor)
		T.lordcolor(prim,sec)
		GLOB.lordcolor -= T

/proc/lord_color_default()
	GLOB.lordprimary = "#007fff" //AZURE
	GLOB.lordsecondary = "#ffffff" //WHITE
	for(var/obj/O in GLOB.lordcolor)
		O.lordcolor(GLOB.lordprimary,GLOB.lordsecondary)
	for(var/turf/T in GLOB.lordcolor)
		T.lordcolor(GLOB.lordprimary,GLOB.lordsecondary)
