//
// This generator is for the supercool big shields intended for ships that do nice stuff with overmaps.
//
/obj/machinery/power/shield_generator
	name = "advanced shield generator"
	desc = "A heavy-duty shield generator and capacitor, capable of generating energy shields at large distances."
	icon = 'icons/obj/machines/shielding_vr.dmi'
	icon_state = "generator0"
	circuit = /obj/item/circuitboard/shield_generator
	density = TRUE
	var/datum/wires/shield_generator/wires = null
	var/list/field_segments = list()    // List of all shield segments owned by this generator.
	var/list/damaged_segments = list()  // List of shield segments that have failed and are currently regenerating.
	var/shield_modes = 0                // Enabled shield mode flags
	var/mitigation_em = 0               // Current EM mitigation
	var/mitigation_physical = 0         // Current Physical mitigation
	var/mitigation_heat = 0             // Current Burn mitigation
	var/mitigation_max = 0              // Maximal mitigation reachable with this generator. Set by RefreshParts()
	var/max_energy = 0                  // Maximal stored energy. In joules. Depends on the type of used SMES coil when constructing this generator.
	var/current_energy = 0              // Current stored energy.
	var/field_radius = 1                // Current field radius.
	var/target_radius = 1               // Desired field radius.
	var/running = SHIELD_OFF            // Whether the generator is enabled or not.
	var/input_cap = 1 MEGAWATTS         // Currently set input limit. Set to 0 to disable limits altogether. The shield will try to input this value per tick at most
	var/upkeep_power_usage = 0          // Upkeep power usage last tick.
	var/upkeep_multiplier = 1           // Multiplier of upkeep values.
	var/power_coefficient = 1			// Multiplier of overall power usage (for mappers, subtypes, etc)
	var/power_usage = 0                 // Total power usage last tick.
	var/overloaded = 0                  // Whether the field has overloaded and shut down to regenerate.
	var/hacked = 0                      // Whether the generator has been hacked by cutting the safety wire.
	var/offline_for = 0                 // The generator will be inoperable for this duration in ticks.
	var/input_cut = 0                   // Whether the input wire is cut.
	var/mode_changes_locked = 0         // Whether the control wire is cut, locking out changes.
	var/ai_control_disabled = 0         // Whether the AI control is disabled.
	var/list/mode_list = null           // A list of shield_mode datums.
	var/full_shield_strength = 0        // The amount of power shields need to be at full operating strength.
	var/initial_shield_modes = MODEFLAG_HYPERKINETIC|MODEFLAG_EM|MODEFLAG_ATMOSPHERIC|MODEFLAG_HUMANOIDS

	var/idle_multiplier   = 1           // Trades off cost vs. spin-up time from idle to running
	var/idle_valid_values = list(1, 2, 5, 10)
	var/spinup_delay      = 20
	var/spinup_counter    = 0

/obj/machinery/power/shield_generator/update_icon()
	if(running)
		icon_state = "generator1"
		set_light(1, 2, "#66FFFF")
	else
		icon_state = "generator0"
		set_light(0)


/obj/machinery/power/shield_generator/Initialize(mapload)
	. = ..()
	if(!wires)
		wires = new(src)
	default_apply_parts()
	connect_to_network()

	mode_list = list()
	for(var/st in subtypesof(/datum/shield_mode))
		var/datum/shield_mode/SM = new st()
		mode_list.Add(SM)
	toggle_flag(initial_shield_modes)

/obj/machinery/power/shield_generator/Destroy()
	shutdown_field()
	field_segments = null
	damaged_segments = null
	mode_list = null
	. = ..()


/obj/machinery/power/shield_generator/RefreshParts()
	max_energy = 0
	full_shield_strength = 0
	for(var/obj/item/smes_coil/S in component_parts)
		full_shield_strength += (S.ChargeCapacity * 5)
	max_energy = full_shield_strength * 20
	current_energy = between(0, current_energy, max_energy)

	mitigation_max = MAX_MITIGATION_BASE + MAX_MITIGATION_RESEARCH * total_component_rating_of_type(/obj/item/stock_parts/capacitor)
	mitigation_em = between(0, mitigation_em, mitigation_max)
	mitigation_physical = between(0, mitigation_physical, mitigation_max)
	mitigation_heat = between(0, mitigation_heat, mitigation_max)
	..()


