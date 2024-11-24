#define COMSIG_GLOB_ROUND_END "!glob_round_end"

GLOBAL_DATUM_INIT(SSroundstart_events, /datum/controller/subsystem/roundstart_events, new)

// Base types
/datum/round_event_control/roundstart
	var/runnable = TRUE
	var/event_announcement = ""
	var/selected_event_name = null

/datum/round_event/roundstart
	var/is_active = FALSE

	proc/apply_effect()
		SHOULD_CALL_PARENT(TRUE)
		return

/datum/round_event_control/roundstart/proc/can_spawn_event()
	if(!(SSticker.current_state in list(GAME_STATE_PREGAME, GAME_STATE_SETTING_UP, GAME_STATE_PLAYING)))
		return FALSE
	return runnable


//throne room meeting event
/datum/round_event/roundstart/throne_meeting
    var/min_distance = 3
    var/max_distance = 9
    var/static/list/valid_jobs = list(
        "Servant", "Squire", "Town Guard", "Dungeoneer", "Priest", 
        "Inquisitor", "Templar", "Acolyte", "Churchling", "Merchant",
        "Shophand", "Town Elder", "Blacksmith", "Smithy Apprentice",
        "Artificer", "Soilson", "Tailor", "Innkeeper", "Cook",
        "Bathmaster", "Taven Knave", "Bath Swain", "Towner", "Vagabond"
    )

/datum/round_event/roundstart/throne_meeting/apply_effect()
    . = ..()
    is_active = TRUE
    
    var/obj/structure/roguethrone/throne = locate(/obj/structure/roguethrone) in world
    if(!throne)
        message_admins("Throne Meeting event failed: No throne found")
        return
        
    // Get all valid spawn points around the throne
    var/list/valid_turfs = list()
    var/turf/throne_turf = get_turf(throne)
    
    for(var/turf/T in range(max_distance, throne_turf))
        // Skip if not the right type of floor
        if(!istype(T, /turf/open/floor/rogue/tile/masonic/single) && !istype(T, /turf/open/floor/rogue/carpet))
            continue
            
        // Skip if blocked
        if(T.density)
            continue
            
        // Check for dense objects
        var/blocked = FALSE
        for(var/atom/A in T)
            if(A.density)
                blocked = TRUE
                break
        if(blocked)
            continue
            
        // Check distance
        var/distance = get_dist(T, throne_turf)
        if(distance >= min_distance && distance <= max_distance)
            valid_turfs += T
                
    if(!length(valid_turfs))
        message_admins("Throne Meeting event failed: No valid turfs found")
        return
        
    // Teleport valid job holders
    var/teleported_count = 0
    for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
        if(!H.mind?.assigned_role || !(H.mind.assigned_role in valid_jobs))
            continue
            
        if(length(valid_turfs))
            var/turf/scatter_loc = pick(valid_turfs)
            H.forceMove(scatter_loc)
            valid_turfs -= scatter_loc
            teleported_count++
    
    message_admins("Throne Meeting event: Teleported [teleported_count] players")

/datum/round_event_control/roundstart/throne_meeting
    name = "Throne Meeting"
    typepath = /datum/round_event/roundstart/throne_meeting
    weight = 5
    event_announcement = "There is an important meeting in the throne room..."
    runnable = TRUE

//Blackguards event

