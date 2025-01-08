#define COMSIG_GLOB_ROUND_END "!glob_round_end"
GLOBAL_LIST_EMPTY(active_roundstart_events)
GLOBAL_DATUM_INIT(SSroundstart_events, /datum/controller/subsystem/roundstart_events, new)

// Base types
/datum/round_event_control/roundstart
	var/runnable = TRUE
	var/event_announcement = ""
	var/selected_event_name = null
	weight = 0

/datum/round_event/roundstart
	var/is_active = FALSE

	proc/apply_effect()
		SHOULD_CALL_PARENT(TRUE)
		GLOB.active_roundstart_events += src
		return

/datum/round_event_control/roundstart/proc/can_spawn_event()
	if(!(SSticker.current_state in list(GAME_STATE_PREGAME, GAME_STATE_SETTING_UP, GAME_STATE_PLAYING)))
		return FALSE
	return runnable


// Spice and Volf event
/datum/round_event/roundstart/spice_and_volf
	var/mob/living/carbon/human/chosen_one = null

/datum/round_event/roundstart/spice_and_volf/apply_effect()
	. = ..()
	is_active = TRUE
	
	var/list/valid_candidates = list()
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(H.mind && !H.mind.special_role)  // Only non-antagonists
			valid_candidates += H
			
	if(!length(valid_candidates))
		return
		
	chosen_one = pick(valid_candidates)
	if(!chosen_one)
		return
	
	// Add werewolf antag datum with custom objective
	var/datum/antagonist/werewolf/W = new()
	chosen_one.mind.add_antag_datum(W)
	
	if(W)
		// Clear default objectives
		W.objectives.Cut()
		
		// Add custom peaceful objective
		var/datum/objective/custom/peaceful_wolf = new
		peaceful_wolf.explanation_text = "Though you are afflicted by the zizonic curse of the wild, you have managed to tame the beast within. With your sanity in tact, you have sworn to use your true form only for good."
		W.objectives += peaceful_wolf
		
		// Get hair color directly from the mob
		var/hair_color = chosen_one.get_hair_color()
		
		// Add or modify tail organ
		var/obj/item/organ/tail/tail
		if(!chosen_one.getorganslot(ORGAN_SLOT_TAIL))
			tail = new()
			tail.Insert(chosen_one, TRUE, FALSE)
		else
			tail = chosen_one.getorganslot(ORGAN_SLOT_TAIL)
		tail.set_accessory_type(/datum/sprite_accessory/tail/wolf)
		tail.accessory_colors = hair_color
		
		// Add or modify ears organ
		var/obj/item/organ/ears/ears
		if(!chosen_one.getorganslot(ORGAN_SLOT_EARS))
			ears = new()
			ears.Insert(chosen_one, TRUE, FALSE)
		else
			ears = chosen_one.getorganslot(ORGAN_SLOT_EARS)
		ears.set_accessory_type(/datum/sprite_accessory/ears/wolf)
		ears.accessory_colors = hair_color
		
		// Wise wolf..
		chosen_one.change_stat("intelligence", 4)
		
		// Update appearance
		chosen_one.update_body()
		chosen_one.regenerate_icons()
		
		// Notify player
		addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, chosen_one, "<span class='userdanger'><font size=5>Though you are afflicted by the zizonic curse of the wild, you have managed to tame the beast within. With your sanity in tact, you have sworn to use your true form only for good.</font></span>"), 10 SECONDS)

/datum/round_event_control/roundstart/spice_and_volf
	name = "Spice and Volf"
	typepath = /datum/round_event/roundstart/spice_and_volf
	weight = 3
	event_announcement = ""
	runnable = TRUE

// Six Sylphs event
/datum/round_event/roundstart/six_sylphs

/datum/round_event/roundstart/six_sylphs/apply_effect()
	. = ..()
	is_active = TRUE
	
	// Find the crown and register signals for equip/unequip
	var/obj/item/clothing/head/roguetown/crown/serpcrown/crown = SSroguemachine.crown
	if(crown)
		RegisterSignal(crown, COMSIG_ITEM_EQUIPPED, PROC_REF(on_crown_equipped))
		RegisterSignal(crown, COMSIG_ITEM_DROPPED, PROC_REF(on_crown_dropped))
		
		// Handle case where someone is already wearing the crown
		if(istype(crown.loc, /mob/living/carbon/human))
			var/mob/living/carbon/human/current_wearer = crown.loc
			if(current_wearer.head == crown)
				apply_protection(current_wearer)
	
	// Register signal for latejoin handling
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_CREATED, PROC_REF(on_mob_created))

