/mob/living/carbon/human/species/halfling/lightfoot
	race = /datum/species/halfling/lightfoot

/datum/species/halfling/lightfoot
	name = "Halfling"
	id = "halflingl"
	desc = "<b>Dwarf</b><br>\
	Dwarves are a peoples defined by their relentless dedication. \
	From a young age, many are drawn to a single skill, an art, or a craft, \
	and once that passion takes root, it becomes their world. \
	This obsession often shapes their identity, and their days are measured not by time \
	but by the progress they make in perfecting their craft. \
	It is this unwavering tenacity, this single-mindedness, that marks them as a race \
	of tireless builders, creators, and warriors, forever bound to the pursuits they choose \
	with unshakable resolve.<br><br>\
	When the tide of necromantic magic swept across the world, the dwarves struggled to adapt, \
	they were too rooted in tradition, their minds too locked into the repetition of their chosen paths, \
	to pivot quickly or effectively. They sought to confront the new threat with the same tools \
	and tactics that had worked for centuries, unable to break from their rigid approaches. \
	In the aftermath, many dwarves, unable to reclaim their lost homes or rebuild what was shattered, \
	sought refuge among the humans.<br><br>\
	+1 Constitution."

	skin_tone_wording = "Ancestry"

	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,OLDGREY)
	//inherent_traits = list(TRAIT_DRUNK_HEALING)
	possible_ages = ALL_AGES_LIST
	default_features = MANDATORY_FEATURE_LIST
	use_skintones = 1
	skinned_type = /obj/item/stack/sheet/animalhide/human
	disliked_food = NONE
	liked_food = NONE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	limbs_icon_m = 'icons/roguetown/mob/bodies/m/mhalfling.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/f/fhalfling.dmi'
	dam_icon = 'icons/roguetown/mob/bodies/dam/dam_male.dmi'
	dam_icon_f = 'icons/roguetown/mob/bodies/dam/dam_female.dmi'
	hairyness = "t3"
	soundpack_m = /datum/voicepack/male
	soundpack_f = /datum/voicepack/female
	use_f = TRUE
	custom_clothes = TRUE
	clothes_id = "dwarf"
	offset_features = list(
		OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,-4), OFFSET_WRISTS = list(0,-5),\
		OFFSET_CLOAK = list(0,0), OFFSET_FACEMASK = list(0,-5), OFFSET_HEAD = list(0,-5), \
		OFFSET_FACE = list(0,-5), OFFSET_BELT = list(0,-5), OFFSET_BACK = list(0,-5), \
		OFFSET_NECK = list(0,-5), OFFSET_MOUTH = list(0,-5), OFFSET_PANTS = list(0,0), \
		OFFSET_SHIRT = list(0,0), OFFSET_ARMOR = list(0,0), OFFSET_HANDS = list(0,-5), \
		OFFSET_ID_F = list(0,-5), OFFSET_GLOVES_F = list(0,-5), OFFSET_WRISTS_F = list(0,-6), OFFSET_HANDS_F = list(0,-6), \
		OFFSET_CLOAK_F = list(0,-1), OFFSET_FACEMASK_F = list(0,-6), OFFSET_HEAD_F = list(0,-6), \
		OFFSET_FACE_F = list(0,-6), OFFSET_BELT_F = list(0,-5), OFFSET_BACK_F = list(0,-5), \
		OFFSET_NECK_F = list(0,-6), OFFSET_MOUTH_F = list(0,-6), OFFSET_PANTS_F = list(0,0), \
		OFFSET_SHIRT_F = list(0,-1), OFFSET_ARMOR_F = list(0,-1), OFFSET_UNDIES = list(0,-4), OFFSET_UNDIES_F = list(0,-4), \
		)
	race_bonus = list(STAT_INTELLIGENCE = 1, STAT_CONSTITUTION = -1)
	enflamed_icon = "widefire"
	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes,
		ORGAN_SLOT_EARS = /obj/item/organ/ears/halfling,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		ORGAN_SLOT_APPENDIX = /obj/item/organ/appendix,
		)
	customizers = list(
		/datum/customizer/organ/eyes/humanoid,
		/datum/customizer/bodypart_feature/hair/head/humanoid,
		/datum/customizer/bodypart_feature/hair/facial/humanoid,
		/datum/customizer/bodypart_feature/hair/chest/humanoid,
		/datum/customizer/bodypart_feature/accessory,
		/datum/customizer/bodypart_feature/face_detail,
		/datum/customizer/organ/testicles/human,
		/datum/customizer/organ/penis/human,
		/datum/customizer/organ/breasts/human,
		/datum/customizer/organ/vagina/human,
		)
	body_markings = list(
	)

/datum/species/halfling/lightfoot/check_roundstart_eligible()
	return TRUE
/*
/datum/species/halfling/lightfoot/get_span_language(datum/language/message_language)
	if(!message_language)
		return
	if(message_language.type == /datum/language/elvish)
		return list(SPAN_ELF)
//	if(message_language.type == /datum/language/common)
//		return list(SPAN_DWARF)
	return message_language.spans
*/
/datum/species/halfling/lightfoot/get_skin_list()
	return list(
		"Grenzelhoft" = SKIN_COLOR_GRENZELHOFT,
		"Hammerhold" = SKIN_COLOR_HAMMERHOLD,
		"Avar" = SKIN_COLOR_AVAR,
		"Rockhill" = SKIN_COLOR_ROCKHILL,
		"Otava" = SKIN_COLOR_OTAVA,
		"Etrusca" = SKIN_COLOR_ETRUSCA,
		"Gronn" = SKIN_COLOR_GRONN,
		"North Zybantia (Giza)" = SKIN_COLOR_GIZA,
		"West Zybantia (Shalvistine)" = SKIN_COLOR_SHALVISTINE,
		"East Zybantia (Lalvestine)" = SKIN_COLOR_LALVESTINE,
		"Naledi" = SKIN_COLOR_NALEDI,
		"Kazengun" = SKIN_COLOR_KAZENGUN
	)

/datum/species/halfling/lightfoot/get_hairc_list()
	return sortList(list(
	"blond - pale" = "9d8d6e",
	"blond - dirty" = "88754f",
	"blond - drywheat" = "d5ba7b",
	"blond - strawberry" = "c69b71",

	"brown - mud" = "362e25",
	"brown - oats" = "584a3b",
	"brown - grain" = "58433b",
	"brown - soil" = "48322a",

	"black - oil" = "181a1d",
	"black - cave" = "201616",
	"black - rogue" = "2b201b",
	"black - midnight" = "1d1b2b",

	"red - berry" = "48322a",
	"red - wine" = "82534c",
	"red - sunset" = "82462b",
	"red - blood" = "822b2b"

	))


/*
/datum/species/halfling/lightfoot/random_name(gender,unique,lastname)

	var/randname
	if(unique)
		if(gender == MALE)
			for(var/i in 1 to 10)
				randname = pick( world.file2list("strings/rt/names/elf/elfwm.txt") )
				if(!findname(randname))
					break
		if(gender == FEMALE)
			for(var/i in 1 to 10)
				randname = pick( world.file2list("strings/rt/names/elf/elfwf.txt") )
				if(!findname(randname))
					break
	else
		if(gender == MALE)
			randname = pick( world.file2list("strings/rt/names/elf/elfwm.txt") )
		if(gender == FEMALE)
			randname = pick( world.file2list("strings/rt/names/elf/elfwf.txt") )
	return randname

/datum/species/gnome/woodland/random_surname()
	return " [pick(world.file2list("strings/rt/names/elf/elfwlast.txt"))]"
*/