/datum/antagonist/blackguard
	name = "Blackguard"
	roundend_category = "blackguards"
	antagpanel_category = "Blackguard"
	antag_moodlet = /datum/mood_event/focused
	show_in_roundend = TRUE
	
	/datum/antagonist/blackguard/on_gain()
		. = ..()
		if(owner && owner.current)
			to_chat(owner.current, "<span class='warning'><B>You are a Blackguard mercenary. Your loyalties lie with coin rather than honor.</B></span>")
			
			if(ishuman(owner.current))
				var/mob/living/carbon/human/H = owner.current
				
				// Remove honorary title (Ser/Dame)
				var/new_name = H.real_name
				new_name = replacetext(new_name, "Ser ", "")
				new_name = replacetext(new_name, "Dame ", "")
				H.real_name = new_name
				H.name = new_name
				
				// Update job titles
				if(H.mind.assigned_role == "Knight Lieutenant")
					H.mind.assigned_role = "Blackguard Lieutenant"
					H.job = "Blackguard Lieutenant"
				else if(H.mind.assigned_role == "Knight Banneret")
					H.mind.assigned_role = "Blackguard Banneret"
					H.job = "Blackguard Banneret"
				
				// Cancel adventurer setup
				H.advsetup = FALSE
				H.invisibility = 0
				var/atom/movable/screen/advsetup/GET_IT_OUT = locate() in H.hud_used.static_inventory
				qdel(GET_IT_OUT)
				H.cure_blind("advsetup")
				
				// Only apply skills and stats to Lieutenants
				if(H.mind.assigned_role == "Blackguard Lieutenant")
					H.mind.adjust_skillrank(/datum/skill/combat/polearms, 3, TRUE)
					H.mind.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)
					H.mind.adjust_skillrank(/datum/skill/combat/shields, 4, TRUE)
					H.mind.adjust_skillrank(/datum/skill/combat/maces, 4, TRUE)
					H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
					H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
					H.mind.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
					H.mind.adjust_skillrank(/datum/skill/misc/swimming, 1, TRUE)
					H.mind.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
					H.mind.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
					H.mind.adjust_skillrank(/datum/skill/misc/riding, 4, TRUE)
					
					H.change_stat("strength", 3)
					H.change_stat("endurance", 2)
					H.change_stat("constitution", 3)
					H.change_stat("intelligence", 1)
					H.change_stat("speed", 1)
				
				H.dna.species.soundpack_m = new /datum/voicepack/male/knight()
				
				// Equipment handling
				if(H.head) qdel(H.head)
				if(H.wear_neck) qdel(H.wear_neck)
				if(H.wear_armor) qdel(H.wear_armor)
				if(H.wear_shirt) qdel(H.wear_shirt)
				if(H.wear_pants) qdel(H.wear_pants)
				if(H.gloves) qdel(H.gloves)
				if(H.wear_wrists) qdel(H.wear_wrists)
				if(H.shoes) qdel(H.shoes)
				if(H.cloak) qdel(H.cloak)
				if(H.backl) qdel(H.backl)
				
				// Equipment based on role
				if(H.mind.assigned_role == "Blackguard Lieutenant")
					// Lieutenant equipment
					H.equip_to_slot_or_del(new /obj/item/clothing/head/roguetown/helmet/heavy/knight/black(H), SLOT_HEAD)
					H.equip_to_slot_or_del(new /obj/item/clothing/neck/roguetown/chaincoif(H), SLOT_NECK)
					H.equip_to_slot_or_del(new /obj/item/clothing/suit/roguetown/armor/plate/blkknight/death(H), SLOT_ARMOR)
					H.equip_to_slot_or_del(new /obj/item/clothing/suit/roguetown/armor/chainmail(H), SLOT_SHIRT)
					H.equip_to_slot_or_del(new /obj/item/clothing/under/roguetown/chainlegs/blk(H), SLOT_PANTS)
					H.equip_to_slot_or_del(new /obj/item/clothing/gloves/roguetown/plate/blk(H), SLOT_GLOVES)
					H.equip_to_slot_or_del(new /obj/item/clothing/wrists/roguetown/bracers(H), SLOT_WRISTS)
					H.equip_to_slot_or_del(new /obj/item/clothing/shoes/roguetown/boots/armor/blk(H), SLOT_SHOES)
					H.equip_to_slot_or_del(new /obj/item/clothing/cloak/tabard/blkknight(H), SLOT_CLOAK)
					H.equip_to_slot_or_del(new /obj/item/gwstrap(H), SLOT_BACK_L)
					H.put_in_active_hand(new /obj/item/rogueweapon/greatsword/zwei)
					// Lieutenant-specific traits
					ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
					ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)
					ADD_TRAIT(H, TRAIT_GUARDSMAN, TRAIT_GENERIC)
				else if(H.mind.assigned_role == "Blackguard Banneret")
					// Banneret equipment - lighter armor variant
					H.equip_to_slot_or_del(new /obj/item/clothing/head/roguetown/helmet/blacksteel/bucket(H), SLOT_HEAD)
					H.equip_to_slot_or_del(new /obj/item/clothing/neck/roguetown/chaincoif(H), SLOT_NECK)
					H.equip_to_slot_or_del(new /obj/item/clothing/suit/roguetown/armor/blacksteel/platechest(H), SLOT_ARMOR)
					H.equip_to_slot_or_del(new /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk(H), SLOT_SHIRT)
					H.equip_to_slot_or_del(new /obj/item/clothing/under/roguetown/blacksteel/platelegs(H), SLOT_PANTS)
					H.equip_to_slot_or_del(new /obj/item/clothing/gloves/roguetown/blacksteel/plategloves(H), SLOT_GLOVES)
					H.equip_to_slot_or_del(new /obj/item/clothing/wrists/roguetown/bracers(H), SLOT_WRISTS)
					H.equip_to_slot_or_del(new /obj/item/clothing/shoes/roguetown/boots/blacksteel/plateboots(H), SLOT_SHOES)
					H.equip_to_slot_or_del(new /obj/item/clothing/cloak/cape/blkknight(H), SLOT_CLOAK)
					H.equip_to_slot_or_del(new /obj/item/rogueweapon/sword/long/blackflamb(H), SLOT_BACK_L)

