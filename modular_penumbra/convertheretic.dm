/datum/job/roguetown/confessor/verb/ConvertToDivine()
    set category = "Inquisition"
    set name = "Convert Heretic"
    var/mob/living/carbon/human/user = usr
    var/obj/item/clothing/neck/roguetown/psicross/g/required_item = null
    var/list/targets = list()
    var/obj/structure/fluff/psycross/near_psycross = null
    for(var/obj/structure/obj in oview(1, user))
        if(istype(obj, /obj/structure/fluff/psycross))
            near_psycross = obj
            break
    if(!near_psycross)
        to_chat(user, "You must be next to a Psicross structure to perform the conversion.")
        return
    for(var/obj/item/I in user.held_items)
        if(istype(I, /obj/item/clothing/neck/roguetown/psicross/g))
            required_item = I
            break
    if(!required_item)
        to_chat(user, "You need a Golden Psicross in your hands to start the conversion.")
        return
    for(var/mob/living/carbon/human/target in oview(1, user))
        if(target != user && istype(target, /mob/living/carbon/human))
            if(target.health <= 0)
                continue
            targets += target
    if(targets.len == 0)
        to_chat(user, "There are no valid targets nearby.")
        return
    var/mob/living/carbon/human/target
    if(targets.len == 1)
        target = targets[1]
    else
        var/list/target_names = list()
        for(var/mob/living/carbon/human/tgt in targets)
            target_names += tgt.name
        var/target_selection = input(user, "Choose a target for the conversion", "Target Selection") as null|anything in target_names
        if(!target_selection)
            return
        target = targets[target_names.Find(target_selection)]
    if(target.health <= 0)
        to_chat(user, "The target is dead and cannot be converted.")
        return
    
    if(istype(target.patron, /datum/patron/divine))
        to_chat(user, "This target is already under divine patronage, the conversion will fail.")
        user.apply_damage(30, BURN)
        qdel(required_item)
        return
    
    var/initial_user_loc = user.loc
    var/initial_target_loc = target.loc
    
    user.visible_message("<span class='notice'>[user] begins the conversion ritual on [target]...</span>")
    
    if(!do_after(user, 300, target = target, extra_checks = CALLBACK(src, .proc/conversion_checks, user, target, initial_user_loc, initial_target_loc)))
        to_chat(user, "<span class='warning'>The conversion ritual has been interrupted!</span>")
        return
        
    target.patron = new /datum/patron/divine/astrata()
    to_chat(target, "<span class='notice'>You have been converted to the true faith!</span>")
    to_chat(user, "<span class='notice'>[target.name] has been converted to the true faith!</span>")
    target.apply_damage(30, BURN)
    to_chat(user, "<span class='notice'>The conversion to the true faith was successful, the target has been converted.</span>")
    qdel(required_item)

/datum/job/roguetown/confessor/proc/conversion_checks(mob/living/carbon/human/user, mob/living/carbon/human/target, initial_user_loc, initial_target_loc)
    if(user.loc != initial_user_loc)
        return FALSE
    if(target.loc != initial_target_loc)
        return FALSE
    if(!user || user.stat || user.health <= 0)
        return FALSE
    if(!target || target.stat || target.health <= 0)
        return FALSE
    return TRUE