/datum/round_event/roundstart/six_sylphs/proc/apply_protection(mob/living/carbon/human/user)
	if(!istype(user))
		return
		
	ADD_TRAIT(user, TRAIT_NODEATH, "six_sylphs")
	ADD_TRAIT(user, TRAIT_NOBREATH, "six_sylphs")
	ADD_TRAIT(user, TRAIT_NODISMEMBER, "six_sylphs")
	ADD_TRAIT(user, TRAIT_NOCRITDAMAGE, "six_sylphs")
	to_chat(user, span_notice("You feel the protection of the six legendary sylphs..."))

/datum/round_event/roundstart/six_sylphs/proc/remove_protection(mob/living/carbon/human/user)
	if(!istype(user))
		return
		
	REMOVE_TRAIT(user, TRAIT_NODEATH, "six_sylphs")
	REMOVE_TRAIT(user, TRAIT_NOBREATH, "six_sylphs")
	REMOVE_TRAIT(user, TRAIT_NODISMEMBER, "six_sylphs")
	REMOVE_TRAIT(user, TRAIT_NOCRITDAMAGE, "six_sylphs")
	to_chat(user, span_warning("The sylphs' protection fades away..."))

/datum/round_event/roundstart/six_sylphs/proc/on_crown_equipped(obj/item/clothing/head/roguetown/crown/serpcrown/source, mob/living/carbon/human/user, slot)
	SIGNAL_HANDLER
	
	if(slot != SLOT_HEAD || !istype(user))
		return
		
	apply_protection(user)

/datum/round_event/roundstart/six_sylphs/proc/on_crown_dropped(obj/item/clothing/head/roguetown/crown/serpcrown/source, mob/living/carbon/human/user)
	SIGNAL_HANDLER
	
	if(!istype(user))
		return
		
	remove_protection(user)

/datum/round_event/roundstart/six_sylphs/proc/on_mob_created(datum/source, mob/M)
	SIGNAL_HANDLER
	
	if(!istype(M, /mob/living/carbon/human))
		return
		
	var/mob/living/carbon/human/H = M
	addtimer(CALLBACK(src, .proc/check_crown_on_spawn, H), 1 SECONDS)

/datum/round_event/roundstart/six_sylphs/proc/check_crown_on_spawn(mob/living/carbon/human/H)
	if(!H || !istype(H.head, /obj/item/clothing/head/roguetown/crown/serpcrown))
		return
		
	apply_protection(H)

/datum/round_event_control/roundstart/six_sylphs
	name = "Six Sylphs"
	typepath = /datum/round_event/roundstart/six_sylphs
	weight = 5
	event_announcement = "The Baron has made a pact with the faefolk - That whoever wears the crown will live forever!"
	runnable = TRUE



// Bintu's Fortune special traits
/datum/special_trait/bintus_blessing
	name = "Bintu's Blessing"
	greet_text = span_notice("You feel particularly fortunate...")
	weight = 0 // Not randomly selectable

/datum/special_trait/bintus_blessing/on_apply(mob/living/carbon/human/character, silent)
	. = ..()
	ADD_TRAIT(character, TRAIT_FORTUNE_BLESSED, ROUNDSTART_TRAIT)

/datum/special_trait/bintus_curse
	name = "Bintu's Curse"
	greet_text = span_warning("Your luck seems to have run out...")
	weight = 0 // Not randomly selectable

/datum/special_trait/bintus_curse/on_apply(mob/living/carbon/human/character, silent)
	. = ..()
	ADD_TRAIT(character, TRAIT_FORTUNE_CURSED, ROUNDSTART_TRAIT)

// Bintu's Fortune event
/datum/round_event/roundstart/bintus_fortune
	var/static/list/blessed_ckeys = list()

/datum/round_event/roundstart/bintus_fortune/apply_effect()
	. = ..()
	is_active = TRUE
	
	// Find bintu and register signals for petting and death
	for(var/mob/living/simple_animal/pet/cat/inn/C in GLOB.mob_list)
		RegisterSignal(C, COMSIG_MOB_PETTED, PROC_REF(on_cat_petted))
		RegisterSignal(C, COMSIG_LIVING_DEATH, PROC_REF(on_cat_death))

/datum/round_event/roundstart/bintus_fortune/proc/on_cat_petted(mob/living/simple_animal/pet/cat/inn/source, mob/living/carbon/human/petter)
	SIGNAL_HANDLER
	
	if(!petter?.mind?.key || (petter.mind.key in blessed_ckeys))
		return
		
	blessed_ckeys += petter.mind.key
	ADD_TRAIT(petter, TRAIT_FORTUNE_BLESSED, "bintus_fortune")
	petter.change_stat("fortune", 1)
	to_chat(petter, span_notice("You feel blessed by Bintu's presence..."))

