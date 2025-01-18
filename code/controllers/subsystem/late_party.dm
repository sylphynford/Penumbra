SUBSYSTEM_DEF(lateparty)
	name = "Late party"
	wait = 1 MINUTES
	runlevels = RUNLEVEL_GAME

	var/list/unique_waves = list()

	// List of players that agreed to the ghost prompt. Once this reaches its minimum, we spawn them in.
	// If it doesn't reach the minimum, we add it to the migrant wave list, and remove it once a wave spawns normally.
	var/list/readied_dead_players = list()

/datum/controller/subsystem/lateparty/Initialize()
	for(var/wave_type in GLOB.migrant_waves)
		var/datum/migrant_wave/wave = MIGRANT_WAVE(wave_type)
		if(!wave.unique)
			continue
		unique_waves += wave_type
	return ..()

/datum/controller/subsystem/lateparty/fire()
	for(var/wave_type in unique_waves)
		var/datum/migrant_wave/wave = MIGRANT_WAVE(wave_type)
		// We don't want multiple late parties, let whichever one is checked first win.
		if(wave.check_condition())
			if(!try_ghosts())
			SSmigrants.special_wave_type = wave_type
			return


// Before adding the migrant wave to the queue, lets try asking ghosts if they want to play first.
/datum/controller/subsystem/lateparty/proc/try_ghosts()
	return