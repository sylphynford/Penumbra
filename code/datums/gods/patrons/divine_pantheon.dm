/datum/patron/divine
	name = null
	associated_faith = /datum/faith/divine
	t0 = /obj/effect/proc_holder/spell/invoked/lesser_heal

/datum/patron/divine/astrata
	name = "PSYDON"
	domain = "All Creation"
	desc = "The true God of everything, PSYDON is all loving and all forgiving."
	worshippers = "Citizens of the town and onwards."
	confess_lines = list(
		"THERE IS ONLY ONE TRUE GOD!",
		"PSYDON'S CREATION WILL BE REMADE!",
		"REBUKE THE HERETICAL - PSYDON ENDURES!",
	)

/datum/patron/divine/noc
	name = "Noc"
	domain = "Saint of the Moon, Night, and Knowledge"
	hidden_from_prefs = TRUE
	desc = "The Saint of PSYDON that opens his eyes during pondorous Night. He gifted man knowledge of divinity and magicks."
	worshippers = "Wizards and Scholars"
	mob_traits = list(TRAIT_NOCSIGHT)
	confess_lines = list(
		"THERE IS ONLY ONE TRUE GOD!",
		"PSYDON'S CREATION WILL BE REMADE!",
		"REBUKE THE HERETICAL - PSYDON ENDURES!",
	)

/datum/patron/divine/dendor
	name = "Dendor"
	domain = "Saint of the Earth and Nature"
	hidden_from_prefs = TRUE
	desc = "The Saint of Wilds. The Saint of Ground-Lyfe. Treefather."
	worshippers = "Druids, Beasts, Madmen"
	mob_traits = list(TRAIT_KNEESTINGER_IMMUNITY)
	confess_lines = list(
		"THERE IS ONLY ONE TRUE GOD!",
		"PSYDON'S CREATION WILL BE REMADE!",
		"REBUKE THE HERETICAL - PSYDON ENDURES!",
	)

/datum/patron/divine/abyssor
	name = "Abyssor"
	domain = "Saint of the Ocean, Storms and the Tide"
	desc = "The strongest of the Saints; a great Admiral that served PSYDON at sea."
	hidden_from_prefs = TRUE
	worshippers = "Men of the Sea, Primitive Aquatics"
	mob_traits = list(TRAIT_ABYSSOR_SWIM)
	confess_lines = list(
		"THERE IS ONLY ONE TRUE GOD!",
		"PSYDON'S CREATION WILL BE REMADE!",
		"REBUKE THE HERETICAL - PSYDON ENDURES!",
	)

/datum/patron/divine/ravox
	name = "Ravox"
	domain = "Saint of Justice, Glory, Battle"
	desc = "Stalwart warrior, glorious justicier; legends say he came down to the Basin to repel the vile hordes of demons with his own hands, and that he seeks warriors for PSYDON's divine army among mortals."
	hidden_from_prefs = TRUE
	worshippers = "Warriors, Sellswords & those who seek Justice"
	confess_lines = list(
		"THERE IS ONLY ONE TRUE GOD!",
		"PSYDON'S CREATION WILL BE REMADE!",
		"REBUKE THE HERETICAL - PSYDON ENDURES!",
	)

/datum/patron/divine/necra
	name = "Necra"
	domain = "Saint of Death and the Afterlife"
	desc = "Veiled Saint of the underworld, equally feared and respected by all. She taught us the inevitability of death and cares for them as they reach the afterlife."
	hidden_from_prefs = TRUE
	worshippers = "The Dead, Mourners, Gravekeepers"
	mob_traits = list(TRAIT_SOUL_EXAMINE)
	confess_lines = list(
		"THERE IS ONLY ONE TRUE GOD!",
		"PSYDON'S CREATION WILL BE REMADE!",
		"REBUKE THE HERETICAL - PSYDON ENDURES!",
	)

/datum/patron/divine/xylix
	name = "Xylix"
	domain = "Saint of Trickery, Freedom and Inspiration"
	desc = "The Laughing Saint, both famous and infamous for his sway over the forces of luck. Xylix is known for the inspiration of many a bards lyric. Speaks through his gift to man; the Tarot deck."
	hidden_from_prefs = TRUE
	worshippers = "Gamblers, Bards, Artists, and the Silver-Tongued"
	mob_traits = list(TRAIT_XYLIX)
	confess_lines = list(
		"THERE IS ONLY ONE TRUE GOD!",
		"PSYDON'S CREATION WILL BE REMADE!",
		"REBUKE THE HERETICAL - PSYDON ENDURES!",
	)

/datum/patron/divine/pestra
	name = "Pestra"
	domain = "Saint of Decay, Disease and Medicine"
	desc = "Saint that blessed many a man with healing hands, Pestra taught man the arts of medicine and its benefits."
	worshippers = "The Sick, Phyicians, Apothecaries"
	hidden_from_prefs = TRUE
	mob_traits = list(TRAIT_EMPATH, TRAIT_ROT_EATER)
	confess_lines = list(
		"THERE IS ONLY ONE TRUE GOD!",
		"PSYDON'S CREATION WILL BE REMADE!",
		"REBUKE THE HERETICAL - PSYDON ENDURES!",
	)

/datum/patron/divine/malum
	name = "Malum"
	domain = "Saint of Fire, Destruction and Rebirth"
	hidden_from_prefs = TRUE
	desc = "Opinionless Saint of the crafts. He teaches that great works for killing or saving are great works, either way. The well-oiled guillotine and the well-sharpened axe are tools, and there is no good and evil to their craft."
	worshippers = "Smiths, Miners, Engineers"
	confess_lines = list(
		"THERE IS ONLY ONE TRUE GOD!",
		"PSYDON'S CREATION WILL BE REMADE!",
		"REBUKE THE HERETICAL - PSYDON ENDURES!",
	)

//Eora content from Stonekeep

/datum/patron/divine/eora
	name = "Eora"
	domain = "Saint of Love, Life and Beauty"
	hidden_from_prefs = TRUE
	desc = "She is without a shred of hate in her heart and taught mankind that true love that even transcends death."
	worshippers = "Lovers, the romantically inclined, and Doting Grandparents"
	confess_lines = list(
		"THERE IS ONLY ONE TRUE GOD!",
		"PSYDON'S CREATION WILL BE REMADE!",
		"REBUKE THE HERETICAL - PSYDON ENDURES!",
	)