/datum/round_event/roundstart/bintus_fortune/proc/on_cat_death(mob/living/simple_animal/pet/cat/inn/source)
	SIGNAL_HANDLER
	
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(H.mind?.key in blessed_ckeys)
			REMOVE_TRAIT(H, TRAIT_FORTUNE_BLESSED, "bintus_fortune")
			ADD_TRAIT(H, TRAIT_FORTUNE_CURSED, "bintus_fortune")
			H.change_stat("fortune", -2) // -1 from removing blessing, -1 from curse
			to_chat(H, span_warning("You feel your fortune turn sour as Bintu's blessing fades..."))

/datum/round_event_control/roundstart/bintus_fortune
	name = "Bintu's Fortune"
	typepath = /datum/round_event/roundstart/bintus_fortune
	weight = 5
	event_announcement = "They say Bintu brings good fortune..."
	runnable = TRUE


//no gates event
/datum/round_event/roundstart/drunk_jester

/datum/round_event/roundstart/drunk_jester/apply_effect()
	. = ..()
	is_active = TRUE
	
	var/passages_removed = 0
	// Find all passage bars
	for(var/obj/structure/bars/passage/P in world)
		// Check if this passage has any redstone connections
		if(!length(P.redstone_attached))
			continue
			
		// Check if the passage is in the town area
		var/area/A = get_area(P)
		if(!istype(A, /area/rogue/outdoors/town))
			continue
			
		// Check if any of the attached objects are wall levers
		for(var/obj/structure/lever/wall/L in P.redstone_attached)
			// Found a connected wall lever, delete the passage
			qdel(P)
			passages_removed++
			break

	message_admins("Drunk Jester event: Removed [passages_removed] passage bars in town")

/datum/round_event_control/roundstart/drunk_jester
	name = "Drunk Jester"
	typepath = /datum/round_event/roundstart/drunk_jester
	weight = 5
	event_announcement = "After an accident with a drunk jester, all the gates in town have been destroyed..."
	runnable = TRUE


//great season event
/datum/round_event/roundstart/great_season


/datum/round_event/roundstart/great_season/apply_effect()
	. = ..()
	is_active = TRUE
	
	for(var/type in subtypesof(/datum/plant_def))
		var/datum/plant_def/P = GLOB.plant_defs[type]
		if(!P)
			continue
		// Double minimum yield
		P.produce_amount_min *= 2
		// Double maximum yield
		P.produce_amount_max *= 2
		// Decrease time needed to produce crops
		P.produce_time *= 0.75
		// Decrease nutrition requirements
		P.maturation_nutrition *= 0.8
		P.produce_nutrition *= 0.8

/datum/round_event_control/roundstart/great_season
	name = "Great Season"
	typepath = /datum/round_event/roundstart/great_season
	weight = 5
	event_announcement = "The weather has been perfect for crops this season. Farmers report bountiful yields and faster growth across all farmlands."
	runnable = TRUE



//farming blight event
/datum/round_event/roundstart/blight


/datum/round_event/roundstart/blight/apply_effect()
	. = ..()
	is_active = TRUE
	
	for(var/type in subtypesof(/datum/plant_def))
		var/datum/plant_def/P = GLOB.plant_defs[type]
		if(!P)
			continue
		// Reduce minimum yield but don't let it go below 1
		P.produce_amount_min = max(1, P.produce_amount_min - 2)
		// Reduce maximum yield but don't let it go below minimum
		P.produce_amount_max = max(P.produce_amount_min, P.produce_amount_max - 2)
		// Increase time needed to produce crops
		P.produce_time *= 1.5
		// Increase nutrition requirements
		P.maturation_nutrition *= 1.2
		P.produce_nutrition *= 1.2

/datum/round_event_control/roundstart/blight
	name = "Blight"
	typepath = /datum/round_event/roundstart/blight
	weight = 5
	event_announcement = "The crops seem sickly this season. Farmers report reduced yields and slower growth across all farmlands."
	runnable = TRUE



// Competent Ruler event
/datum/round_event/roundstart/competent_ruler

/datum/round_event/roundstart/competent_ruler/apply_effect()
	. = ..()
	is_active = TRUE
	
	SStreasury.treasury_value *= 7