// Shuts down the shield, removing all shield segments and unlocking generator settings.
/obj/machinery/power/shield_generator/proc/shutdown_field()
	for(var/obj/effect/shield/S in field_segments)
		qdel(S)

	running = SHIELD_OFF
	current_energy = 0
	mitigation_em = 0
	mitigation_physical = 0
	mitigation_heat = 0
	update_icon()


// Generates the field objects. Deletes existing field, if applicable.
/obj/machinery/power/shield_generator/proc/regenerate_field()
	for(var/obj/effect/shield/S in field_segments)
		qdel(S)
	var/list/shielded_turfs

	if(check_flag(MODEFLAG_HULL))
		shielded_turfs = fieldtype_hull()
	else
		shielded_turfs = fieldtype_square()

	for(var/turf/T in shielded_turfs)
		var/obj/effect/shield/S = new(T)
		S.gen = src
		S.flags_updated()
		field_segments |= S

	//Hull shield chaos icon generation
	if(check_flag(MODEFLAG_HULL))
		var/list/midsections = list()
		var/list/startends = list()
		var/list/corners = list()
		var/list/horror = list()

		for(var/obj/effect/shield/SE in field_segments)
			var/adjacent_fields = 0
			for(var/direction in GLOB.cardinal)
				var/turf/T = get_step(SE, direction)
				var/obj/effect/shield/S = locate() in T
				if(S)
					adjacent_fields |= direction

			//What?
			if(!adjacent_fields)
				horror += SE
				testing("Solo shield turf at [SE.x], [SE.y], [SE.z]")
				continue

			//Middle section or corner (multiple bits set)
			if((adjacent_fields & (adjacent_fields - 1)) != 0)
				//'Impossible' directions
				if(adjacent_fields == (NORTH|SOUTH) || adjacent_fields == (EAST|WEST))
					midsections[SE] = adjacent_fields
				//It's a simple corner
				else //if (adjacent_fields in cornerdirs)
					corners[SE] = adjacent_fields

			//Not 0, not multiple bits, it's a start or an end
			else
				startends[SE] = adjacent_fields

		//Midsections go first
		for(var/obj/effect/shield/SE in midsections)
			var/adjacent = midsections[SE]
			var/turf/L = get_step(SE, ~adjacent & (SOUTH|WEST))
			var/turf/R = get_step(SE, ~adjacent & (NORTH|EAST))
			if(!isspace(L) && !isspace(R))	// Squished in a single tile gap of space!
				switch(adjacent)
					if(NORTH|SOUTH) //Middle vertical section
						if(SE.x < src.x) //Left of generator goes north
							SE.set_dir(NORTH)
						else
							SE.set_dir(SOUTH)
					if(EAST|WEST) //Middle horizontal section
						if(SE.y < src.y) //South of generator goes left
							SE.set_dir(WEST)
						else
							SE.set_dir(EAST)
			else if(isspace(L))
				SE.set_dir(turn(~adjacent & (SOUTH|WEST), -90))
			else
				SE.set_dir(turn(~adjacent & (NORTH|EAST), -90))

			midsections -= SE

		//Some unhandled error state
		for(var/obj/effect/shield/SE in midsections)
			SE.enabled_icon_state = "arrow" //Error state/unhandled

		//Corners
		for(var/obj/effect/shield/S in corners)
			var/adjacent = corners[S]
			if(adjacent in GLOB.cornerdirs)
				do_corner_shield(S, adjacent) //Dir is adjacent fields direction
			else
				// Okay first a quick hack. If only one nonshield...
				var/nonshield = adjacent ^ (NORTH|SOUTH|EAST|WEST)
				if((nonshield & (nonshield - 1)) == 0)
					if(!isspace(get_step(S, nonshield)))
						S.set_dir(turn(nonshield, 90)) // We're basically a normal midsection just with another touching. Ignore it.
						//What's this mysterious 3rd shield touching us?
						var/dir_to_them = turn(nonshield, 180)
						var/turf/T = get_step(S, dir_to_them)
						var/obj/effect/shield/SO = locate() in T
						//They are a corner
						if((SO.dir & (SO.dir - 1)) != 0)
							continue
						else if(dir_to_them & SO.dir) //They're facing away from us, so we're their start
							S.add_overlay(image(icon, icon_state = "shield_start" , dir = SO.dir))
						else if(SO.dir & nonshield) //They're facing us (and the wall)
							S.add_overlay(image(icon, icon_state = "shield_end" , dir = SO.dir))

					else
						var/list/touchnonshield = list()
						for(var/direction in GLOB.cornerdirs)
							var/turf/T = get_step(S, direction)
							if(!isspace(T))
								touchnonshield += T
						if(touchnonshield.len == 1)
							do_corner_shield(S, get_dir(S, touchnonshield[1]))
						else
							S.enabled_icon_state = "capacitor"
				else
					// Not actually a corner... It has MULTIPLE!
					S.enabled_icon_state = "arrow" //Error state/unhandled

		for(var/obj/effect/shield/S in startends)
			var/adjacent = startends[S]
			log_debug("Processing startend [S] at [S?.x],[S?.y] adjacent=[adjacent]")
			var/turf/T = get_step(S, adjacent)
			var/obj/effect/shield/SO = locate() in T
			S.set_dir(SO.dir)
			if(S.dir == adjacent) //Flowing into them
				S.enabled_icon_state = "shield_start"
			else
				S.enabled_icon_state = "shield_end"
	else
		var/turf/gen_turf = get_turf(src)
		for(var/obj/effect/shield/SE in field_segments)
			var/new_dir = 0
			if(SE.x == gen_turf.x - field_radius)
				new_dir |= NORTH
			else if(SE.x == gen_turf.x + field_radius)
				new_dir |= SOUTH
			if(SE.y == gen_turf.y + field_radius)
				new_dir |= EAST
			else if(SE.y == gen_turf.y - field_radius)
				new_dir |= WEST
			if((new_dir & (new_dir - 1)) == 0)
				SE.set_dir(new_dir) // Only one bit set means we are an edge not corner.
			else
				do_corner_shield(SE, turn(new_dir, -90), TRUE) // All our corners are outside, don't check turf type.

	for(var/obj/effect/shield/SE in field_segments)
		SE.update_visuals()

	//Phew, update our own icon
	update_icon()

