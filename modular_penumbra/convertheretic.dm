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
    var/datum/patron/target_patron = target.patron
    if(target_patron && target_patron == /datum/patron/divine)
        to_chat(user, "This target is already under divine patronage, the conversion will fail.")
        user.apply_damage(30, BURN)
        target.apply_damage(30, BURN)
        qdel(required_item)
        return
    target.patron = new /datum/patron/divine/astrata()
    to_chat(target, "You have been converted to the true faith!")
    to_chat(user, "[target.name] has been converted to the true faith!")
    target.apply_damage(30, BURN)
    to_chat(user, "The conversion to the true faith was successful, the target has been converted.")
    qdel(required_item)