/datum/round_event_control/roundstart/competent_ruler
	name = "Competent Ruler"
	typepath = /datum/round_event/roundstart/competent_ruler
	weight = 3
	event_announcement = "The Baron's wise investments have greatly increased the treasury's wealth..."
	runnable = TRUE

// Gambling Habit event
/datum/round_event/roundstart/gambling_habit

/datum/round_event/roundstart/gambling_habit/apply_effect()
	. = ..()
	is_active = TRUE
	
	SStreasury.treasury_value = 0

/datum/round_event_control/roundstart/gambling_habit
	name = "Gambling Habit"
	typepath = /datum/round_event/roundstart/gambling_habit
	weight = 3
	event_announcement = "The Baron lost the treasury's wealth in a gambling spree..."
	runnable = TRUE


// Impressive Lineage event
/datum/round_event/roundstart/impressive_lineage

/datum/round_event/roundstart/impressive_lineage/apply_effect()
	. = ..()
	is_active = TRUE
	
	// Apply noble trait to all towners
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(!H.mind?.assigned_role)
			continue
			
		var/datum/job/J = SSjob.GetJob(H.job)
		if(!J || !(J.department_flag & PEASANTS))
			continue
			
		ADD_TRAIT(H, TRAIT_NOBLE, "impressive_lineage_event")

/datum/round_event_control/roundstart/impressive_lineage
	name = "Impressive Lineage"
	typepath = /datum/round_event/roundstart/impressive_lineage
	weight = 5
	event_announcement = "Due to some kind of machinery error, the common folk seem to be recognized as nobles.."
	runnable = TRUE

//event that does nothing to prevent metagaming
/datum/round_event_control/roundstart/nothing
	name = "Nothing happened."
	typepath = /datum/round_event/roundstart/nothing
	weight = 5
	event_announcement = ""
	runnable = TRUE

/datum/round_event/roundstart/nothing/apply_effect()
	. = ..()
	is_active = TRUE
	// This event intentionally does nothing

//Bloodlines event
/datum/round_event/roundstart/noble_vampires
	is_active = FALSE

/datum/round_event/roundstart/noble_vampires/apply_effect()
	. = ..()
	is_active = TRUE
	
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_CREATED, PROC_REF(on_mob_created))
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		make_vampire(H)

/datum/round_event/roundstart/noble_vampires/proc/make_vampire(mob/living/carbon/human/H)
	if(!H.mind?.assigned_role)
		return
		
	var/datum/job/J = SSjob.GetJob(H.mind.assigned_role)
	if(!J || !(J.department_flag & NOBLEMEN))
		return
		
	if(H.mind.has_antag_datum(/datum/antagonist/vampire))
		return
		
	var/datum/antagonist/vampire/new_antag = new()
	new_antag.increase_votepwr = FALSE
	H.mind.add_antag_datum(new_antag)
	to_chat(H, span_userdanger("You are the true masters of the world. But it is imperative you maintain the Masquerade..."))

/datum/round_event/roundstart/noble_vampires/proc/on_mob_created(datum/source, mob/M)
	SIGNAL_HANDLER
	
	if(!is_active || !istype(M, /mob/living/carbon/human))
		return
		
	var/mob/living/carbon/human/H = M
	addtimer(CALLBACK(src, .proc/check_and_convert_noble, H), 1 SECONDS)

/datum/round_event/roundstart/noble_vampires/proc/check_and_convert_noble(mob/living/carbon/human/H)
	if(!H?.mind?.assigned_role)
		return
		
	make_vampire(H)

/datum/round_event_control/roundstart/noble_vampires
	name = "Bloodlines"
	typepath = /datum/round_event/roundstart/noble_vampires
	weight = 3
	event_announcement = ""
	runnable = TRUE


//throne room meeting event
/datum/round_event/roundstart/throne_meeting
	var/min_distance = 3
	var/max_distance = 9
	var/list/all_valid_turfs = list()  // Store all valid turfs
	var/list/available_turfs = list()   // Current pool of available turfs
	var/static/list/valid_jobs = list(
		"Servant", "Squire", "Town Guard", "Dungeoneer", "Priest", 
		"Inquisitor", "Occultist", "Monk", "Churchling", "Merchant",
		"Shophand", "Town Elder", "Blacksmith", "Smithy Apprentice",
		"Artificer", "Soilson", "Tailor", "Innkeeper", "Cook",
		"Bathmaster", "Taven Knave", "Bath Swain", "Bath Wench", "Tavern Wench", "Towner", "Maid", "Vagabond", "Templar"
	)

