#define REL_TYPE_SPOUSE 1
#define REL_TYPE_SIBLING 2
#define REL_TYPE_PARENT 3
#define REL_TYPE_OFFSPRING 4
#define REL_TYPE_RELATIVE 5

#define MATCH_FAIL_SPECIES 1
#define MATCH_FAIL_SEX 2
#define MATCH_FAIL_GENDER 3
#define MATCH_FAIL_AGE 4
SUBSYSTEM_DEF(family)
	name = "family"


	var/list/families = list()
	var/list/used_names = list()
	var/list/used_titles = list()

	var/list/relative_types = list()

	var/list/rel_images = list()

	var/family_candidates = list()

	var/list/special_role_blacklist = list(ROLE_LICH,"Vampire Lord") //Special roles that're prevented from having families.

/datum/controller/subsystem/family/fire() //update family icons.
	var/list/old_images = rel_images.Copy()
	for(var/i in old_images)
		var/image/I = i
		I.loc = null
		qdel(I)

	rel_images.Cut()
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		for(var/mob/living/carbon/human/HH in GLOB.mob_list)
			if(HH == H)
				continue
			if(H.isFamily(HH))
				var/datum/relation/R = H.getRelationship(HH)
				if(!R)
					continue
				var/image/I = image('icons/mob/rel.dmi',HH,icon_state=R.rel_state)
				I.appearance_flags = RESET_TRANSFORM
				H << I
				rel_images += I


/datum/controller/subsystem/family/proc/makeFamily(var/mob/living/carbon/human/head,var/name)
	var/i = 0
	while(!name || used_names.Find(name))
		i++
		name = pick(strings("family.json","prefix")) + "-" + pick(strings("family.json","title"))
		if(i == 100)
			name += " the [pick("ill","unfortunate")] lucked" //fallback on the impossible chance it CANNOT make a unique name.

	var/datum/family/F = new()
	F.name = name
	used_names += name
	F.addMember(head)

	return F

