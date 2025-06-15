/datum/map/lavaworld/New()
	. = ..()

	// TODO: custom lobby screens
	var/choice = pickweight(list(
		'html/lobby/logo1.png' = 50,
		'html/lobby/logo2.png' = 50,
		'html/lobby/gateway.png' = 5,
		'html/lobby/youcanttaketheskyfromme.png' = 200,
		'html/lobby/intothedark.png' = 200,
		'html/lobby/above3b.png' = 200,
	))
	if(choice)
		lobby_screens = list(choice)

/datum/map/lavaworld
	name = "LavaWorld"
	full_name = "TBD Lava World"
	path = "lavaworld"

	use_overmap = FALSE
	overmap_z = Z_NAME_ALIAS_MISC
	overmap_size = 50
	overmap_event_areas = 44
	usable_email_tlds = list("virgo.nt")

	zlevel_datum_type = /datum/map_z_level/lavaworld

	lobby_screens = list('html/lobby/youcanttaketheskyfromme.png') //set back to youcanttaketheskyfromme
	id_hud_icons = 'icons/mob/hud_jobs_vr.dmi'

	// TODO: holomap_smoosh
	holomap_smoosh = null

	// TODO: Fix
	station_name  = "NSB Adephagia"
	station_short = "Tether"
	facility_type = "station"
	dock_name     = "Virgo-3B Colony"
	dock_type     = "surface"
	boss_name     = "Central Command"
	boss_short    = "CentCom"
	company_name  = "NanoTrasen"
	company_short = "NT"
	starsys_name  = "Virgo-Erigone"

	shuttle_docked_message = "The scheduled Orange Line tram to the %dock_name% has arrived. It will depart in approximately %ETD%."
	shuttle_leaving_dock = "The Orange Line tram has left the station. Estimate %ETA% until the tram arrives at %dock_name%."
	shuttle_called_message = "A scheduled crew transfer to the %dock_name% is occuring. The tram will be arriving shortly. Those departing should proceed to the Orange Line tram station within %ETA%."
	shuttle_recall_message = "The scheduled crew transfer has been cancelled."
	shuttle_name = "Automated Tram"
	emergency_shuttle_docked_message = "The evacuation tram has arrived at the tram station. You have approximately %ETD% to board the tram."
	emergency_shuttle_leaving_dock = "The emergency tram has left the station. Estimate %ETA% until the tram arrives at %dock_name%."
	emergency_shuttle_called_message = "An emergency evacuation has begun, and an off-schedule tram has been called. It will arrive at the tram station in approximately %ETA%."
	emergency_shuttle_recall_message = "The evacuation tram has been recalled."

	station_networks = list(
							NETWORK_CARGO,
							NETWORK_CIRCUITS,
							NETWORK_CIVILIAN,
							NETWORK_COMMAND,
							NETWORK_ENGINE,
							NETWORK_ENGINEERING,
							NETWORK_EXPLORATION,
							//NETWORK_DEFAULT,  //Is this even used for anything? Robots show up here, but they show up in ROBOTS network too,
							NETWORK_MEDICAL,
							NETWORK_MINE,
							NETWORK_OUTSIDE,
							NETWORK_RESEARCH,
							NETWORK_RESEARCH_OUTPOST,
							NETWORK_ROBOTS,
							NETWORK_SECURITY,
							NETWORK_TELECOM,
							NETWORK_TETHER,
							)
	secondary_networks = list(
							NETWORK_ERT,
							NETWORK_MERCENARY,
							NETWORK_THUNDER,
							NETWORK_COMMUNICATORS,
							NETWORK_ALARM_ATMOS,
							NETWORK_ALARM_POWER,
							NETWORK_ALARM_FIRE,
							NETWORK_TALON_HELMETS,
							NETWORK_TALON_SHIP,
							)

	bot_patrolling = FALSE

	allowed_spawns = list("Tram Station","Gateway","Cryogenic Storage","Cyborg Storage","ITV Talon Cryo")
	spawnpoint_died = /datum/spawnpoint/tram
	spawnpoint_left = /datum/spawnpoint/tram
	spawnpoint_stayed = /datum/spawnpoint/cryo

	meteor_strike_areas = list()

	default_skybox = /datum/skybox_settings/lavaworld

	unit_test_exempt_areas = list()
	unit_test_exempt_from_atmos = list()
	unit_test_z_levels = list()

	lateload_z_levels = list(
		list(Z_NAME_OFFMAP1),
		list(Z_NAME_BEACH, Z_NAME_BEACH_CAVE),
		list(Z_NAME_AEROSTAT, Z_NAME_AEROSTAT_SURFACE),
		list(Z_NAME_DEBRISFIELD),
		list(Z_NAME_FUELDEPOT),
		)

	lateload_gateway = list(
		list(Z_NAME_GATEWAY_CARP_FARM),
		list(Z_NAME_GATEWAY_SNOW_FIELD),
		list(Z_NAME_GATEWAY_LISTENING_POST),
		list(list(Z_NAME_GATEWAY_HONLETH_A, Z_NAME_GATEWAY_HONLETH_B)),
		list(Z_NAME_GATEWAY_ARYNTHI_CAVE_A,Z_NAME_GATEWAY_ARYNTHI_A),
		list(Z_NAME_GATEWAY_ARYNTHI_CAVE_B,Z_NAME_GATEWAY_ARYNTHI_B),
		list(Z_NAME_GATEWAY_WILD_WEST),
		)

	lateload_overmap = list(
		list(Z_NAME_OM_GRASS_CAVE),
		)

	lateload_redgate = list(
		list(Z_NAME_REDGATE_TEPPI_RANCH),
		list(Z_NAME_REDGATE_INNLAND),
		list(Z_NAME_REDGATE_DARK_ADVENTURE),
		list(Z_NAME_REDGATE_EGGNOG_CAVE,Z_NAME_REDGATE_EGGNOG_TOWN),
		list(Z_NAME_REDGATE_STAR_DOG),
		list(Z_NAME_REDGATE_HOTSPRINGS),
		list(Z_NAME_REDGATE_RAIN_CITY),
		list(Z_NAME_REDGATE_ISLANDS_UNDERWATER,Z_NAME_REDGATE_ISLANDS),
		list(Z_NAME_REDGATE_MOVING_TRAIN, Z_NAME_REDGATE_MOVING_TRAIN_UPPER),
		list(Z_NAME_REDGATE_FANTASY_DUNGEON, Z_NAME_REDGATE_FANTASY_TOWN),
		list(Z_NAME_REDGATE_LASERDOME),
		list(Z_NAME_REDGATE_CASCADING_FALLS),
		list(Z_NAME_REDGATE_JUNGLE_CAVE, Z_NAME_REDGATE_JUNGLE),
		list(Z_NAME_REDGATE_FACILITY),
		)

	ai_shell_restricted = FALSE
	ai_shell_allowed_levels = list()

	// belter_docked_z = 		list(Z_LEVEL_TETHER_SPACE_LOW)
	// belter_transit_z =		list(Z_NAME_ALIAS_MISC)
	// belter_belt_z = 		list(Z_NAME_TETHER_ROGUEMINE_1,
	// 								Z_NAME_TETHER_ROGUEMINE_2)

	// mining_station_z =		list(Z_LEVEL_TETHER_SPACE_LOW)
	// mining_outpost_z =		list(Z_LEVEL_TETHER_SURFACE_MINE)

	planet_datums_to_make = list(
		/datum/planet/virgo3b,
		/datum/planet/virgo4,
	)

