/obj/mecha/tgui_interact(mob/user, datum/tgui/ui, datum/tgui/parent_ui, custom_state)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Mecha", name)
		ui.open()

/obj/mecha/tgui_status(mob/user, datum/tgui_state/state)
	. = ..()
	if(user != occupant)
		. = min(., STATUS_UPDATE)
	if(user.loc != src)
		. = STATUS_CLOSE

/obj/mecha/tgui_data(mob/user, datum/tgui/ui, datum/tgui_state/state)
	var/list/data = ..()

	data["appearance"] = REF(appearance)
	data["internal_damage"] = internal_damage

	data["health"] = health
	data["health_max"] = initial(health)

	var/obj/item/mecha_parts/component/armor/AC = internal_components[MECH_ARMOR]
	data["armor"] = AC?.integrity
	data["armor_max"] = AC?.max_integrity

	var/obj/item/mecha_parts/component/hull/HC = internal_components[MECH_HULL]
	data["hull"] = HC?.integrity
	data["hull_max"] = HC?.max_integrity

	data["cell_charge"] = get_charge()
	data["cell_charge_max"] = cell?.maxcharge

	data["use_internal_tank"] = use_internal_tank

	data["tank_pressure"] = internal_tank ? internal_tank.return_pressure() : null
	data["tank_temperature"] = internal_tank ? internal_tank.return_temperature() : null

	data["cabin_pressure"] = return_pressure()
	data["cabin_temperature"] = return_temperature()

	data["lights"] = lights
	data["dna"] = dna

	data["defence_mode_possible"] = defence_mode_possible
	data["defence_mode"] = defence_mode

	data["overload_possible"] = overload_possible
	data["overload"] = overload

	data["smoke_possible"] = smoke_possible
	data["smoke_reserve"] = smoke_reserve

	data["thrusters_possible"] = thrusters_possible
	data["thrusters"] = thrusters

	var/list/cargo_data = list()
	for(var/atom/movable/AM as anything in cargo)
		cargo_data += list(
			"name" = "[AM]",
			"appearance" = REF(AM.appearance)
		)
	data["cargo"] = cargo_data

	data["radio_broadcasting"] = radio.broadcasting
	data["radio_listening"] = radio.listening
	data["radio_frequency"] = radio.frequency

	data["can_disconnect"] = (/obj/mecha/verb/disconnect_from_port in verbs)
	data["can_connect"] = (/obj/mecha/verb/connect_to_port in verbs)

	data["add_req_access"] = add_req_access
	data["maint_access"] = maint_access

	return data


/obj/mecha/tgui_static_data(mob/user)
	var/list/data = ..()

	data["MECHA_INT_FIRE"] = MECHA_INT_FIRE
	data["MECHA_INT_TEMP_CONTROL"] = MECHA_INT_TEMP_CONTROL
	data["MECHA_INT_SHORT_CIRCUIT"] = MECHA_INT_SHORT_CIRCUIT
	data["MECHA_INT_TANK_BREACH"] = MECHA_INT_TANK_BREACH
	data["MECHA_INT_CONTROL_LOST"] = MECHA_INT_CONTROL_LOST
	data["WARNING_HIGH_PRESSURE"] = WARNING_HIGH_PRESSURE

	return data

/obj/mecha/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(.)
		return

	if(ui.user != occupant)
		return

	switch(action)
		if("eject")
			eject()
			return TRUE
		if("toggle_lights")
			lights()
			return TRUE
		if("toggle_internals")
			internal_tank()
			return TRUE
		if("repair_int_control_lost")
			occupant_message("Recalibrating coordination system.")
			log_message("Recalibration of coordination system started.")
			var/T = loc
			if(do_after(100))
				if(T == loc)
					clearInternalDamage(MECHA_INT_CONTROL_LOST)
					occupant_message(span_blue("Recalibration successful."))
					log_message("Recalibration of coordination system finished with 0 errors.")
				else
					occupant_message(span_red("Recalibration failed."))
					log_message("Recalibration of coordination system failed with 1 error.",1)