/datum/round_event/roundstart/blackguards/apply_effect()
	. = ..()
	is_active = TRUE
	convert_existing_knights()
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_CREATED, PROC_REF(on_mob_created))


/datum/round_event/roundstart/blackguards/proc/convert_existing_knights()
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(!H.mind?.assigned_role)
			continue
			
		// Check for original knight roles
		if(H.mind.assigned_role in list("Knight Lieutenant", "Knight Banneret"))
			H.mind.add_antag_datum(/datum/antagonist/blackguard)

/datum/round_event/roundstart/blackguards/proc/on_mob_created(datum/source, mob/M)
	SIGNAL_HANDLER
	
	if(!is_active || !istype(M, /mob/living/carbon/human))
		return
		
	var/mob/living/carbon/human/H = M
	addtimer(CALLBACK(src, .proc/check_and_convert_knight, H), 1 SECONDS)

/datum/round_event/roundstart/blackguards/proc/check_and_convert_knight(mob/living/carbon/human/H)
	if(!H?.mind?.assigned_role)
		return
		
	if(H.mind.assigned_role in list("Knight Lieutenant", "Knight Banneret"))
		H.mind.add_antag_datum(/datum/antagonist/blackguard)

/datum/round_event_control/roundstart/blackguards
	name = "Blackguards"
	typepath = /datum/round_event/roundstart/blackguards
	weight = 5
	event_announcement = "With the Baron's finest knights slain in battle, he has been forced to hire Blackguard mercenaries to lead his forces. They are less loyal, but their skill and cruelty is well proven.."
	runnable = TRUE


//Traitor guard event
/datum/antagonist/traitor_guard
	name = "Traitor Guard"
	roundend_category = "traitor guards"
	antagpanel_category = "Traitor Guard"
	job_rank = "Town Guard"
	antag_moodlet = /datum/mood_event/focused
	show_in_roundend = TRUE
	
	var/triumph_points = 5 // Points awarded for success
	
	/datum/antagonist/traitor_guard/on_gain()
		. = ..()
		if(owner && owner.current)
			to_chat(owner.current, "<span class='warning'><B>Enough is enough. You have been offered knighthood by a rival noble family in exchange for betraying the Baron. Prove your loyalty to them by getting revenge on the Baron for their misdeeds..</B></span>")
			
	/datum/antagonist/traitor_guard/roundend_report_header()
		return "<span class='header'>A guard turned traitor...</span><br>"
		
	/datum/antagonist/traitor_guard/roundend_report_footer()
		return "<br>The guard's betrayal will be remembered in the annals of history."

/datum/round_event/roundstart/guard_rumors
	var/static/list/valid_jobs = list("Town Guard", "Sergeant at Arms")
	var/mob/living/carbon/human/chosen_guard = null
	var/mob/living/carbon/human/target = null

/datum/round_event/roundstart/guard_rumors/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_ROUND_END, PROC_REF(check_completion))

