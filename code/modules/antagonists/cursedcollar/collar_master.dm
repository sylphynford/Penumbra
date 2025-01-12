/datum/antagonist/collar_master
    name = "Collar Master"
    antagpanel_category = "Other"
    show_in_antagpanel = FALSE
    show_name_in_check_antagonists = FALSE
    var/obj/item/clothing/neck/roguetown/cursed_collar/my_collar
    var/datum/action/innate/collar_control/control_action

/datum/antagonist/collar_master/on_gain()
    . = ..()
    control_action = new
    control_action.Grant(owner.current)

/datum/antagonist/collar_master/on_removal()
    control_action.Remove(owner.current)
    QDEL_NULL(control_action)
    . = ..()

/datum/action/innate/collar_control
    name = "Collar Control"
    icon_icon = 'icons/mob/actions/actions_items.dmi'
    button_icon_state = "collar"
    check_flags = AB_CHECK_CONSCIOUS
    var/listening = FALSE

/datum/action/innate/collar_control/Activate()
    var/datum/antagonist/collar_master/CM = owner.mind.has_antag_datum(/datum/antagonist/collar_master)
    if(!CM || !CM.my_collar || !CM.my_collar.victim)
        return
    
    var/list/options = list()
    options["Scry"] = "scry"
    options[listening ? "Stop Listening" : "Listen"] = "listen"
    options["Shock"] = "shock"
    options["Force Submit"] = "submit"
    
    var/choice = input(owner, "Choose an action:", "Collar Control") as null|anything in options
    if(!choice)
        return
    
    switch(options[choice])
        if("scry")
            var/mob/dead/observer/screye/S = owner.scry_ghost()
            if(S)
                S.ManualFollow(CM.my_collar.victim)
                addtimer(CALLBACK(S, TYPE_PROC_REF(/mob/dead/observer, reenter_corpse)), 8 SECONDS)
        if("listen")
            listening = !listening
            if(listening)
                to_chat(owner, span_notice("You attune your mind to the collar's magic..."))
            else
                to_chat(owner, span_notice("You cease listening through the collar."))
        if("shock")
            to_chat(CM.my_collar.victim, span_danger("The collar sends painful shocks through your body!"))
            CM.my_collar.victim.electrocute_act(15, CM.my_collar, flags = SHOCK_NOGLOVES)
            CM.my_collar.victim.Knockdown(20)
            playsound(CM.my_collar.victim, 'sound/blank.ogg', 50, TRUE)
        if("submit")
            to_chat(CM.my_collar.victim, span_userdanger("The collar sends overwhelming shocks through your body, forcing you to submit!"))
            CM.my_collar.victim.Paralyze(600)
            CM.my_collar.victim.electrocute_act(25, CM.my_collar, flags = SHOCK_NOGLOVES)
            new /obj/effect/temp_visual/surrender(get_turf(CM.my_collar.victim))
            playsound(CM.my_collar.victim, 'sound/blank.ogg', 50, TRUE)