/obj/machinery/power/shield_generator/proc/do_corner_shield(var/obj/effect/shield/S, var/new_dir, var/force_outside)
	S.enabled_icon_state = "blank"
	S.set_dir(new_dir)
	var/inside = force_outside ? FALSE : isspace(get_step(S, new_dir))
	// TODO - Obviously this can be more elegant
	if(inside)
		switch(new_dir)
			if(NORTHEAST)
				S.add_overlay(image(S.icon, icon_state = "shield_end", dir = SOUTH))
				S.add_overlay(image(S.icon, icon_state = "shield_start", dir = EAST))
			if(NORTHWEST)
				S.add_overlay(image(S.icon, icon_state = "shield_end", dir = EAST))
				S.add_overlay(image(S.icon, icon_state = "shield_start", dir = NORTH))
			if(SOUTHEAST)
				S.add_overlay(image(S.icon, icon_state = "shield_end", dir = WEST))
				S.add_overlay(image(S.icon, icon_state = "shield_start", dir = SOUTH))
			if(SOUTHWEST)
				S.add_overlay(image(S.icon, icon_state = "shield_end", dir = NORTH))
				S.add_overlay(image(S.icon, icon_state = "shield_start", dir = WEST))
	else
		switch(new_dir)
			if(NORTHEAST)
				S.add_overlay(image(S.icon, icon_state = "shield_end", dir = WEST))
				S.add_overlay(image(S.icon, icon_state = "shield_start", dir = NORTH))
			if(NORTHWEST)
				S.add_overlay(image(S.icon, icon_state = "shield_end", dir = SOUTH))
				S.add_overlay(image(S.icon, icon_state = "shield_start", dir = WEST))
			if(SOUTHEAST)
				S.add_overlay(image(S.icon, icon_state = "shield_end", dir = NORTH))
				S.add_overlay(image(S.icon, icon_state = "shield_start", dir = EAST))
			if(SOUTHWEST)
				S.add_overlay(image(S.icon, icon_state = "shield_end", dir = EAST))
				S.add_overlay(image(S.icon, icon_state = "shield_start", dir = SOUTH))


// Recalculates and updates the upkeep multiplier
/obj/machinery/power/shield_generator/proc/update_upkeep_multiplier()
	var/new_upkeep = 1.0
	for(var/datum/shield_mode/SM in mode_list)
		if(check_flag(SM.mode_flag))
			new_upkeep *= SM.multiplier

	upkeep_multiplier = new_upkeep * power_coefficient


