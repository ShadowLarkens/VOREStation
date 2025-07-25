var/global/datum/repository/crew/crew_repository = new()

/datum/repository/crew
	var/list/cache_data

/datum/repository/crew/New()
	cache_data = list()
	..()

/datum/repository/crew/proc/health_data(var/zLevel)
	var/list/crewmembers = list()
	if(!zLevel)
		return crewmembers

	var/z_level = "[zLevel]"
	var/datum/cache_entry/cache_entry = cache_data[z_level]
	if(!cache_entry)
		cache_entry = new/datum/cache_entry
		cache_data[z_level] = cache_entry

	if(world.time < cache_entry.timestamp)
		return cache_entry.data

	var/tracked = scan()
	for(var/obj/item/clothing/under/C in tracked)
		var/turf/pos = get_turf(C)
		var/area/B = pos?.loc //No sensor in Dorm
		if((C.has_sensor) && (pos?.z == zLevel) && (C.sensor_mode != SUIT_SENSOR_OFF) && !(B.flag_check(AREA_BLOCK_SUIT_SENSORS)) && !(is_jammed(C)) && !(is_vore_jammed(C)))
			if(ishuman(C.loc))
				var/mob/living/carbon/human/H = C.loc
				if(H.w_uniform != C)
					continue

				var/list/crewmemberData = list("dead"=0, "oxy"=-1, "tox"=-1, "fire"=-1, "brute"=-1, "area"="", "x"=-1, "y"=-1, "realZ"=-1, "z"="", "ref" = "\ref[H]")

				crewmemberData["sensor_type"] = C.sensor_mode
				crewmemberData["name"] = H.get_authentification_name(if_no_id="Unknown")
				crewmemberData["rank"] = H.get_authentification_rank(if_no_id="Unknown", if_no_job="No Job")
				crewmemberData["assignment"] = H.get_assignment(if_no_id="Unknown", if_no_job="No Job")

				if(C.sensor_mode >= SUIT_SENSOR_BINARY)
					crewmemberData["dead"] = H.stat == DEAD

				if(C.sensor_mode >= SUIT_SENSOR_VITAL)
					crewmemberData["stat"] = H.stat
					crewmemberData["oxy"] = round(H.getOxyLoss(), 1)
					crewmemberData["tox"] = round(H.getToxLoss(), 1)
					crewmemberData["fire"] = round(H.getFireLoss(), 1)
					crewmemberData["brute"] = round(H.getBruteLoss(), 1)

				if(C.sensor_mode >= SUIT_SENSOR_TRACKING)
					var/area/A = get_area(H)
					crewmemberData["area"] = sanitize(A.get_name())
					crewmemberData["x"] = pos.x
					crewmemberData["y"] = pos.y
					crewmemberData["realZ"] = pos.z
					crewmemberData["z"] = using_map.get_zlevel_name(pos.z)

				crewmembers[++crewmembers.len] = crewmemberData

	crewmembers = sortByKey(crewmembers, "name")
	cache_entry.timestamp = world.time + 5 SECONDS
	cache_entry.data = crewmembers

	return crewmembers

/datum/repository/crew/proc/scan()
	var/list/tracked = list()
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(istype(H.w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/C = H.w_uniform
			if (C.has_sensor)
				tracked |= C
	return tracked
