/datum/patron/inhumen
	name = null
	associated_faith = /datum/faith/inhumen
	undead_hater = FALSE
	t0 = /obj/effect/proc_holder/spell/invoked/lesser_heal
	confess_lines = list(
		"PSYDON WILL FAIL!",
		"PSYDON IS A WORTHLESS COWARD!",
		"PSYDON IS A DECEIVERS!"
	)

/datum/patron/inhumen/zizo
	name = "Zizo"
	domain = "The domain of ambition and defilement."
	desc = "The disciples of Zizo are a faction that believes in the power and supremacy of Zizo, viewing him as the world's only hope against impending doom.  They work tirelessly to strengthen Zizo's hold on the world, conducting dark rituals and seeking out ancient artifacts. Despite their seemingly malevolent alliance, they see themselves as the world's protectors, believing that only by embracing the power of Zizo can the world be saved. They are united not by worship, but by a shared creed: power belongs to those who take it, not to those who wait for a absent god to bestow it."
	worshippers = "Necromancers, Warlocks, and the Undead"
	mob_traits = list(TRAIT_CABAL)
	t1 = /obj/effect/proc_holder/spell/invoked/projectile/profane/miracle
	t2 = /obj/effect/proc_holder/spell/invoked/raise_lesser_undead/miracle
	t3 = /obj/effect/proc_holder/spell/invoked/rituos/miracle
	confess_lines = list(
		"PRAISE ZIZO!",
		"LONG LIVE ZIZO!",
		"ZIZO IS GOD!"
	)

/datum/patron/inhumen/graggar
	name = "Graggar"
	domain = "The domain of violence in its purest forms."
	hidden_from_prefs = TRUE
	desc = "The second fragment of the researcher known as Z. Created to test the creations of PSYDON. Graggar is the pool of blood that speaks to you after a traumatic murder and the presence that encourages great violence. The servants of Graggar know him as an orc who achieved divinity through violence."
	worshippers = "The Cruel, the Evil, the Violent."
	mob_traits = list(TRAIT_HORDE, TRAIT_ORGAN_EATER)
	confess_lines = list(
		"GRAGGAR IS THE BEAST I WORSHIP!",
		"THROUGH VIOLENCE I ACHIEVE DIVINITY!",
		"THE LORD OF CONQUEST DEMANDS BLOOD!"
	)

/datum/patron/inhumen/matthios
	name = "Matthios"
	domain = "The domain of greed."
	hidden_from_prefs = TRUE
	desc = "The third fragment of the researcher known as Z. Created to test the creations of PSYDON by driving his creations to envy their fellow man. Matthios is the friend who justifies taking from others because 'not enough' was shared. The servants of Matthios know him as the one who stole primordial knowledge from the last king of Psydonia in order to create ambition in the world which in turn allowed Matthios to become divine."
	worshippers = "The Well-Intentioned Extremist, The Thief, The Merchant."
	mob_traits = list(TRAIT_COMMIE)
	confess_lines = list(
		"MATTHIOS STEALS FROM THE GREEDY!",
		"MATTHIOS IS THE PATH OF JUSTICE!",
		"MATTHIOS IS MY LORD!"
	)

/datum/patron/inhumen/baotha
	name = "Baotha"
	hidden_from_prefs = TRUE
	domain = "The domain of excess and addiction."
	desc = "The fourth fragment of the researcher known as Z. Created to test the creations of PSYDON by driving his creations to ever-increasing highs and lows. Baotha is the nightswain that encourages you to leave your beloved for a woman you have never met. Baotha is also the aspect that encourages you to chug a gallon of wine all in one go. The servants of Baotha know her as the one who achieved divinity through ritualistic acts of pleasure."
	worshippers = "The Perverted, The Lecherous."
	mob_traits = list(TRAIT_DEPRAVED, TRAIT_CRACKHEAD)
	confess_lines = list(
		"BAOTHA DEMANDS PLEASURE!",
		"I SUCCUMB TO PLEASURE!", // noise marine reference (not anymore that's cringe)
		"BAOTHA IS MY JOY!"
	)

/datum/patron/inhumen/faithless
	name = "Faithless"
	domain = "The domain of disbelief and rejection."
	desc = "Born from the pessimistic belief that Psydon has abandoned the world and Zizo revels in mortal suffering, for the Faithless, there is no paradise beyond, only the opportunity to carve an empire of their own making here and now. Where others see despair in a world without gods, they see infinite possibility. Unlike the open heresy of Zizo worshippers, which invites fiery condemnation and swift punishment, the faithless avoid outright persecution from the church of Psydonia. Their rejection of the divine is seen not as an affront to Psydon but as a misguided rebellion born of ignorance and despair. This thin veneer of indifference, however, does little to shield them from the pervasive prejudice that haunts their existence."
	worshippers = "Those who reject the faith of PSYDON."
	confess_lines = list(
		"THERE ARE NO GODS!",
		"FAITH IS A PRISON!",
		"WE NEED NO DIVINE MASTERS!"
	)