/obj/machinery/power/shield_generator/process()
	upkeep_power_usage = 0
	power_usage = 0

	if(offline_for)
		offline_for = max(0, offline_for - 1)
	// We're turned off.
	if(running == SHIELD_OFF)
		return

	if(target_radius != field_radius && running != SHIELD_RUNNING) // Do not recalculate the field while it's running; that's extremely laggy.
		field_radius += (target_radius > field_radius) ? 1 : -1

	// We are shutting down, therefore our stored energy disperses faster than usual.
	else if(running == SHIELD_DISCHARGING)
		current_energy -= SHIELD_SHUTDOWN_DISPERSION_RATE
	else if(running == SHIELD_SPINNING_UP)
		spinup_counter--
		if(spinup_counter <= 0)
			running = SHIELD_RUNNING
			regenerate_field()

	mitigation_em = between(0, mitigation_em - MITIGATION_LOSS_PASSIVE, mitigation_max)
	mitigation_heat = between(0, mitigation_heat - MITIGATION_LOSS_PASSIVE, mitigation_max)
	mitigation_physical = between(0, mitigation_physical - MITIGATION_LOSS_PASSIVE, mitigation_max)

	if(running == SHIELD_RUNNING)
		upkeep_power_usage = round((field_segments.len - damaged_segments.len) * ENERGY_UPKEEP_PER_TILE * upkeep_multiplier)
	else if(running > SHIELD_RUNNING)
		upkeep_power_usage = round(ENERGY_UPKEEP_IDLE * idle_multiplier * (field_radius * 8) * upkeep_multiplier) // Approximates number of turfs.

	if(powernet && (running >= SHIELD_RUNNING) && !input_cut)
		var/energy_buffer = 0
		energy_buffer = draw_power(min(upkeep_power_usage, input_cap))
		power_usage += round(energy_buffer)

		if(energy_buffer < upkeep_power_usage)
			current_energy -= round(upkeep_power_usage - energy_buffer)	// If we don't have enough energy from the grid, take it from the internal battery instead.

		// Now try to recharge our internal energy.
		var/energy_to_demand
		if(input_cap)
			energy_to_demand = between(0, max_energy - current_energy, input_cap - energy_buffer)
		else
			energy_to_demand = max(0, max_energy - current_energy)
		energy_buffer = draw_power(energy_to_demand)
		power_usage += energy_buffer
		current_energy += round(energy_buffer)
	else
		current_energy -= round(upkeep_power_usage)	// We are shutting down, or we lack external power connection. Use energy from internal source instead.

	if(current_energy <= 0)
		energy_failure()

	if(!overloaded)
		for(var/obj/effect/shield/S in damaged_segments)
			S.regenerate()
	else if (field_integrity() > 25)
		overloaded = 0

/obj/machinery/power/shield_generator/attackby(obj/item/O as obj, mob/user as mob)
	if(panel_open && (O?.has_tool_quality(TOOL_MULTITOOL) || O?.has_tool_quality(TOOL_WIRECUTTER)))
		wires.Interact(user)
		return TRUE
	if(default_deconstruction_screwdriver(user, O))
		return
	if(O?.has_tool_quality(TOOL_CROWBAR) || O?.has_tool_quality(TOOL_WRENCH) || istype(O, /obj/item/storage/part_replacer))
		if(offline_for)
			to_chat(user, span_warning("Wait until \the [src] cools down from emergency shutdown first!"))
			return
		if(running)
			to_chat(user, span_notice("Turn off \the [src] first!"))
			return
	if(default_deconstruction_crowbar(user, O))
		return
	if(default_part_replacement(user, O))
		return
	if(default_unfasten_wrench(user, O, 40))
		return
	return ..()

/obj/machinery/power/shield_generator/proc/energy_failure()
	if(running == SHIELD_DISCHARGING)
		shutdown_field()
	else
		current_energy = 0
		overloaded = 1
		for(var/obj/effect/shield/S in field_segments)
			S.fail(1)

/obj/machinery/power/shield_generator/proc/set_idle(var/new_state)
	if(new_state)
		if(running == SHIELD_IDLE)
			return
		running = SHIELD_IDLE
		for(var/obj/effect/shield/S in field_segments)
			qdel(S)
	else
		if(running != SHIELD_IDLE)
			return
		running = SHIELD_SPINNING_UP
		spinup_counter = round(spinup_delay / idle_multiplier)
	update_icon()