/datum/controller/subsystem/family/proc/DoSetSpouse()
	var/list/players = GLOB.player_list.Copy()
	var/list/grouped = list()
	var/list/grouping = list()
	for(var/mob/living/carbon/human/H in players)
		if(grouped.Find(H))
			continue
		if(H.client.prefs.spouse)
			for(var/mob/living/carbon/human/S in GLOB.player_list) //Find the spouse.
				if(S.key == H.client.prefs.spouse && S.client.prefs.spouse == H.key) //Check if they also have H as a spouse.
					grouping.Add(list(list(H,S)))
					grouped += S

	for(var/l in grouping)
		var/list/group = l
		if(length(group) < 2)
			continue
		var/mob/living/carbon/human/head //For consistency, we set the head to be the person with a dick.
		var/mob/living/carbon/human/partner
		for(var/c in group)
			var/mob/living/carbon/human/H = c
			if(H.getorganslot(ORGAN_SLOT_PENIS))
				head = H

		group -= head
		partner = group[1]

		//done here so both parties can receive the fail message.
		if(head.family || partner.family)
			to_chat(head,span_warning("Setspouse failed. [head.family ? "You already have" : "Your spouse already has"] a family."))
			to_chat(partner,span_warning("Setspouse failed. [partner.family ? "You already have" : "Your spouse already has"] a family."))
			continue

		var/head_blacklist = SSjob.GetJob(head.job).family_blacklisted
		var/partner_blacklist = SSjob.GetJob(partner.job).family_blacklisted
		if(head_blacklist || partner_blacklist)
			to_chat(head,span_warning("Setspouse failed. [head_blacklist ? "Your" : "Your spouse's"] role cannot be in a family."))
			to_chat(partner,span_warning("Setspouse failed. [partner_blacklist ? "Your" : "Your spouse's"] role cannot be in a family."))
			continue

		var/datum/family/F = makeFamily(head)
		if(F.checkFamilyCompat(partner, head, REL_TYPE_SPOUSE) && F.checkFamilyCompat(head, partner, REL_TYPE_SPOUSE))
			F.addMember(partner)
			F.addRel(partner, head, REL_TYPE_SPOUSE, TRUE)
			F.addRel(head, partner, REL_TYPE_SPOUSE, TRUE)
		else
			for(var/c in list(head,partner))
				switch(F.match_fail)
					if(MATCH_FAIL_SPECIES)
						to_chat(c,span_warning("Setspouse failed. Character's races were incompatible with selected preferences."))
					if(MATCH_FAIL_SEX)
						to_chat(c,span_warning("Setspouse failed. incompatible sexes."))
					if(MATCH_FAIL_GENDER)
						to_chat(c,span_warning("Setspouse failed. incompatible gender."))
					if(MATCH_FAIL_AGE)
						to_chat(c,span_warning("Setspouse failed. incompatible age."))
			qdel(F)

/datum/controller/subsystem/family/proc/SetupFamilies()
	if(!length(family_candidates))
		return

	var/list/current_families = list()
	var/list/head_candidates = list()
	var/list/remaining_candidates = list()

	// Get initial head candidates
	for(var/c in family_candidates)
		var/mob/living/carbon/human/H = c
		if(H.getorganslot(ORGAN_SLOT_PENIS))
			head_candidates += H
		else
			remaining_candidates += H

	// Shuffle both lists for randomness
	head_candidates = shuffle(head_candidates)
	remaining_candidates = shuffle(remaining_candidates)

	// Try to match each head with one candidate
	while(length(head_candidates) && length(remaining_candidates))
		var/mob/living/carbon/head = pick(head_candidates)
		var/datum/family/F = makeFamily(head)
		current_families += F
		head_candidates -= head

		// Try to find ONE match for this head
		for(var/mob/living/carbon/human/H in remaining_candidates)
			var/rel_type = F.tryConnect(H, head)
			if(F.checkFamilyCompat(H, head, rel_type) && F.checkFamilyCompat(head, H, rel_type))
				F.addMember(H)
				F.addRel(H, head, getMatchingRel(rel_type), TRUE)
				F.addRel(head, H, rel_type, TRUE)
				remaining_candidates -= H
				break  // Stop after first match - one head, one candidate

	// Clean up single member families
	for(var/fam in families)
		var/datum/family/F = fam
		if(length(F.members) <= 1)
			qdel(F)


/datum/controller/subsystem/family/proc/SetupLordFamily()
	var/datum/family/lord_family
	var/mob/living/carbon/human/lord
	var/mob/living/carbon/human/lady //stored separate as they have to be added before the children.
	var/list/children = list()


	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(!H.client) //Needed because the preference menu makes dummy humans.
			continue
		var/datum/job/J = SSjob.GetJob(H.job)
		if(!J || !J.lord_family)
			continue
		if(istype(J,/datum/job/roguetown/lord))
			if(!lord)
				lord = H
				lord_family = makeFamily(lord, GLOB.lordsurname)
		else if(istype(J,/datum/job/roguetown/lady))
			lady = H
		else
			children |= H

	if(!lord_family)
		return

	var/list/family_list = list(lady)

	family_list += children

	for(var/m in family_list)
		if(!m)
			continue
		var/mob/living/carbon/human/H = m

		lord_family.addMember(H)

		var/datum/job/J = SSjob.GetJob(H.job)
		var/rel_type = J.lord_rel_type
		if(rel_type != REL_TYPE_SPOUSE) //Genitals are already checked when the job is assigned. Ane we ignore both the Lord's & Consort's attraction prefs.
			if(!lord_family.checkFamilyCompat(H,lord,J.lord_rel_type)) //They're not suitible for their assigned relation type.
				if(rel_type == REL_TYPE_OFFSPRING && lord_family.checkFamilyCompat(H,lord,REL_TYPE_SIBLING)) //Fallback, if they can't be children. Check if they can be siblings.
					rel_type = REL_TYPE_SIBLING
				else
					rel_type = REL_TYPE_RELATIVE

		lord_family.addRel(H,lord,rel_type,TRUE)
		lord_family.addRel(lord,H,getMatchingRel(rel_type),TRUE)


	for(var/ref in lord_family.members) //loop through all other members and connect them.
		if(ref == lord_family.members[1]) //skip the lord.
			continue
		var/mob/living/carbon/human/H = lord_family.members[ref]:resolve()
		var/datum/relation/H_rel = lord_family.getTrueRel(lord,H)

		for(var/ref2 in lord_family.members)
			if(ref2 == lord_family.members[1] || ref2 == ref) //skip the lord and first member.
				continue
			var/mob/living/carbon/human/HH = lord_family.members[ref2]:resolve()
			var/datum/relation/HH_rel = lord_family.getTrueRel(lord,HH)

			var/new_rel = REL_TYPE_RELATIVE
			switch(H_rel.rel_type)
				if(REL_TYPE_SPOUSE)
					switch(HH_rel.rel_type)
						if(REL_TYPE_OFFSPRING)
							new_rel = REL_TYPE_PARENT
				if(REL_TYPE_OFFSPRING)
					switch(HH_rel.rel_type)
						if(REL_TYPE_OFFSPRING)
							new_rel = REL_TYPE_SIBLING
						if(REL_TYPE_SPOUSE)
							new_rel = REL_TYPE_OFFSPRING

			lord_family.addRel(H,HH,new_rel,TRUE)

/datum/family
	var/name = "ERROR"
	var/list/members = list() //Assoc list storing weakrefs to the members. The keys are the members real names.
	var/list/relations = list()
	var/list/member_identity = list() //stores uni_identity of members to compare against.

	var/match_fail //Hack. Used to easily inform failed matching for setspouse.

/datum/family/New()
	SSfamily.families += src

/datum/family/Destroy()
	.=..()
	for(var/N in members)
		if(isnull(N))
			continue
		var/mob/living/carbon/human/H = members[N]:resolve()
		if(H)
			H.family = null

	for(var/rel in relations)
		if(isnull(rel))
			continue
		var/datum/relation/R = rel
		R.holder = null
		R.target = null
		qdel(R)

/datum/family/proc/getRelations(var/mob/living/carbon/human/member,var/rel_type) //Returns all relations of the specified type.
	var/list/rels = list()
	for(var/datum/relation/R in relations)
		if(R.holder == WEAKREF(member) && (!rel_type || R.rel_type == rel_type))
			rels += R

	return rels


/datum/family/proc/getRel(var/mob/living/carbon/human/holder,var/mob/living/carbon/human/target) //Returns relationship shared by holder & target.
	for(var/datum/relation/R in relations)
		if(WEAKREF(holder) == R.holder && members[target.name] == R.target)
			return R

/datum/family/proc/getTrueRel(var/mob/living/carbon/human/holder,var/mob/living/carbon/human/target) //Returns true relationship shared by holder & target.
	for(var/datum/relation/R in relations)
		if(WEAKREF(holder) == R.holder && WEAKREF(target) == R.target)
			return R

/datum/family/proc/addRel(var/mob/living/carbon/human/target, var/mob/living/carbon/human/holder,var/rel_type, var/announce = FALSE) //creates a relation for two members.
	var/datum/relation/R
	var/list/rel_types = typesof(/datum/relation)
	for(var/type in rel_types)
		var/datum/relation/T = type
		if(T::rel_type == rel_type)
			R = new T(holder,target)

	if(!R)
		R = new /datum/relation/relative(holder,target)
	relations += R

	if(announce)
		spawn(1)
			to_chat(holder,"<span class='notice'>My [R.name]. [target.real_name] ([target.dna.species.name], [target.job], [target.age]) is here alongside me.</span>")

		R.onConnect(holder,target) //Bit of hack to have this here. But it stops church marriages from being given rings.

/datum/family/proc/tryConnect(var/mob/living/carbon/human/target, var/mob/living/carbon/human/member) //Gets the rel_type for the targets. For now, it only returns spouse.
	return REL_TYPE_SPOUSE


/datum/family/proc/checkFamilyCompat(var/mob/living/carbon/human/target, var/mob/living/carbon/human/member, var/rel_type) //Checks target's suitability for being in a family with the family member.
	switch(rel_type)
		if(REL_TYPE_SPOUSE)
			message_admins("Attempting to match [member.real_name] and [target.real_name]!")
			if(!member.client)
				return
			//Check gender.
			if(!member.client.prefs.family_gender.Find(target.gender))
				message_admins("match [member.real_name] ([member.gender]) and [target.real_name] ([target.gender]) Gender Fail!")
				match_fail = MATCH_FAIL_GENDER
				return FALSE

			//Check species.
			if(!member.client.prefs.family_species.Find(target.dna.species.id))
				message_admins("match [member.real_name] ([member.dna.species.id]) and [target.real_name] ([target.dna.species.id]) Species Fail!")
				match_fail = MATCH_FAIL_SPECIES
				return FALSE

			var/member_sex
			var/target_sex

			//Check sex.
			for(var/G in list(ORGAN_SLOT_VAGINA,ORGAN_SLOT_PENIS)) //Ensure that member & target don't share the same sex.
				if(member.getorganslot(G))
					member_sex = G == ORGAN_SLOT_VAGINA ? "vagina" : "penis"
				if(target.getorganslot(G))
					target_sex = G == ORGAN_SLOT_VAGINA ? "vagina" : "penis"
				if(member.getorganslot(G) && target.getorganslot(G))
					message_admins("match [member.real_name]  and [target.real_name] Sex Fail!")
					match_fail = MATCH_FAIL_SEX
					return FALSE

			var/list/age_values = AGE_VALUES
			var/target_value = age_values[target.age]
			var/member_value = age_values[member.age]
			if(max(member_value,target_value) - min(member_value,target_value) > 1) //Too high an age difference.
				message_admins("match [member.real_name] ([member.age])  and [target.real_name] ([target.age]) Age Fail!!")
				match_fail = MATCH_FAIL_AGE
				return FALSE

			message_admins("MATCHING [member.real_name] ([member.age], [member.dna.species.id], [member_sex])  and [target.real_name] ([target.age], [target.dna.species.id], [target_sex])!")
			return TRUE //suitable.

		if(REL_TYPE_SIBLING)
			var/list/age_values = AGE_VALUES
			var/target_value = age_values[target.age]
			var/member_value = age_values[member.age]
			if(max(member_value,target_value) - min(member_value,target_value) > 1) //Too high an age difference.
				return FALSE

			if(target.dna.species.type != member.dna.species.type)
				return FALSE

			return TRUE

		if(REL_TYPE_RELATIVE)
			return TRUE


		if(REL_TYPE_OFFSPRING)
			var/list/age_values = AGE_VALUES
			var/target_value = age_values[target.age]
			var/member_value = age_values[member.age]
			if(member_value - target_value > 1) //Too high an age difference.
				return FALSE
			var/list/allowed_species = list(member.dna.species.type)

			var/datum/relation/R
			var/mob/living/carbon/human/spouse
			var/list/rel_list = getRelations(member,REL_TYPE_SPOUSE)

			if(length(rel_list))
				R = rel_list[1]

			if(R)
				spouse = members[R.target]:resolve()
			if(spouse)
				if(spouse.dna.species.type != member.dna.species.type) //Parents have different species. Allow half children.
					allowed_species |= member.dna.species.halfchild_types[spouse.dna.species.id]

			if(!target.dna.species.type in allowed_species)
				return FALSE
			return TRUE

		else
			if(istype(target.dna.species,member.dna.species.type)) //Same species? Can always be in a family.
				return TRUE

	return FALSE


proc/getMatchingRel(var/rel_type)
	switch(rel_type)
		if(REL_TYPE_PARENT)
			return REL_TYPE_OFFSPRING
		if(REL_TYPE_OFFSPRING)
			return REL_TYPE_PARENT
		else
			return rel_type

/datum/family/proc/addMember(var/mob/living/carbon/human/H)
	members[H.real_name] = WEAKREF(H)
	member_identity[H.real_name] = H.dna.uni_identity
	H.family = src
	to_chat(H,"<span class='notice'><big>I'm apart of the [name] family!</big>")

/mob/living/carbon/human
	var/datum/family/family

/datum/family/proc/getHeadMember()
	var/H = getHeadRef():resolve()
	if(!H)
		return
	return H

/datum/family/proc/getHeadRef()
	var/head_name = members[1]
	return members[head_name]


/datum/relation
	var/name
	var/holder //The holder of the relationship.
	var/target //Who the relationship applies to. Example: Holder is husband, target is Wife.
	var/rel_type
	var/rel_state = "rel"

/datum/relation/proc/getName()
	return name


/datum/relation/proc/onConnect(var/mob/living/carbon/human/holder,var/mob/living/carbon/human/target)
	return

/datum/relation/New(var/mob/living/carbon/human/H,var/mob/living/carbon/human/T)
	holder = WEAKREF(H)
	target = WEAKREF(T)
	name = getName() //Done once to prevent any organ changes from changing the name.

/datum/relation/spouse
	name = "Spouse"
	rel_type = REL_TYPE_SPOUSE
	rel_state = "love"

/datum/relation/spouse/getName()
	var/mob/living/carbon/human/T = target:resolve()
	if(T)
		if(T.getorganslot(ORGAN_SLOT_PENIS))
			return "Husband"
		if(T.getorganslot(ORGAN_SLOT_VAGINA))
			return "Wife"
	return "Spouse"

/datum/relation/spouse/onConnect(var/mob/living/carbon/human/holder,var/mob/living/carbon/human/target)
	var/datum/job/holder_job = SSjob.GetJob(holder.job)

	// Only give rings to non-baron/consort spouses.
	if(istype(holder_job, /datum/job/roguetown/lord) || istype(holder_job, /datum/job/roguetown/lady))
		return

	// Handle existing rings before equipping new one
	if(holder.wear_ring)
		// Try to store in belt first
		var/obj/item/storage/belt = holder.get_item_by_slot(SLOT_BELT)
		if(istype(belt) && SEND_SIGNAL(belt, COMSIG_TRY_STORAGE_INSERT, holder.wear_ring, holder))
			to_chat(holder, span_notice("I store my old ring in my belt."))
		else
			// Try backpack slots if belt storage fails
			var/obj/item/storage/backpack/backr = holder.get_item_by_slot(SLOT_BACK_R)
			if(istype(backr) && SEND_SIGNAL(backr, COMSIG_TRY_STORAGE_INSERT, holder.wear_ring, holder))
				to_chat(holder, span_notice("I store my old ring in my right backpack."))
			else
				var/obj/item/storage/backpack/backl = holder.get_item_by_slot(SLOT_BACK_L)
				if(istype(backl) && SEND_SIGNAL(backl, COMSIG_TRY_STORAGE_INSERT, holder.wear_ring, holder))
					to_chat(holder, span_notice("I store my old ring in my left backpack."))
				else
					holder.dropItemToGround(holder.wear_ring)
					to_chat(holder, span_warning("I had to drop my old ring."))

	// Create and equip new soulring for both spouses
	var/obj/item/clothing/ring/soul/ring = new(holder, target.real_name)
	holder.equip_to_slot_if_possible(ring, SLOT_RING)


/datum/relation/sibling
	name = "Sibling"
	rel_type = REL_TYPE_SIBLING

/datum/relation/sibling/getName()
	var/mob/living/carbon/human/T = target:resolve()
	if(T)
		if(T.getorganslot(ORGAN_SLOT_PENIS))
			return "Brother"
		if(T.getorganslot(ORGAN_SLOT_VAGINA))
			return "Sister"
	return "Sibling"


/datum/relation/parent
	name = "Parent"
	rel_type = REL_TYPE_PARENT

/datum/relation/parent/getName()
	var/mob/living/carbon/human/T = target:resolve()
	if(T)
		if(T.getorganslot(ORGAN_SLOT_PENIS))
			return "Father"
		if(T.getorganslot(ORGAN_SLOT_VAGINA))
			return "Mother"
	return "Parent"


/datum/relation/offspring
	name = "Child"
	rel_type = REL_TYPE_OFFSPRING

/datum/relation/offspring/getName()
	var/mob/living/carbon/human/T = target:resolve()
	if(T)
		if(T.getorganslot(ORGAN_SLOT_PENIS))
			return "Son"
		if(T.getorganslot(ORGAN_SLOT_VAGINA))
			return "Daughter"
	return "Child"

/datum/relation/relative
	name = "Relative"
	rel_type = REL_TYPE_RELATIVE
	rel_state = "rel2"

/mob/living/carbon/human/proc/getFamily(var/true_family = FALSE)//Returns the family src belongs to. By default. We use our names + DNA to support people pretending to be family members. Use true_family if you wish to get their ACTUAL family.
	if(true_family)
		return family
	for(var/f in SSfamily.families)
		if(isnull(f))
			continue
		var/datum/family/F = f
		if(F.members.Find(name) && dna.uni_identity == family.member_identity[name])
			return F


/mob/living/carbon/human/proc/isFamily(var/mob/living/carbon/human/target,var/true_family = FALSE) //Checks if target is in our family. By default. We use our names + DNA to support people pretending to be family members. Use true_family if you wish to check if they ACTUALLY belong to the family.
	if(!family)
		return FALSE

	if(true_family)
		return target.family == family

	if(family.members[target.name] != null) //Name has the advantage of supporting masked humans + future cases like stealing identities.
		if(target.dna.uni_identity == family.member_identity[target.name])
			return TRUE
	return FALSE

/mob/living/carbon/human/proc/getRelationship(var/mob/living/carbon/human/target)
	if(!family)
		return

	if(!family.members.Find(target.name) || target.dna.uni_identity != family.member_identity[target.name])  //Name has the advantage of supporting masked humans + future cases like stealing identities.
		return

	return family.getRel(src,target)