/datum/round_event/roundstart/guard_rumors/apply_effect()
	. = ..()
	is_active = TRUE
	
	// 50% chance for nothing to happen
	if(prob(50))
		return
	
	var/list/possible_guards = list()
	var/mob/living/carbon/human/consort = null
	
	// Find valid guards and consort
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(H.mind?.assigned_role in valid_jobs)
			possible_guards += H
		else if(H.mind?.assigned_role == "Consort")
			consort = H
	
	if(!length(possible_guards))
		return
	
	// Pick a random guard
	chosen_guard = pick(possible_guards)
	if(!chosen_guard || !chosen_guard.mind)
		return
		
	// Create antag datum for objectives
	var/datum/antagonist/traitor_guard/traitor_datum = new()
	chosen_guard.mind.add_antag_datum(traitor_datum)
	
	// Add traitor objective
	if(consort && !consort.stat == DEAD)
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = chosen_guard.mind
		kill_objective.target = consort.mind
		kill_objective.explanation_text = "Assassinate [consort.real_name], the Consort."
		traitor_datum.objectives += kill_objective
	else
		var/datum/objective/steal/steal_objective = new
		steal_objective.owner = chosen_guard.mind
		steal_objective.steal_target = /obj/item/roguegem/jewel
		steal_objective.explanation_text = "Steal the Baron's Crown Jewel from the treasury."
		traitor_datum.objectives += steal_objective
	
	// Notify the guard of their objective
	to_chat(chosen_guard, "<B>Objective:</B> [traitor_datum.objectives[1].explanation_text]")

/datum/round_event/roundstart/guard_rumors/proc/check_completion()
	if(!chosen_guard || !chosen_guard.mind)
		return
	
	var/datum/antagonist/traitor_guard/traitor_datum = chosen_guard.mind.has_antag_datum(/datum/antagonist/traitor_guard)
	if(!traitor_datum)
		return
		
	var/traitorwin = TRUE
	for(var/datum/objective/objective in traitor_datum.objectives)
		if(istype(objective, /datum/objective/steal))
			var/datum/objective/steal/steal_objective = objective
			if(!steal_objective.check_completion())
				traitorwin = FALSE
				break
		else if(!objective.check_completion())
			traitorwin = FALSE
			break
	
	if(traitorwin)
		chosen_guard.adjust_triumphs(5)
		to_chat(world, "<span class='greentext'>The Traitor Guard has succeeded in their betrayal!</span>")
		chosen_guard.playsound_local(get_turf(chosen_guard), 'sound/misc/triumph.ogg', 100, FALSE, pressure_affected = FALSE)
	else
		to_chat(world, "<span class='redtext'>The Traitor Guard has failed in their betrayal!</span>")
		chosen_guard.playsound_local(get_turf(chosen_guard), 'sound/misc/fail.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/round_event_control/roundstart/guard_rumors
	name = "Guard Rumors"
	typepath = /datum/round_event/roundstart/guard_rumors
	weight = 10
	event_announcement = "Rumors have swirled that one of the guards may be a traitor... Or perhaps it's just a rumor."
	runnable = TRUE


// Matriarchy event
/datum/round_event/roundstart/matriarchy

/datum/round_event/roundstart/matriarchy/apply_effect()
	. = ..()
	is_active = TRUE
	
	var/mob/living/carbon/human/baron
	var/mob/living/carbon/human/consort
	
	// Find the Baron and Consort
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(H.mind?.assigned_role == "Baron" || H.mind?.assigned_role == "Baroness")
			baron = H
		else if(H.mind?.assigned_role == "Consort")
			consort = H
	
	if(!baron || !consort)
		return
	
	// Store their locations
	var/turf/baron_loc = get_turf(baron)
	var/turf/consort_loc = get_turf(consort)
	
	// Close any open color choice menus for the baron
	if(baron.client)
		baron.client << browse(null, "window=color_choice")
		baron.client << browse(null, "window=Banner Color")
	
	// Swap their positions
	baron.forceMove(consort_loc)
	consort.forceMove(baron_loc)
	
	// Update Consort's title and name
	consort.job = "Consort-Regnant"
	
	// Swap their spells
	var/list/baron_spells = list()
	var/list/consort_spells = list()
	
	// Store baron's spells
	if(baron.mind)
		baron_spells = baron.mind.spell_list.Copy()
		for(var/obj/effect/proc_holder/spell/S in baron_spells)
			baron.mind.RemoveSpell(S)
	
	// Store consort's spells
	if(consort.mind)
		consort_spells = consort.mind.spell_list.Copy()
		for(var/obj/effect/proc_holder/spell/S in consort_spells)
			consort.mind.RemoveSpell(S)
	
	// Give baron's spells to consort
	for(var/obj/effect/proc_holder/spell/S in baron_spells)
		if(consort.mind)
			consort.mind.AddSpell(S)
	
	// Give consort's spells to baron
	for(var/obj/effect/proc_holder/spell/S in consort_spells)
		if(baron.mind)
			baron.mind.AddSpell(S)
	
	// Transfer crown
	var/obj/item/clothing/head/crown = baron.get_item_by_slot(SLOT_HEAD)
	if(istype(crown, /obj/item/clothing/head/roguetown/crown/serpcrown))
		baron.dropItemToGround(crown)
		if(consort.head)
			qdel(consort.head)
		consort.equip_to_slot_or_del(crown, SLOT_HEAD)
	
	// Transfer cloak
	var/obj/item/clothing/cloak = baron.get_item_by_slot(SLOT_CLOAK)
	if(istype(cloak, /obj/item/clothing/cloak/lordcloak))
		baron.dropItemToGround(cloak)
		if(consort.cloak)
			qdel(consort.cloak)
		consort.equip_to_slot_or_del(cloak, SLOT_CLOAK)
	
	// Give new scepter directly to consort
	var/obj/item/rogueweapon/lordscepter/new_scepter = new(get_turf(consort))
	consort.put_in_hands(new_scepter)
	
	// Delete any existing scepter the baron might have
	for(var/obj/item/rogueweapon/lordscepter/old_scepter in baron.GetAllContents())
		qdel(old_scepter)
	
	// Give the color choice to the consort instead
	addtimer(CALLBACK(consort, TYPE_PROC_REF(/mob, lord_color_choice)), 50)

/datum/round_event_control/roundstart/matriarchy
	name = "Regnant"
	typepath = /datum/round_event/roundstart/matriarchy
	weight = 5
	event_announcement = "The crown passes to the Consort in a rare recognizance of ancient law..."
	runnable = TRUE



//Militia event

/datum/component/militia_blessing
	var/applied = TRUE

/datum/component/militia_blessing/Initialize()
	. = ..()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

/datum/round_event/roundstart/militia
	var/static/list/weapon_skills = list(
		/obj/item/rogueweapon/sword/short = /datum/skill/combat/swords,
		/obj/item/rogueweapon/mace/cudgel = /datum/skill/combat/maces,
		/obj/item/rogueweapon/spear = /datum/skill/combat/polearms,
		/obj/item/rogueweapon/stoneaxe/woodcut/steel = /datum/skill/combat/axes
	)

	var/static/list/basic_weapons = list(
		/obj/item/rogueweapon/sword/short,
		/obj/item/rogueweapon/mace/cudgel,
		/obj/item/rogueweapon/spear,
		/obj/item/rogueweapon/stoneaxe/woodcut/steel
	)

/datum/round_event/roundstart/militia/apply_effect()
	. = ..()
	is_active = TRUE
	bless_existing_players()
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_CREATED, PROC_REF(on_mob_created))

