#define MULE_IDLE 0
#define MULE_MOVING 1
#define MULE_UNLOAD 2
#define MULE_LOST 3
#define MULE_CALC_MIN 4
#define MULE_CALC_MAX 10
#define MULE_PATH_DONE 11
// IF YOU CHANGE THOSE, UPDATE THEM IN pda.tmpl TOO

/mob/living/bot/mulebot
	name = "Mulebot"
	desc = "A Multiple Utility Load Effector bot."
	icon_state = "mulebot0"
	anchored = TRUE
	density = TRUE
	health = 150
	maxHealth = 150
	mob_bump_flag = HEAVY

	min_target_dist = 0
	max_target_dist = 250
	target_speed = 3
	max_frustration = 5
	botcard_access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mining, access_mining_station)

	var/atom/movable/load

	var/paused = 0
	var/crates_only = 1
	var/auto_return = 1
	var/safety = 1

	var/targetName
	var/turf/home
	var/homeName

	var/global/amount = 0

/mob/living/bot/mulebot/Initialize(mapload)
	. = ..()

	var/turf/T = get_turf(loc)
	var/obj/machinery/navbeacon/N = locate() in T
	if(N)
		home = T
		homeName = N.location
	else
		homeName = "Unset"

	suffix = num2text(++amount) // Starts from 1

	name = "Mulebot #[suffix]"

/mob/living/bot/mulebot/MouseDrop_T(var/atom/movable/C, var/mob/user)
	if(user.stat)
		return

	if(!istype(C) || C.anchored || get_dist(user, src) > 1 || get_dist(src, C) > 1 )
		return

	load(C)

/mob/living/bot/mulebot/attack_hand(var/mob/user)
	tgui_interact(user)

/mob/living/bot/mulebot/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MuleBot", "Mulebot [suffix ? "([suffix])" : ""]")
		ui.open()

/mob/living/bot/mulebot/tgui_data(mob/user)
	var/list/data = ..()
	data["suffix"] = suffix
	data["power"] = on
	data["issillicon"] = issilicon(user)
	data["load"] = load
	data["locked"] = locked
	data["auto_return"] = auto_return
	data["crates_only"] = crates_only
	data["hatch"] = open
	data["safety"] = safety
	return data

/mob/living/bot/mulebot/tgui_act(action, params, datum/tgui/ui)
	if(..())
		return TRUE

	add_fingerprint(ui.user)
	switch(action)
		if("power")
			if(on)
				turn_off()
			else
				turn_on()
			visible_message("[ui.user] switches [on ? "on" : "off"] [src].")
			. = TRUE

		if("stop")
			obeyCommand(ui.user, "Stop")
			. = TRUE

		if("go")
			obeyCommand(ui.user, "GoTD")
			. = TRUE

		if("home")
			obeyCommand(ui.user, "Home")
			. = TRUE

		if("destination")
			obeyCommand(ui.user, "SetD")
			. = TRUE

		if("sethome")
			var/new_dest
			var/list/beaconlist = GetBeaconList()
			if(beaconlist.len)
				new_dest = tgui_input_list(ui.user, "Select new home tag", "Mulebot [suffix ? "([suffix])" : ""]", beaconlist)
			else
				tgui_alert_async(ui.user, "No destination beacons available.")
			if(new_dest)
				home = get_turf(beaconlist[new_dest])
				homeName = new_dest
			. = TRUE

		if("unload")
			unload()
			. = TRUE

		if("autoret")
			auto_return = !auto_return
			. = TRUE

		if("cargotypes")
			crates_only = !crates_only
			. = TRUE

		if("safety")
			safety = !safety
			. = TRUE

/mob/living/bot/mulebot/attackby(var/obj/item/O, var/mob/user)
	..()
	update_icons()

/mob/living/bot/mulebot/proc/obeyCommand(mob/user, var/command)
	switch(command)
		if("Home")
			resetTarget()
			target = home
			targetName = "Home"
		if("SetD")
			var/new_dest
			var/list/beaconlist = GetBeaconList()
			if(beaconlist.len)
				new_dest = tgui_input_list(user, "Select new destination tag", "Mulebot [suffix ? "([suffix])" : ""]", beaconlist)
			else
				tgui_alert_async(user, "No destination beacons available.")
			if(new_dest)
				resetTarget()
				target = get_turf(beaconlist[new_dest])
				targetName = new_dest
		if("GoTD")
			paused = 0
		if("Stop")
			paused = 1

/mob/living/bot/mulebot/emag_act(var/remaining_charges, var/user)
	locked = !locked
	to_chat(user, span_notice("You [locked ? "lock" : "unlock"] the mulebot's controls!"))
	flick("mulebot-emagged", src)
	playsound(src, 'sound/effects/sparks1.ogg', 100, 0)
	return 1

/mob/living/bot/mulebot/update_icons()
	if(open)
		icon_state = "mulebot-hatch"
		return
	if(target_path.len && !paused)
		icon_state = "mulebot1"
		return
	icon_state = "mulebot0"