/datum/round_event/roundstart/throne_meeting/proc/get_valid_turfs(turf/throne_turf)
	var/list/turfs = list()
	for(var/turf/T in range(max_distance, throne_turf))
		if(!istype(T, /turf/open/floor/rogue/tile/masonic/single) && !istype(T, /turf/open/floor/rogue/carpet))
			continue
		if(T.density)
			continue
		var/blocked = FALSE
		for(var/atom/A in T)
			if(A.density)
				blocked = TRUE
				break
		if(blocked)
			continue
		var/distance = get_dist(T, throne_turf)
		if(distance >= min_distance && distance <= max_distance)
			turfs += T
	return turfs

/datum/round_event/roundstart/throne_meeting/proc/refill_available_turfs()
	available_turfs = all_valid_turfs.Copy()
	shuffle_inplace(available_turfs)

/datum/round_event/roundstart/throne_meeting/apply_effect()
	. = ..()
	is_active = TRUE
	
	var/obj/structure/roguethrone/throne = locate(/obj/structure/roguethrone) in world
	if(!throne)
		message_admins("Throne Meeting event failed: No throne found")
		return
		
	all_valid_turfs = get_valid_turfs(get_turf(throne))
	if(!length(all_valid_turfs))
		message_admins("Throne Meeting event failed: No valid turfs found")
		return
	
	// Check if any key holders exist
	var/list/key_holder_jobs = list(
		"Sergeant at Arms",
		"Town Guard",
		"Baron",
		"Baroness",
		"Consort",
		"Knight Lieutenant",
		"Knight Banneret",
		"Servant",
		"Dungeoneer",
		"Squire",
		"Inquisitor"
	)
	
	var/has_key_holders = FALSE
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(H.mind?.assigned_role in key_holder_jobs)
			has_key_holders = TRUE
			break
	
	// If no key holders, spawn manor key
	if(!has_key_holders)
		var/turf/throne_front = get_step(get_turf(throne), SOUTH)
		if(throne_front)
			new /obj/item/roguekey/manor(throne_front)
			message_admins("Throne Meeting: No key holders found, spawned manor key")
	
	refill_available_turfs()
	
	var/teleported_count = 0
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(!H.mind?.assigned_role || !(H.mind.assigned_role in valid_jobs))
			continue
			
		if(!length(available_turfs))
			refill_available_turfs()
			
		var/turf/scatter_loc = pick_n_take(available_turfs)
		H.forceMove(scatter_loc)
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
	name = "Queen's Guard"
	roundend_category = "Queen's Guard"
	antagpanel_category = "Queen's Guard"
	show_in_roundend = TRUE
	
	/datum/antagonist/blackguard/on_gain()
		. = ..()
		if(owner && owner.current)
			to_chat(owner.current, "<span class='warning'><font size=4><B>You are a member of the Queen's Guard. Your loyalty lies with Queen Samantha, rather than the Baron. You have only been instructed to maintain order.</B></font></span>")
			
			if(ishuman(owner.current))
				var/mob/living/carbon/human/H = owner.current
				

				// Update job titles and add Ser title for Guard Captain if needed
				if(H.mind.assigned_role == "Guard Captain")
					H.mind.assigned_role = "Knight Lieutenant"
					H.job = "Knight Lieutenant"
					ADD_TRAIT(H, TRAIT_NOBLE, TRAIT_GENERIC)

					// Add Ser title if not present
					if(!findtext(H.real_name, "Ser ") && !findtext(H.real_name, "Dame "))
						H.real_name = "Ser [H.real_name]"
						H.name = H.real_name
				else if(H.mind.assigned_role == "Huskar")
					H.mind.assigned_role = "Knight Captain"
					H.job = "Knight Captain"
				
				
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
				if(H.mind.assigned_role == "Knight Lieutenant")
					// Lieutenant equipment
					H.equip_to_slot_or_del(new /obj/item/clothing/head/roguetown/helmet/heavy/knight/queensguard(H), SLOT_HEAD)
					H.equip_to_slot_or_del(new /obj/item/clothing/neck/roguetown/chaincoif(H), SLOT_NECK)
					H.equip_to_slot_or_del(new /obj/item/clothing/suit/roguetown/armor/plate(H), SLOT_ARMOR)
					H.equip_to_slot_or_del(new /obj/item/clothing/suit/roguetown/armor/chainmail(H), SLOT_SHIRT)
					H.equip_to_slot_or_del(new /obj/item/clothing/under/roguetown/chainlegs(H), SLOT_PANTS)
					H.equip_to_slot_or_del(new /obj/item/clothing/gloves/roguetown/plate(H), SLOT_GLOVES)
					H.equip_to_slot_or_del(new /obj/item/clothing/wrists/roguetown/bracers(H), SLOT_WRISTS)
					H.equip_to_slot_or_del(new /obj/item/clothing/shoes/roguetown/boots/armor(H), SLOT_SHOES)
					H.equip_to_slot_or_del(new /obj/item/clothing/cloak/cape/knight(H), SLOT_CLOAK)

				else if(H.mind.assigned_role == "Knight Captain")
					// Banneret equipment 
					H.equip_to_slot_or_del(new /obj/item/clothing/head/roguetown/helmet/heavy/knight/queensguard(H), SLOT_HEAD)
					H.equip_to_slot_or_del(new /obj/item/clothing/neck/roguetown/chaincoif(H), SLOT_NECK)
					H.equip_to_slot_or_del(new /obj/item/clothing/suit/roguetown/armor/plate/halfplateroyalguard(H), SLOT_ARMOR)
					H.equip_to_slot_or_del(new /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk(H), SLOT_SHIRT)
					H.equip_to_slot_or_del(new /obj/item/clothing/under/roguetown/platelegs(H), SLOT_PANTS)
					H.equip_to_slot_or_del(new /obj/item/clothing/gloves/roguetown/plate(H), SLOT_GLOVES)
					H.equip_to_slot_or_del(new /obj/item/clothing/wrists/roguetown/bracers(H), SLOT_WRISTS)
					H.equip_to_slot_or_del(new /obj/item/clothing/shoes/roguetown/boots/armor(H), SLOT_SHOES)
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
		if(H.mind.assigned_role in list("Guard Captain", "Huskar"))
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
		
	if(H.mind.assigned_role in list("Guard Captain", "Huskar"))
		H.mind.add_antag_datum(/datum/antagonist/blackguard)