/datum/round_event/roundstart/militia/proc/on_mob_created(datum/source, mob/M)
	SIGNAL_HANDLER
	
	if(!is_active || !istype(M, /mob/living/carbon/human))
		return
		
	var/mob/living/carbon/human/H = M
	addtimer(CALLBACK(src, .proc/check_and_bless_peasant, H), 1 SECONDS)

/datum/round_event/roundstart/militia/proc/check_and_bless_peasant(mob/living/carbon/human/H)
	if(!H?.mind?.assigned_role)
		return
		
	if(!H.GetComponent(/datum/component/militia_blessing))
		apply_blessing(H)

/datum/round_event/roundstart/militia/proc/apply_blessing(mob/living/carbon/human/H)
	if(!H || !H.mind || !H.job)
		return FALSE
	
	var/datum/job/J = SSjob.GetJob(H.job)
	if(!J || !(J.department_flag & PEASANTS))
		return FALSE

	// Give random basic weapon and increase its related skill
	var/weapon_type = pick(basic_weapons)
	var/obj/item/weapon = new weapon_type(get_turf(H))
	H.put_in_hands(weapon)
	
	// Increase the specific weapon skill
	var/skill_type = weapon_skills[weapon_type]
	if(skill_type)
		H.mind.adjust_skillrank(skill_type, 2, TRUE)
	
	// Always increase these basic combat skills
	H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)

	// Increase stats
	H.change_stat("strength", 1)
	H.change_stat("endurance", 1)
	H.change_stat("constitution", 1)
	
	// Add militia blessing component
	H.AddComponent(/datum/component/militia_blessing)

