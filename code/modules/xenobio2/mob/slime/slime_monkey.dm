/*
Slime cube lives here.
*/
/obj/item/slime_cube
	name = "slimy monkey cube"
	desc = "Wonder what might come out of this."
	icon = 'icons/mob/slime2.dmi'
	icon_state = "slime cube"
	var/searching = 0

/obj/item/slime_cube/attack_self(mob/user as mob)
	if(!searching)
		to_chat(user, span_warning("You stare at the slimy cube, watching as some activity occurs."))
		request_player()

/obj/item/slime_cube/proc/request_player()
	icon_state = "slime cube active"
	searching = 1

	var/datum/ghost_query/promethean/P = new()
	var/list/winner = P.query()
	if(winner.len)
		var/mob/observer/dead/D = winner[1]
		transfer_personality(D)
	else
		reset_search()

/obj/item/slime_cube/proc/reset_search() //We give the players sixty seconds to decide, then reset the timer.
	icon_state = "slime cube"
	if(searching == 1)
		searching = 0
		var/turf/T = get_turf_or_move(src.loc)
		for(var/mob/M in viewers(T))
			M.show_message(span_warning("The activity in the cube dies down. Maybe it will spark another time."))

/obj/item/slime_cube/proc/transfer_personality(var/mob/candidate)
	announce_ghost_joinleave(candidate, 0, "They are a promethean now.")
	src.searching = 2
	var/mob/living/carbon/human/S = new(get_turf(src))
	S.client = candidate.client
	to_chat(S, span_infoplain(span_bold("You are a promethean, brought into existence on [station_name()].")))
	S.mind.assigned_role = JOB_PROMETHEAN
	S.set_species("Promethean")
	S.shapeshifter_set_colour("#05FF9B")
	for(var/mob/M in viewers(get_turf_or_move(loc)))
		M.show_message(span_warning("The monkey cube suddenly takes the shape of a humanoid!"))
	var/newname = sanitize(tgui_input_text(S, "You are a Promethean. Would you like to change your name to something else?", "Name change"), MAX_NAME_LEN)
	if(newname)
		S.real_name = newname
		S.name = S.real_name
		S.dna.real_name = newname
	if(S.mind)
		S.mind.name = S.name
	qdel(src)