/mob/living/bot/mulebot/handleRegular()
	if(!safety && prob(1))
		flick("mulebot-emagged", src)
	update_icons()

/mob/living/bot/mulebot/handleFrustrated(has_target)
	automatic_custom_emote(AUDIBLE_MESSAGE, "makes a sighing buzz.")
	playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
	..()

/mob/living/bot/mulebot/handleAdjacentTarget()
	if(target == src.loc)
		automatic_custom_emote(AUDIBLE_MESSAGE, "makes a chiming sound.")
		playsound(src, 'sound/machines/chime.ogg', 50, 0)
		UnarmedAttack(target)
		resetTarget()
		if(auto_return && home && (loc != home))
			target = home
			targetName = "Home"

/mob/living/bot/mulebot/confirmTarget()
	return 1

/mob/living/bot/mulebot/calcTargetPath()
	..()
	if(!target_path.len && target != home) // I presume that target is not null
		resetTarget()
		target = home
		targetName = "Home"

/mob/living/bot/mulebot/stepToTarget()
	if(paused)
		return
	..()

/mob/living/bot/mulebot/UnarmedAttack(var/turf/T)
	if(T == src.loc)
		unload(dir)

/mob/living/bot/mulebot/Bump(var/mob/living/M)
	if(!safety && istype(M))
		visible_message(span_warning("[src] knocks over [M]!"))
		M.Stun(8)
		M.Weaken(5)
	..()

/mob/living/bot/mulebot/proc/runOver(var/mob/living/M)
	if(istype(M)) // At this point, MULEBot has somehow crossed over onto your tile with you still on it. CRRRNCH.
		visible_message(span_warning("[src] drives over [M]!"))
		playsound(src, 'sound/effects/splat.ogg', 50, 1)

		var/damage = rand(5, 7)
		M.apply_damage(2 * damage, BRUTE, BP_HEAD)
		M.apply_damage(2 * damage, BRUTE, BP_TORSO)
		M.apply_damage(0.5 * damage, BRUTE, BP_L_LEG)
		M.apply_damage(0.5 * damage, BRUTE, BP_R_LEG)
		M.apply_damage(0.5 * damage, BRUTE, BP_L_ARM)
		M.apply_damage(0.5 * damage, BRUTE, BP_R_ARM)

		blood_splatter(src, M, 1)

/mob/living/bot/mulebot/relaymove(var/mob/user, var/direction)
	if(load == user)
		unload(direction)

/mob/living/bot/mulebot/explode()
	unload(pick(0, 1, 2, 4, 8))

	visible_message(span_danger("[src] blows apart!"))

	var/turf/Tsec = get_turf(src)
	new /obj/item/assembly/prox_sensor(Tsec)
	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/cable_coil/cut(Tsec)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	new /obj/effect/decal/cleanable/blood/oil(Tsec)
	..()

/mob/living/bot/mulebot/proc/GetBeaconList()
	var/list/beaconlist = list()
	for(var/obj/machinery/navbeacon/N in GLOB.navbeacons)
		if(!N.codes["delivery"])
			continue
		beaconlist.Add(N.location)
		beaconlist[N.location] = N
	return beaconlist

/mob/living/bot/mulebot/proc/load(var/atom/movable/C)
	if(busy || load || get_dist(C, src) > 1 || !isturf(C.loc))
		return

	for(var/obj/structure/plasticflaps/P in src.loc)//Takes flaps into account
		if(!CanPass(C,P))
			return

	if(crates_only && !istype(C,/obj/structure/closet/crate))
		automatic_custom_emote(AUDIBLE_MESSAGE, "makes a sighing buzz.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
		return

	var/obj/structure/closet/crate/crate = C
	if(istype(crate))
		crate.close()

	busy = 1

	C.forceMove(loc)
	sleep(2)
	if(C.loc != loc) //To prevent you from going onto more than one bot.
		return
	C.forceMove(src)
	load = C

	C.pixel_y += 9
	if(C.layer < layer)
		C.layer = layer + 0.1
	add_overlay(C)

	busy = 0

/mob/living/bot/mulebot/proc/unload(var/dirn = 0)
	if(!load || busy)
		return

	busy = 1
	cut_overlays()

	load.forceMove(loc)
	load.pixel_y -= 9
	load.layer = initial(load.layer)

	if(dirn)
		step(load, dirn)

	load = null

	for(var/atom/movable/AM in src)
		if(AM == botcard || AM == access_scanner)
			continue

		AM.forceMove(loc)
		AM.layer = initial(AM.layer)
		AM.pixel_y = initial(AM.pixel_y)
	busy = 0

#undef MULE_IDLE
#undef MULE_MOVING
#undef MULE_UNLOAD
#undef MULE_LOST
#undef MULE_CALC_MIN
#undef MULE_CALC_MAX
#undef MULE_PATH_DONE