/datum/round_event/roundstart/militia/proc/bless_existing_players()
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(!H?.mind?.assigned_role)
			continue
			
		var/datum/job/J = SSjob.GetJob(H.job)
		if(!J || !(J.department_flag & PEASANTS))
			continue
			
		if(!H.GetComponent(/datum/component/militia_blessing))
			apply_blessing(H)

/datum/round_event_control/roundstart/militia
	name = "Militia"
	typepath = /datum/round_event/roundstart/militia
	weight = 5
	event_announcement = "The common folk have been drilled ruthlessly by the Baron into an organized militia.."
	runnable = TRUE


// Funky Water event
/datum/round_event/roundstart/funky_water/apply_effect()
	. = ..()
	is_active = TRUE
	RegisterSignal(SSdcs, COMSIG_REAGENT_WATER_CONSUMED, PROC_REF(on_water_consumed))

/datum/round_event/roundstart/funky_water/proc/on_water_consumed(datum/source, mob/living/carbon/human/H, amount)
	SIGNAL_HANDLER
	
	if(!is_active || !H?.client || !H.sexcon)
		return
		
	H.sexcon.set_arousal(H.sexcon.arousal + 0.5)
	if(H.sexcon.arousal >= 100 && H.sexcon.can_ejaculate())
		H.sexcon.ejaculate()
		H.sexcon.set_arousal(0)

/datum/round_event_control/roundstart/funky_water
	name = "Funky Water"
	typepath = /datum/round_event/roundstart/funky_water
	weight = 5
	event_announcement = "Something is wrong with the water supply..."
	runnable = TRUE

// Eternal Night event
/datum/round_event/roundstart/eternal_night

/datum/round_event/roundstart/eternal_night/apply_effect()
	. = ..()
	is_active = TRUE

	// Disable sunlight system
	for(var/obj/effect/sunlight/S in GLOB.sunlights)
		S.light_power = 0
		S.set_light(0)  // Just use set_light with brightness 0
		STOP_PROCESSING(SStodchange, S)

	// Prevent nightshift system from re-enabling lights
	GLOB.SSroundstart_events.eternal_night_active = TRUE
	START_PROCESSING(SSprocessing, src)

/datum/round_event/roundstart/eternal_night/process()
	if(!is_active)
		STOP_PROCESSING(SSprocessing, src)
		return

	// Continuously ensure lights stay disabled
	for(var/obj/effect/sunlight/S in GLOB.sunlights)
		if(S.light_power != 0)
			S.light_power = 0
			S.set_light(0)
			STOP_PROCESSING(SStodchange, S)

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
	transform_existing_players()
	START_PROCESSING(SSprocessing, src)

/datum/round_event/roundstart/female_transformation/process()
	if(!is_active)
		STOP_PROCESSING(SSprocessing, src)
		return
	transform_new_players()

/datum/round_event/roundstart/female_transformation/proc/transform_existing_players()
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		transform_human(H)

/datum/round_event/roundstart/female_transformation/proc/transform_new_players()
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(!H.mind?.key || (H.mind.key in transformed_ckeys))
			continue
		transform_human(H)

/datum/round_event/roundstart/female_transformation/proc/transform_human(mob/living/carbon/human/H)
	if(!H || !H.mind?.key || (H.mind.key in transformed_ckeys))
		return FALSE

	// Only transform males
	if(H.gender != MALE)
		return FALSE

	H.gender = FEMALE
	H.voice_type = "Feminine"
	H.pronouns = "she/her"
	// Update title/name
	var/prev_real_name = H.real_name

	// Convert male titles to female equivalents
	var/new_name = prev_real_name
	if(findtext(new_name, "Ser "))
		new_name = replacetext(new_name, "Ser ", "Dame ")
	else if(findtext(new_name, "Lord "))
		new_name = replacetext(new_name, "Lord ", "Lady ")
	else if(findtext(new_name, "King "))
		new_name = replacetext(new_name, "King ", "Queen ")
	else if(findtext(new_name, "Baron "))
		new_name = replacetext(new_name, "Baron ", "Baroness ")

	H.real_name = new_name
	H.name = new_name

	// Remove male organs and add female ones
	var/obj/item/organ/penis = H.getorganslot(ORGAN_SLOT_PENIS)
	if(penis)
		penis.Remove(H)
		qdel(penis)

	var/obj/item/organ/testicles = H.getorganslot(ORGAN_SLOT_TESTICLES)
	if(testicles)
		testicles.Remove(H)
		qdel(testicles)

	if(!H.getorganslot(ORGAN_SLOT_VAGINA))
		var/obj/item/organ/vagina/V = new
		V.Insert(H, TRUE)

	if(!H.getorganslot(ORGAN_SLOT_BREASTS))
		var/obj/item/organ/breasts/B = new
		B.Insert(H, TRUE)

	// Update appearance
	H.update_body()
	H.update_body_parts()
	H.regenerate_icons()
	H.regenerate_clothes()

	transformed_ckeys += H.mind.key


	return TRUE