/datum/round_event_control/roundstart/blackguards
	name = "Queen's Guard"
	typepath = /datum/round_event/roundstart/blackguards
	weight = 5
	event_announcement = "With the Baron's finest men slain in battle, he has been forced to rely on reinforcements from the capital, Queen Samantha's Knights. They are only loyal to the Queen, and have been instructed only to maintain order."
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
			to_chat(owner.current, "<span class='warning'><font size=4><B>Enough is enough. You have been offered knighthood by a rival noble family in exchange for betraying the Baron. Prove your loyalty to them by getting revenge on the Baron for their misdeeds..</B></font></span>")
			
	/datum/antagonist/traitor_guard/roundend_report_header()
		return "<span class='header'>A guard turned traitor...</span><br>"
		
	/datum/antagonist/traitor_guard/roundend_report_footer()
		return "<br>The guard's betrayal will be remembered in the annals of history."

/datum/round_event/roundstart/guard_rumors
	var/mob/living/carbon/human/chosen_guard = null
	var/mob/living/carbon/human/target = null
	var/traitor_success = FALSE
	var/announced = FALSE
	var/static/list/valid_jobs = list("Town Guard", "Sergeant at Arms")

/datum/round_event/roundstart/guard_rumors/apply_effect()
	. = ..()
	is_active = TRUE
	
	// 50% chance for nothing to happen
	if(prob(50))
		is_active = FALSE
		return
	
	var/list/possible_guards = list()
	
	// Find valid guards
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(H.mind?.assigned_role in valid_jobs)
			possible_guards += H
	
	if(!length(possible_guards))
		is_active = FALSE
		return
	
	// Pick a random guard
	chosen_guard = pick(possible_guards)
	if(!chosen_guard || !chosen_guard.mind)
		is_active = FALSE
		return
		
	// Create antag datum for objectives
	var/datum/antagonist/traitor_guard/traitor_datum = new()
	chosen_guard.mind.add_antag_datum(traitor_datum)
	
	// Check if there's a consort
	var/mob/living/carbon/human/consort
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(H.mind?.assigned_role == "Consort")
			consort = H
			break
	
	if(consort)
		// Create assassination objective
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = chosen_guard.mind
		kill_objective.target = consort.mind
		kill_objective.explanation_text = "Assassinate [consort.real_name], the Consort, to prove your loyalty to the rival noble family."
		traitor_datum.objectives += kill_objective
	else
		// Create steal objective as fallback
		var/datum/objective/steal/steal_objective = new
		steal_objective.owner = chosen_guard.mind
		steal_objective.steal_target = /obj/item/roguegem/jewel
		steal_objective.explanation_text = "Steal the Baron's Crown Jewel from the treasury."
		traitor_datum.objectives += steal_objective
	
	// Notify the guard of their objective
	to_chat(chosen_guard, "<B>Objective:</B> [traitor_datum.objectives[1].explanation_text]")
	
	RegisterSignal(SSdcs, COMSIG_GLOB_ROUND_END, PROC_REF(check_completion))