/datum/map/lavaworld/get_map_info()
	. = list()
	. +=  "The [full_name] is an ancient ruin turned workplace in the Virgo-Erigone System, deep in the midst of the Coreward Periphery.<br>"
	. +=  "Humanity has spread across the stars and has met many species on similar or even more advanced terms than them - it's a brave new world and many try to find their place in it . <br>"
	. +=  "Though Virgo-Erigone is not important for the great movers and shakers, it sees itself in the midst of the interests of a reviving alien species of the Zorren, corporate and subversive interests and other exciting dangers the Periphery has to face.<br>"
	. +=  "As an employee or contractor of NanoTrasen, operators of the Adephagia and one of the galaxy's largest corporations, you're probably just here to do a job."
	return jointext(., "<br>")

/datum/map/lavaworld/perform_map_generation()
	return 1

/datum/skybox_settings/lavaworld
	icon_state = "space5"
	use_stars = FALSE

/datum/planet/virgo3b
	expected_z_levels = list(Z_NAME_ALIAS_CENTCOM)

/datum/planet/virgo4
	expected_z_levels = list(Z_NAME_BEACH)

// For making the 6-in-1 holomap, we calculate some offsets
#define LAVAWORLD_MAP_SIZE 140 // Width and height of compiled in tether z levels.
#define LAVAWORLD_HOLOMAP_CENTER_GUTTER 40 // 40px central gutter between columns
#define LAVAWORLD_HOLOMAP_MARGIN_X ((HOLOMAP_ICON_SIZE - (2*LAVAWORLD_MAP_SIZE) - LAVAWORLD_HOLOMAP_CENTER_GUTTER) / 2) // 80
#define LAVAWORLD_HOLOMAP_MARGIN_Y ((HOLOMAP_ICON_SIZE - (2*LAVAWORLD_MAP_SIZE)) / 2) // 30

/datum/map_z_level/lavaworld
	flags = MAP_LEVEL_STATION|MAP_LEVEL_CONTACT|MAP_LEVEL_PLAYER|MAP_LEVEL_SEALED|MAP_LEVEL_CONSOLES|MAP_LEVEL_XENOARCH_EXEMPT|MAP_LEVEL_PERSIST|MAP_LEVEL_VORESPAWN
	holomap_legend_x = 220
	holomap_legend_y = 160

/datum/map_z_level/lavaworld/level_one
	z = Z_LEVEL_LW_LEVEL1
	name = "Level 1"
	base_turf = /turf/simulated/floor/lava/outdoors
	holomap_offset_x = LAVAWORLD_HOLOMAP_MARGIN_X
	holomap_offset_y = LAVAWORLD_HOLOMAP_MARGIN_Y