/datum/round_event_control/roundstart/female_transformation
	name = "Sisterhood"
	typepath = /datum/round_event/roundstart/female_transformation
	weight = 0
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
	weight = 10
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
			if(H.job in list("Baron", "Baroness"))
				RegisterSignal(H, COMSIG_MOB_SAY, PROC_REF(handle_throne_execution))

		// Make all titans announce the execution instructions with sound
		for(var/obj/structure/roguemachine/titan/T in world)
			T.say("Say EXECUTE followed by the criminal's name while sitting on the throne to destroy them.")
			playsound(T.loc, 'sound/misc/machinetalk.ogg', 50, FALSE)

/datum/round_event_control/roundstart/throne_execution
	name = "Throne Execution Power"
	typepath = /datum/round_event/roundstart/throne_execution
	weight = 5
	event_announcement = "The throne crackles with newfound power..."
	runnable = TRUE

// Eternal Day event
/datum/round_event/roundstart/eternal_day

/datum/round_event/roundstart/eternal_day/apply_effect()
	. = ..()
	is_active = TRUE
	
	// Keep sunlight bright
	for(var/obj/effect/sunlight/S in GLOB.sunlights)
		S.light_power = 1
		S.light_color = pick("#dbbfbf", "#ddd7bd", "#add1b0", "#a4c0ca", "#ae9dc6", "#d09fbf")
		S.set_light(S.brightness)
		STOP_PROCESSING(SStodchange, S)
	
	START_PROCESSING(SSprocessing, src)

/datum/round_event/roundstart/eternal_day/process()
	if(!is_active)
		STOP_PROCESSING(SSprocessing, src)
		return

	// Continuously ensure lights stay bright
	for(var/obj/effect/sunlight/S in GLOB.sunlights)
		if(S.light_power != 1 || S.light_color in list("#100a18", "#0c0412", "#0f0012", "#c26f56", "#c05271", "#b84933", "#394579", "#49385d", "#3a1537"))
			S.light_power = 1
			S.light_color = pick("#dbbfbf", "#ddd7bd", "#add1b0", "#a4c0ca", "#ae9dc6", "#d09fbf")
			S.set_light(S.brightness)
			STOP_PROCESSING(SStodchange, S)

/datum/round_event_control/roundstart/eternal_day
	name = "Eternal Day"
	typepath = /datum/round_event/roundstart/eternal_day
	weight = 5
	event_announcement = "The sun refuses to set..."
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

/datum/controller/subsystem/roundstart_events
	name = "Roundstart Events"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_EVENTS - 10

	var/list/datum/round_event_control/roundstart/roundstart_events = list()
	var/datum/round_event_control/roundstart/selected_event
	var/has_fired = FALSE
	var/list/active_events = list()
	var/eternal_night_active = FALSE

	Initialize()
		. = ..()
		for(var/path in subtypesof(/datum/round_event_control/roundstart))
			var/datum/round_event_control/roundstart/RE = new path()
			roundstart_events += RE

		// Create callback for ticker setup
		var/datum/callback/cb = CALLBACK(src, .proc/early_round_start)
		if(SSticker.round_start_events)
			SSticker.round_start_events += cb
		else
			SSticker.round_start_events = list(cb)

	proc/early_round_start()
		pick_roundstart_event()
		fire_event()

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

		var/datum/round_event/roundstart/E = new selected_event.typepath()
		if(E && istype(E))
			active_events += E
			if(selected_event.runnable)
				E.apply_effect()
				if(selected_event.event_announcement && length(selected_event.event_announcement) > 0)
					priority_announce(selected_event.event_announcement, "Arcyne Phenomena")

				// Store the event name globally
				GLOB.roundstart_event_name = selected_event.name


