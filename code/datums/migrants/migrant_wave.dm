/datum/migrant_wave
	abstract_type = /datum/migrant_wave
	/// Name of the wave
	var/name = "MIGRANT WAVE"
	/// Assoc list of roles types to amount
	var/list/roles = list()
	/// If defined, this is the minimum active migrants required to roll the wave
	var/min_active = null
	/// If defined, this is the maximum active migrants required to roll the wave
	var/max_active = null
	/// If defined, this is the minimum population playing the game that is required for wave to roll
	var/min_pop = null
	/// If defined, this is the maximum population playing the game that is required for wave to roll
	var/max_pop = null
	/// If defined, this is the maximum amount of times this wave can spawn
	var/max_spawns = null
	/// The relative probability this wave will be picked, from all available waves
	var/weight = 100
	/// Name of the latejoin spawn landmark for the wave to decide where to spawn
	var/spawn_landmark = "Pilgrim"
	/// Text to greet all players in the wave with
	var/greet_text
	/// Whether this wave can roll at all. If not, it can still be forced to be ran, or used as "downgrade" wave
	var/can_roll = TRUE
	/// What type of wave to downgrade to on failure
	var/downgrade_wave
	/// If defined, this will be the wave type to increment for purposes of checking `max_spawns`
	var/shared_wave_type = null
	/// Whether we want to spawn people on the rolled location, this may not be desired for bandits or other things that set the location
	var/spawn_on_location = TRUE
	/// Original role counts that we can reset to
	var/list/original_roles = list()
	//  Should this be deleted after?
	var/unique = FALSE

/datum/migrant_wave/proc/get_roles_amount()
	var/amount = 0
	for(var/role_type in roles)
		amount += roles[role_type]
	return amount

// Used by late party. Return true if condition is met.
/datum/migrant_wave/proc/check_condition()
	return FALSE

/datum/migrant_wave/New()
	. = ..()
	// Store original role counts
	for(var/role_type in roles)
		original_roles[role_type] = roles[role_type]

/datum/migrant_wave/pilgrim
	name = "Wanderers"
	downgrade_wave = /datum/migrant_wave/pilgrim_down_one
	roles = list(
		/datum/migrant_role/pilgrim = 4,
	)
	greet_text = "Fleeing from misfortune and hardship, you and a handful of survivors get closer to Somberwicke, looking for refuge and work, finally almost being there, almost..."

/datum/migrant_wave/pilgrim_down_one
	name = "Wanderers"
	downgrade_wave = /datum/migrant_wave/pilgrim_down_two
	can_roll = FALSE
	roles = list(
		/datum/migrant_role/pilgrim = 3,
	)
	greet_text = "Fleeing from misfortune and hardship, you and a handful of survivors get closer to Somberwicke, looking for refuge and work, finally almost being there, almost..."

/datum/migrant_wave/pilgrim_down_two
	name = "Wanderers"
	downgrade_wave = /datum/migrant_wave/pilgrim_down_three
	can_roll = FALSE
	roles = list(
		/datum/migrant_role/pilgrim = 2,
	)
	greet_text = "Fleeing from misfortune and hardship, you and a handful of survivors get closer to Somberwicke, looking for refuge and work, finally almost being there, almost..."

/datum/migrant_wave/pilgrim_down_three
	name = "Wanderers"
	can_roll = FALSE
	roles = list(
		/datum/migrant_role/pilgrim = 1,
	)
	greet_text = "Fleeing from misfortune and hardship, you and a handful of survivors get closer to Somberwicke, looking for refuge and work, finally almost being there, almost..."

