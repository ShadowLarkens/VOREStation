#define METEOR_DELAY 6000

/datum/game_mode/meteor
	name = "Meteor"
	round_description = "The space station has been stuck in a major meteor shower."
	extended_round_description = "The station is on an unavoidable collision course with an asteroid field. The station will be continuously slammed with meteors, venting hallways, rooms, and ultimately destroying a majority of the basic life functions of the entire structure. Coordinate with your fellow crew members to survive the inevitable destruction of the station and get back home in one piece!"
	config_tag = "meteor"
	required_players = 0
	votable = 0
	deny_respawn = 0
	var/next_wave = METEOR_DELAY

/datum/game_mode/meteor/post_setup()
	defer_powernet_rebuild = 2//Might help with the lag
	..()

/datum/game_mode/meteor/process()
	if(world.time >= next_wave)
		next_wave = world.time + GLOB.meteor_wave_delay
		spawn() spawn_meteors(6, meteors_normal)

/datum/game_mode/meteor/declare_completion()
	var/text
	var/survivors = 0
	for(var/mob/living/player in GLOB.player_list)
		if(player.stat != DEAD)
			var/turf/location = get_turf(player.loc)
			if(!location)	continue
			switch(location.loc.type)
				if( /area/shuttle/escape/centcom )
					text += "<br>"
					text += span_bold(span_normal("[player.real_name] escaped on the emergency shuttle"))
				if( /area/shuttle/escape_pod1/centcom, /area/shuttle/escape_pod2/centcom, /area/shuttle/escape_pod3/centcom, /area/shuttle/escape_pod5/centcom )
					text += "<br>"
					text += span_normal("[player.real_name] escaped in a life pod.")
				else
					text += "<br>"
					text += span_small("[player.real_name] survived but is stranded without any hope of rescue.")
			survivors++

	if(survivors)
		to_world(span_world("The following survived the meteor storm") + ":[text]")
	else
		to_world(span_boldannounce("Nobody survived the meteor storm!"))

	feedback_set_details("round_end_result","end - evacuation")
	feedback_set("round_end_result",survivors)

	..()
	return 1

#undef METEOR_DELAY