/datum/round_event/roundstart/guard_rumors/proc/check_completion()
	if(!chosen_guard || !chosen_guard.mind || announced)
		return
	
	if(SSticker.current_state < GAME_STATE_FINISHED)
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
	
	announced = TRUE
	if(traitorwin)
		chosen_guard.adjust_triumphs(5)
		chosen_guard.playsound_local(get_turf(chosen_guard), 'sound/misc/triumph.ogg', 100, FALSE, pressure_affected = FALSE)
		to_chat(world, "<span class='greentext'>The Traitor Guard has succeeded in their betrayal!</span>")
	else
		chosen_guard.playsound_local(get_turf(chosen_guard), 'sound/misc/fail.ogg', 100, FALSE, pressure_affected = FALSE)
		to_chat(world, "<span class='redtext'>The Traitor Guard has failed in their betrayal!</span>")

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
	
	// Find the Consort and Baron
	var/mob/living/carbon/human/consort
	var/mob/living/carbon/human/baron
	
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(H.mind?.assigned_role == "Consort")
			consort = H
			break
	
	// If the consort is missing, remove this event and try to select another
	if(!consort)
		// Don't set is_active to TRUE since we're aborting
		message_admins("Matriarchy event failed: Missing Consort")
		// Remove this event from active events since we added it in parent call
		GLOB.active_roundstart_events -= src
		// Make the event not runnable for future selections
		for(var/datum/round_event_control/E in SSevents.control)
			if(istype(E, /datum/round_event_control/roundstart/matriarchy))
				var/datum/round_event_control/roundstart/matriarchy/ME = E
				ME.runnable = FALSE
		// Force pick a new event
		GLOB.SSroundstart_events.has_fired = FALSE
		GLOB.SSroundstart_events.pick_roundstart_event()
		GLOB.SSroundstart_events.fire_event()
		return

	is_active = TRUE
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
	var/list/baron_spell_types = list()
	var/list/consort_spell_types = list()
	
	// Store baron's spell types
	if(baron.mind)
		for(var/obj/effect/proc_holder/spell/S in baron.mind.spell_list)
			baron_spell_types += S.type
			baron.mind.RemoveSpell(S)
	
	// Store consort's spell types
	if(consort.mind)
		for(var/obj/effect/proc_holder/spell/S in consort.mind.spell_list)
			consort_spell_types += S.type
			consort.mind.RemoveSpell(S)
	
	// Give baron's spells to consort
	if(consort.mind)
		for(var/spell_type in baron_spell_types)
			consort.mind.AddSpell(new spell_type())
	
	// Give consort's spells to baron
	if(baron.mind)
		for(var/spell_type in consort_spell_types)
			baron.mind.AddSpell(new spell_type())
	
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
	
	// Update SSticker to recognize the consort as ruler
	SSticker.rulermob = consort

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
		addtimer(CALLBACK(H.sexcon, /datum/sex_controller/proc/ejaculate), 0)
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

	// Set permanent nighttime
	GLOB.todoverride = "night"
	
	// Initial sunlight setup
	for(var/obj/effect/sunlight/S in GLOB.sunlights)
		S.light_power = 0
		S.set_light(0)
		STOP_PROCESSING(SStodchange, S)

/datum/round_event_control/roundstart/eternal_night
	name = "Magician's Curse"
	typepath = /datum/round_event/roundstart/eternal_night
	weight = 2
	event_announcement = "The sky has been darkened by inhumen magicks..."
	runnable = TRUE

// Wealthy Benefactor event
/datum/round_event/roundstart/wealthy_benefactor
	var/static/list/rewarded_ckeys = list()
	var/has_processed = FALSE

	/datum/round_event/roundstart/wealthy_benefactor/apply_effect()
		. = ..()
		is_active = TRUE
		addtimer(CALLBACK(src, .proc/choose_target), 2 SECONDS)

	/datum/round_event/roundstart/wealthy_benefactor/proc/choose_target()
		if(has_processed)
			return
		
		has_processed = TRUE
		
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
		// Check for mattcoin
		for(var/obj/item/mattcoin/M in H.GetAllContents())
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


		addtimer(CALLBACK(src, .proc/announce_titan_instructions), 2 SECONDS)