/obj/machinery/power/shield_generator/tgui_interact(mob/user, datum/tgui/ui, datum/tgui/parent_ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OvermapShieldGenerator", name) // 500, 800
		ui.open()

/obj/machinery/power/shield_generator/tgui_data(mob/user)
	var/list/data = list()

	data["running"] = running
	data["modes"] = get_flag_descriptions()
	data["overloaded"] = overloaded
	data["mitigation_max"] = mitigation_max
	data["mitigation_physical"] = round(mitigation_physical, 0.1)
	data["mitigation_em"] = round(mitigation_em, 0.1)
	data["mitigation_heat"] = round(mitigation_heat, 0.1)
	data["field_integrity"] = field_integrity()
	data["max_energy"] = round(max_energy / 1000000, 0.1)
	data["current_energy"] = round(current_energy / 1000000, 0.1)
	data["percentage_energy"] = round(data["current_energy"] / data["max_energy"] * 100)
	data["total_segments"] = field_segments ? field_segments.len : 0
	data["functional_segments"] = damaged_segments ? data["total_segments"] - damaged_segments.len : data["total_segments"]
	data["field_radius"] = field_radius
	data["target_radius"] = target_radius
	data["input_cap_kw"] = round(input_cap / 1000)
	data["upkeep_power_usage"] = round(upkeep_power_usage / 1000, 0.1)
	data["power_usage"] = round(power_usage / 1000)
	data["hacked"] = hacked
	data["offline_for"] = offline_for * 2
	data["idle_multiplier"] = idle_multiplier
	data["idle_valid_values"] = idle_valid_values
	data["spinup_counter"] = spinup_counter

	return data

/obj/machinery/power/shield_generator/attack_hand(mob/user)
	if((. = ..()))
		return
	if(panel_open && Adjacent(user))
		wires.Interact(user)
		return
	tgui_interact(user)

/obj/machinery/power/shield_generator/tgui_status(mob/user)
	if(issilicon(user) && !Adjacent(user) && ai_control_disabled)
		return STATUS_UPDATE
	if(panel_open)
		return min(..(), STATUS_DISABLED)
	return ..()

/obj/machinery/power/shield_generator/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return TRUE

	switch(action)
		if("begin_shutdown")
			if(running < SHIELD_RUNNING) // Discharging or off
				return
			var/alert = tgui_alert(ui.user, "Are you sure you wish to do this? It will drain the power inside the internal storage rapidly.", "Are you sure?", list("Yes", "No"))
			if(tgui_status(ui.user, state) != STATUS_INTERACTIVE)
				return
			if(running < SHIELD_RUNNING)
				return
			if(alert == "Yes")
				set_idle(TRUE) // do this first to clear the field
				running = SHIELD_DISCHARGING
			return TRUE

		if("start_generator")
			if(offline_for)
				return
			set_idle(TRUE)
			return TRUE

		if("toggle_idle")
			if(running < SHIELD_RUNNING)
				return TRUE
			set_idle(text2num(params["toggle_idle"]))
			return TRUE

		// Instantly drops the shield, but causes a cooldown before it may be started again. Also carries a risk of EMP at high charge.
		if("emergency_shutdown")
			if(!running)
				return TRUE

			var/choice = tgui_alert(ui.user, "Are you sure that you want to initiate an emergency shield shutdown? This will instantly drop the shield, and may result in unstable release of stored electromagnetic energy. Proceed at your own risk.", "Confirmation", list("No", "Yes"))
			if((choice != "Yes") || !running)
				return TRUE

			// If the shield would take 5 minutes to disperse and shut down using regular methods, it will take x1.5 (7 minutes and 30 seconds) of this time to cool down after emergency shutdown
			offline_for = round(current_energy / (SHIELD_SHUTDOWN_DISPERSION_RATE / 1.5))
			var/old_energy = current_energy
			shutdown_field()
			log_and_message_admins("has triggered \the [src]'s emergency shutdown!", ui.user)
			spawn()
				empulse(src, old_energy / 60000000, old_energy / 32000000, 1) // If shields are charged at 450 MJ, the EMP will be 7.5, 14.0625. 90 MJ, 1.5, 2.8125
			old_energy = 0

			return TRUE

	if(mode_changes_locked)
		return TRUE

	switch(action)
		if("set_range")
			var/new_range = tgui_input_number(ui.user, "Enter new field range (1-[world.maxx]). Leave blank to cancel.", "Field Radius Control", field_radius, world.maxx, 1)
			if(!new_range)
				return TRUE
			target_radius = between(1, new_range, world.maxx)
			return TRUE

		if("set_input_cap")
			var/new_cap = round(tgui_input_number(ui.user, "Enter new input cap (in kW). Enter 0 or nothing to disable input cap.", "Generator Power Control", round(input_cap / 1000)))
			if(!new_cap)
				input_cap = 0
				return
			input_cap = max(0, new_cap) * 1000
			return TRUE

		if("toggle_mode")
			// Toggling hacked-only modes requires the hacked var to be set to 1
			if((text2num(params["toggle_mode"]) & (MODEFLAG_BYPASS | MODEFLAG_OVERCHARGE)) && !hacked)
				return TRUE

			toggle_flag(text2num(params["toggle_mode"]))
			return TRUE

		if("switch_idle")
			if(running == SHIELD_SPINNING_UP)
				return TRUE
			var/new_idle = text2num(params["switch_idle"])
			if(new_idle in idle_valid_values)
				idle_multiplier = new_idle
			return TRUE

/obj/machinery/power/shield_generator/proc/field_integrity()
	if(full_shield_strength)
		return round(CLAMP01(current_energy / full_shield_strength) * 100)
	return 0


// Takes specific amount of damage
/obj/machinery/power/shield_generator/proc/deal_shield_damage(var/damage, var/shield_damtype)
	var/energy_to_use = damage * ENERGY_PER_HP
	if(check_flag(MODEFLAG_MODULATE))
		mitigation_em -= MITIGATION_HIT_LOSS
		mitigation_heat -= MITIGATION_HIT_LOSS
		mitigation_physical -= MITIGATION_HIT_LOSS

		switch(shield_damtype)
			if(SHIELD_DAMTYPE_PHYSICAL)
				mitigation_physical += MITIGATION_HIT_LOSS + MITIGATION_HIT_GAIN
				energy_to_use *= 1 - (mitigation_physical / 100)
			if(SHIELD_DAMTYPE_EM)
				mitigation_em += MITIGATION_HIT_LOSS + MITIGATION_HIT_GAIN
				energy_to_use *= 1 - (mitigation_em / 100)
			if(SHIELD_DAMTYPE_HEAT)
				mitigation_heat += MITIGATION_HIT_LOSS + MITIGATION_HIT_GAIN
				energy_to_use *= 1 - (mitigation_heat / 100)

		mitigation_em = between(0, mitigation_em, mitigation_max)
		mitigation_heat = between(0, mitigation_heat, mitigation_max)
		mitigation_physical = between(0, mitigation_physical, mitigation_max)

	current_energy -= energy_to_use

	// Overload the shield, which will shut it down until we recharge above 25% again
	if(current_energy < 0)
		energy_failure()
		return SHIELD_BREACHED_FAILURE

	if(prob(10 - field_integrity()))
		return SHIELD_BREACHED_CRITICAL
	if(prob(20 - field_integrity()))
		return SHIELD_BREACHED_MAJOR
	if(prob(35 - field_integrity()))
		return SHIELD_BREACHED_MINOR
	return SHIELD_ABSORBED


// Checks whether specific flags are enabled
/obj/machinery/power/shield_generator/proc/check_flag(var/flag)
	return (shield_modes & flag)


/obj/machinery/power/shield_generator/proc/toggle_flag(var/flag)
	shield_modes ^= flag
	update_upkeep_multiplier()
	for(var/obj/effect/shield/S in field_segments)
		S.flags_updated()

	if((flag & (MODEFLAG_HULL|MODEFLAG_MULTIZ)) && (running == SHIELD_RUNNING))
		regenerate_field()

	if(flag & MODEFLAG_MODULATE)
		mitigation_em = 0
		mitigation_physical = 0
		mitigation_heat = 0


/obj/machinery/power/shield_generator/proc/get_flag_descriptions()
	var/list/all_flags = list()
	for(var/datum/shield_mode/SM in mode_list)
		if(SM.hacked_only && !hacked)
			continue
		all_flags.Add(list(list(
			"name" = SM.mode_name,
			"desc" = SM.mode_desc,
			"flag" = SM.mode_flag,
			"status" = check_flag(SM.mode_flag),
			"hacked" = SM.hacked_only,
			"multiplier" = SM.multiplier
		)))
	return all_flags


// These two procs determine tiles that should be shielded given the field range. They are quite CPU intensive and may trigger BYOND infinite loop checks, therefore they are set
// as background procs to prevent locking up the server. They are only called when the field is generated, or when hull mode is toggled on/off.
/obj/machinery/power/shield_generator/proc/fieldtype_square()
	set background = 1
	var/list/out = list()
	var/list/base_turfs = get_base_turfs()

	for(var/turf/gen_turf in base_turfs)
		var/turf/T
		for (var/x_offset = -field_radius; x_offset <= field_radius; x_offset++)
			T = locate(gen_turf.x + x_offset, gen_turf.y - field_radius, gen_turf.z)
			if(T)
				out += T
			T = locate(gen_turf.x + x_offset, gen_turf.y + field_radius, gen_turf.z)
			if(T)
				out += T

		for (var/y_offset = -field_radius+1; y_offset < field_radius; y_offset++)
			T = locate(gen_turf.x - field_radius, gen_turf.y + y_offset, gen_turf.z)
			if(T)
				out += T
			T = locate(gen_turf.x + field_radius, gen_turf.y + y_offset, gen_turf.z)
			if(T)
				out += T
	return out


/obj/machinery/power/shield_generator/proc/fieldtype_hull()
	set background = 1
	. = list()
	var/list/base_turfs = get_base_turfs()

	// Old code found all space turfs and added them if it had a non-space neighbor.
	// This one finds all non-space turfs and adds all its non-space neighbors.
	for(var/turf/gen_turf in base_turfs)
		var/area/TA = null // Variable for area checking. Defining it here so memory does not have to be allocated repeatedly.
		for(var/turf/T in trange(field_radius, gen_turf))
			// Don't expand to space or on shuttle areas.
			if(isopenturf(T))
				continue

			// Find adjacent space/shuttle tiles and cover them. Shuttles won't be blocked if shield diffuser is mapped in and turned on.
			for(var/turf/TN in orange(1, T))
				TA = get_area(TN)
				//if ((istype(TN, /turf/space) || (istype(TN, /turf/simulated/open) && (istype(TA, /area/space) || TA.area_flags & AREA_FLAG_EXTERNAL))))
				if((istype(TN, /turf/space) || (istype(TN, /turf/simulated/open) && (istype(TA, /area/space)))))
					. |= TN
					continue

// Returns a list of turfs from which a field will propagate. If multi-Z mode is enabled, this will return a "column" of turfs above and below the generator.
/obj/machinery/power/shield_generator/proc/get_base_turfs()
	var/list/turfs = list()
	var/turf/T = get_turf(src)

	if(!istype(T))
		return

	turfs.Add(T)

	// Multi-Z mode is disabled
	if(!check_flag(MODEFLAG_MULTIZ))
		return turfs

	while(HasAbove(T.z))
		T = GetAbove(T)
		if(istype(T))
			turfs.Add(T)

	T = get_turf(src)

	while(HasBelow(T.z))
		T = GetBelow(T)
		if(istype(T))
			turfs.Add(T)

	return turfs


// Starts fully charged
/obj/machinery/power/shield_generator/charged/Initialize(mapload)
	. = ..()
	current_energy = max_energy

// Starts with the best SMES coil and capacitor (and fully charged)
/obj/machinery/power/shield_generator/upgraded/Initialize(mapload)
	. = ..()
	for(var/obj/item/smes_coil/sc in component_parts)
		component_parts -= sc
		qdel(sc)

	for(var/obj/item/stock_parts/capacitor/cap in component_parts)
		component_parts -= cap
		qdel(cap)

	component_parts += new /obj/item/stock_parts/capacitor/hyper(src)
	component_parts += new /obj/item/smes_coil/super_capacity(src)
	RefreshParts()
	current_energy = max_energy

// Only uses 20% as much power (and starts upgraded and charged and hacked)
/obj/machinery/power/shield_generator/upgraded/admin
	name = "experimental shield generator"
	power_coefficient = 0.2
	hacked = TRUE
