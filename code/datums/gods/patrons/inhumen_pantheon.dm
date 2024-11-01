/datum/patron/inhumen
	name = null
	associated_faith = /datum/faith/inhumen
	undead_hater = FALSE
	t0 = /obj/effect/proc_holder/spell/invoked/lesser_heal
	confess_lines = list(
		"PSYDON FAILED!",
		"THE TEN ARE WORTHLESS COWARDS!",
		"THE TEN ARE DECEIVERS!",
	)

/datum/patron/inhumen/zizo
	name = "Zizo"
	domain = "The domain of ambition and defilement"
	desc = "The first fragment of the researcher known only as Z. Created to test the creations of PSYDON and his ilk. Zizo is baleful ambition incarnate. The servants of Zizo know him as a dark elven researcher who created necromancy in Psydonia. They could not be any closer to the truth." 
	worshippers = "Necromancers, Warlocks, and the Undead"
	mob_traits = list(TRAIT_CABAL)
	t1 = /obj/effect/proc_holder/spell/invoked/projectile/profane/miracle
	t2 = /obj/effect/proc_holder/spell/invoked/raise_lesser_undead/miracle
	t3 = /obj/effect/proc_holder/spell/invoked/rituos/miracle
	confess_lines = list(
		"PRAISE ZIZO!",
		"LONG LIVE ZIZO!",
		"ZIZO IS QUEEN!",
	)

/datum/patron/inhumen/graggar
	name = "Graggar"
	domain = "The domain violence in the purist of forms."
	desc = "The second fragment of the researcher known as Z. Created to test the creations of PSYDON. Graggar is the pool of blood that speaks to you after a traumatic murder and the presence that encourages great violence. The servants of Graggar know him an orc who achieved divinity through violence."
	worshippers = "The Cruel, the Evil, the Violent."
	mob_traits = list(TRAIT_HORDE, TRAIT_ORGAN_EATER)
	confess_lines = list(
		"GRAGGAR IS THE BEAST I WORSHIP!",
		"THROUGH VIOLENCE I ACHIEVE DIVINITY,
		"THE ASPECT OF CONQUEST DEMANDS BLOOD!",
	)

/datum/patron/inhumen/matthios
	name = "Matthios"
	domain = "The domain of greed."
	desc = "The third fragment of the researcher known as Z. Created to test the creations of PSYDON by driving his creations to envy their fellow man. Matthios is the friend who justifies taking from others because 'not enough' was shared. The servants of Matthios know him as the one who stole primordial knowledge from the last king of Psydonia in order to create ambition in the world which in turn allowed Matthios to become divine."
	worshippers = "The Well-Intentioned Extremist, The Thief. The Merchant.""
	mob_traits = list(TRAIT_COMMIE)
	confess_lines = list(
		"MATTHIOS STEALS FROM THE GREEDY!", // IRONY
		"MATTHIOS IS THE PATH OF JUSTICE!",
		"MATTHIOS IS MY LORD!",
	)

/datum/patron/inhumen/baotha
	name = "Baotha"
	domain = "The domain of excess and addiction."
	desc = "The fourth fragment of the researcher known as Z. Created to test the creations of PSYDON by driving his creations to ever increasing highs and lows. Baotha is the nightswain that encourages you to leave your beloved for a woman you have never met. Baotha is the aspect that encourages you to chug a gallon of wine all in one go. The servants of Baotha know her as the one who achieved divinity through ritualistic acts of pleasure."
	worshippers = "The Perverted, The Lecherous."
	mob_traits = list(TRAIT_DEPRAVED, TRAIT_CRACKHEAD)
	confess_lines = list(
		"BAOTHA DEMANDS PLEASURE!",
		"LIVE, LAUGH, LOVE!",
		"BAOTHA IS MY JOY!",
	)


/* RATWOOD EDIT - Back to the main pantheon
/datum/patron/inhumen/eora
	name = "Eora"
	domain = "Goddess of Degeneracy, Debauchery and Addiction"
	desc = "The Fallen Daughter of Psydon, once used to be a goddess of love and family but has now fallen from grace as she leads mortals to hedonism."
	worshippers = "Drunkards, Junkies, Gamblers and Bards"
	confess_lines = list(
		"EORA BRINGS ME PLEASURE!",
		"EORA BRINGS ME LUCK!",
		"EORA IS MY HAPPINESS!",
	)
	t0 = /obj/effect/proc_holder/spell/invoked/lesser_heal
*/