/datum/round_event/roundstart/throne_execution/proc/announce_titan_instructions()
	for(var/obj/structure/roguemachine/titan/T in world)
		T.say("Say EXECUTE followed by the criminal's name while sitting on the throne to destroy them.")
		playsound(T.loc, 'sound/misc/machinetalk.ogg', 100, FALSE)

/datum/round_event_control/roundstart/throne_execution
	name = "Throne Execution Power"
	typepath = /datum/round_event/roundstart/throne_execution
	weight = 2
	event_announcement = "The throne crackles with newfound power.. The Baron could execute anyone with it.."
	runnable = TRUE

// Eternal Day event
/datum/round_event/roundstart/eternal_day

/datum/round_event/roundstart/eternal_day/apply_effect()
	. = ..()
	is_active = TRUE
	
	// Set permanent daytime
	GLOB.todoverride = "day"
	
	// Initial sunlight setup
	for(var/obj/effect/sunlight/S in GLOB.sunlights)
		S.light_power = 1
		S.light_color = pick("#dbbfbf", "#ddd7bd", "#add1b0", "#a4c0ca", "#ae9dc6", "#d09fbf")
		S.set_light(S.brightness)
		STOP_PROCESSING(SStodchange, S)

/datum/round_event_control/roundstart/eternal_day
	name = "Eternal Day"
	typepath = /datum/round_event/roundstart/eternal_day
	weight = 2
	event_announcement = "The sun refuses to set..."
	runnable = TRUE

// Admin verb for managing roundstart events
/client/proc/force_roundstart_event()
	set category = "Admin"
	set name = "Fire Roundstart Event"
	set desc = "Triggers a specific roundstart event"

	if(!check_rights(R_ADMIN))
		return

	var/list/event_choices = list()
	for(var/event_path in subtypesof(/datum/round_event_control/roundstart))
		var/datum/round_event_control/roundstart/event = new event_path()
		if(event.runnable && event.weight > 0)  // Only show events with weight > 0
			event_choices[event.name] = event

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
	var/forced_event_path = null
	var/eternal_night_active = FALSE  // Keep existing variables
	var/is_active = FALSE            // Keep existing variables

	Initialize()
		. = ..()
		for(var/path in subtypesof(/datum/round_event_control/roundstart))
			var/datum/round_event_control/roundstart/RE = new path()
			roundstart_events += RE

		var/datum/callback/cb = CALLBACK(src, .proc/early_round_start)
		if(SSticker.round_start_events)
			SSticker.round_start_events += cb
		else
			SSticker.round_start_events = list(cb)

	proc/early_round_start()
		if(has_fired)
			return
		has_fired = TRUE
		
		if(!pick_roundstart_event())
			message_admins("Failed to pick a roundstart event")
			return
		fire_event()

	proc/pick_roundstart_event()
		selected_event = null
		
		if(forced_event_path)
			var/datum/round_event_control/roundstart/forced = new forced_event_path()
			if(forced?.runnable)
				selected_event = forced
				message_admins("DEBUG: Using forced event: [forced.name]")
				forced_event_path = null
				return TRUE
			
		var/list/possible_events = list()
		for(var/datum/round_event_control/roundstart/RE as anything in roundstart_events)
			if(RE.runnable && RE.can_spawn_event() && RE.weight > 0)
				possible_events[RE] = RE.weight

		if(length(possible_events))
			selected_event = pickweight(possible_events)
			return TRUE
			
		return FALSE

	proc/fire_event()
		if(!selected_event?.typepath)
			return

		var/datum/round_event/roundstart/E = new selected_event.typepath()
		if(E && istype(E))
			active_events += E
			if(selected_event.runnable)
				E.apply_effect()
				if(selected_event.event_announcement && length(selected_event.event_announcement) > 0)
					priority_announce(selected_event.event_announcement, "Arcyne Phenomena")
				GLOB.roundstart_event_name = selected_event.name

/proc/announce_active_events(mob/M)
	if(!M)
		return
	to_chat(M, "<br>")
	for(var/datum/round_event/roundstart/RE in GLOB.active_roundstart_events)
		// Get the control type by looking for a control type with matching typepath
		for(var/control_path in subtypesof(/datum/round_event_control/roundstart))
			var/datum/round_event_control/roundstart/REC = new control_path()
			if(REC.typepath == RE.type)
				if(REC?.event_announcement && REC.event_announcement != "")
					to_chat(M, "<span class='big bold'><font color='purple'>Arcyne Phenomena:</font color><BR>[REC.event_announcement]</span><BR>")
				qdel(REC)
				break
