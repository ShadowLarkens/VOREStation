#if !defined(USING_MAP_DATUM)

	#include "lavaworld_defines.dm"

	#ifndef AWAY_MISSION_TEST //Don't include these for just testing away missions
		#include "lavaworld1.dmm"
	#endif

	#define USING_MAP_DATUM /datum/map/lavaworld

#elif !defined(MAP_OVERRIDE)

	#warn A map has already been included, ignoring Lavaworld

#endif
