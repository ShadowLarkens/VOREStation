/obj/mecha/verb/view_stats()
	set name = "View Stats"
	set category = "Exosuit Interface"
	set src = usr.loc

	set popup_menu = 0
	if(usr != src.occupant)
		return

	tgui_interact(occupant)
	occupant << browse(get_stats_html(), "window=exosuit")


////////////////////////////////////
///// Rendering stats window ///////
////////////////////////////////////

/obj/mecha/proc/get_stats_html()
	var/output = {"<html>
						<head><title>[src.name] data</title>
						<style>
						body {color: #00ff00; background: #000000; font-family:"Lucida Console",monospace; font-size: 12px;}
						hr {border: 1px solid #0f0; color: #0f0; background-color: #0f0;}
						a {padding:2px 5px;;color:#0f0;}
						.wr {margin-bottom: 5px;}
						.header {cursor:pointer;}
						.open, .closed {background: #32CD32; color:#000; padding:1px 2px;}
						.links a {margin-bottom: 2px;padding-top:3px;}
						.visible {display: block;}
						.hidden {display: none;}
						</style>
						<script language='javascript' type='text/javascript'>
						[js_byjax]
						[js_dropdowns]
						function ticker() {
						    setInterval(function(){
						        window.location='byond://?src=\ref[src]&update_content=1';
						    }, 1000);
						}

						window.onload = function() {
							dropdowns();
							ticker();
						}
						</script>
						</head>
						<body>
						<div id='content'>
						[src.get_stats_part()]
						</div>
						<div id='eq_list'>
						[src.get_equipment_list()]
						</div>
						<hr>
						<div id='commands'>
						[src.get_commands()]
						</div>
						</body>
						</html>
					 "}
	return output


/obj/mecha/proc/report_internal_damage()
	var/output = null
	var/list/dam_reports = list(
										"[MECHA_INT_FIRE]" = "<font color='red'><b>INTERNAL FIRE</b></font>",
										"[MECHA_INT_TEMP_CONTROL]" = "<font color='red'><b>LIFE SUPPORT SYSTEM MALFUNCTION</b></font>",
										"[MECHA_INT_TANK_BREACH]" = "<font color='red'><b>GAS TANK BREACH</b></font>",
										"[MECHA_INT_CONTROL_LOST]" = "<font color='red'><b>COORDINATION SYSTEM CALIBRATION FAILURE</b></font> - <a href='byond://?src=\ref[src];repair_int_control_lost=1'>Recalibrate</a>",
										"[MECHA_INT_SHORT_CIRCUIT]" = "<font color='red'><b>SHORT CIRCUIT</b></font>"
										)
	for(var/tflag in dam_reports)
		var/intdamflag = text2num(tflag)
		if(hasInternalDamage(intdamflag))
			output += dam_reports[tflag]
			output += "<br />"
	if(return_pressure() > WARNING_HIGH_PRESSURE)
		output += "<font color='red'><b>DANGEROUSLY HIGH CABIN PRESSURE</b></font><br />"
	return output


/obj/mecha/proc/get_stats_part()
	var/integrity = health/initial(health)*100
	var/cell_charge = get_charge()
	var/tank_pressure = internal_tank ? round(internal_tank.return_pressure(),0.01) : "None"
	var/tank_temperature = internal_tank ? internal_tank.return_temperature() : "Unknown"
	var/cabin_pressure = round(return_pressure(),0.01)

	var/obj/item/mecha_parts/component/hull/HC = internal_components[MECH_HULL]
	var/obj/item/mecha_parts/component/armor/AC = internal_components[MECH_ARMOR]

	var/output = {"[report_internal_damage()]
						<b>Armor Integrity: </b>[AC?"[round(AC.integrity / AC.max_integrity * 100, 0.1)]%":span_warning("ARMOR MISSING")]<br>
						<b>Hull Integrity: </b>[HC?"[round(HC.integrity / HC.max_integrity * 100, 0.1)]%":span_warning("HULL MISSING")]<br>
						[integrity<30?"<font color='red'><b>DAMAGE LEVEL CRITICAL</b></font><br>":null]
						<b>Chassis Integrity: </b> [integrity]%<br>
						<b>Powercell charge: </b>[isnull(cell_charge)?"No powercell installed":"[cell.percent()]%"]<br>
						<b>Air source: </b>[use_internal_tank?"Internal Airtank":"Environment"]<br>
						<b>Airtank pressure: </b>[tank_pressure]kPa<br>
						<b>Airtank temperature: </b>[tank_temperature]K|[tank_temperature - T0C]&deg;C<br>
						<b>Cabin pressure: </b>[cabin_pressure>WARNING_HIGH_PRESSURE ? "<font color='red'>[cabin_pressure]</font>": cabin_pressure]kPa<br>
						<b>Cabin temperature: </b> [return_temperature()]K|[return_temperature() - T0C]&deg;C<br>
						<b>Lights: </b>[lights?"on":"off"]<br>
						[src.dna?"<b>DNA-locked:</b><br> <span style='font-size:10px;letter-spacing:-1px;'>[src.dna]</span> \[<a href='byond://?src=\ref[src];reset_dna=1'>Reset</a>\]<br>":null]
					"}


	if(defence_mode_possible)
		output += span_bold("Defence mode: [defence_mode?"on":"off"]") + "<br>"
	if(overload_possible)
		output += span_bold("Leg actuators overload: [overload?"on":"off"]") + "<br>"
	if(smoke_possible)
		output += span_bold("Smoke:") + " [smoke_reserve]<br>"
	if(thrusters_possible)
		output += span_bold("Thrusters:") + " [thrusters?"on":"off"]<br>"

//Cargo components. Keep this last otherwise it does weird alignment issues.
	output += span_bold("Cargo Compartment Contents:") + "<div style=\"margin-left: 15px;\">"
	if(src.cargo.len)
		for(var/obj/O in src.cargo)
			output += "<a href='byond://?src=\ref[src];drop_from_cargo=\ref[O]'>Unload</a> : [O]<br>"
	else
		output += "Nothing"
	output += "</div>"
	return output

/obj/mecha/proc/get_commands()
	var/output = {"<div class='wr'>
						<div class='header'>Electronics</div>
						<div class='links'>
						<a href='byond://?src=\ref[src];toggle_lights=1'>Toggle Lights</a><br>
						<b>Radio settings:</b><br>
						Microphone: <a href='byond://?src=\ref[src];rmictoggle=1'><span id="rmicstate">[radio.broadcasting?"Engaged":"Disengaged"]</span></a><br>
						Speaker: <a href='byond://?src=\ref[src];rspktoggle=1'><span id="rspkstate">[radio.listening?"Engaged":"Disengaged"]</span></a><br>
						Frequency:
						<a href='byond://?src=\ref[src];rfreq=-10'>-</a>
						<a href='byond://?src=\ref[src];rfreq=-2'>-</a>
						<span id="rfreq">[format_frequency(radio.frequency)]</span>
						<a href='byond://?src=\ref[src];rfreq=2'>+</a>
						<a href='byond://?src=\ref[src];rfreq=10'>+</a><br>
						</div>
						</div>
						<div class='wr'>
						<div class='header'>Airtank</div>
						<div class='links'>
						<a href='byond://?src=\ref[src];toggle_airtank=1'>Toggle Internal Airtank Usage</a><br>
						[(/obj/mecha/verb/disconnect_from_port in src.verbs)?"<a href='byond://?src=\ref[src];port_disconnect=1'>Disconnect from port</a><br>":null]
						[(/obj/mecha/verb/connect_to_port in src.verbs)?"<a href='byond://?src=\ref[src];port_connect=1'>Connect to port</a><br>":null]
						</div>
						</div>
						<div class='wr'>
						<div class='header'>Permissions & Logging</div>
						<div class='links'>
						<a href='byond://?src=\ref[src];toggle_id_upload=1'><span id='t_id_upload'>[add_req_access?"L":"Unl"]ock ID upload panel</span></a><br>
						<a href='byond://?src=\ref[src];toggle_maint_access=1'><span id='t_maint_access'>[maint_access?"Forbid":"Permit"] maintenance protocols</span></a><br>
						<a href='byond://?src=\ref[src];dna_lock=1'>DNA-lock</a><br>
						<a href='byond://?src=\ref[src];view_log=1'>View internal log</a><br>
						<a href='byond://?src=\ref[src];change_name=1'>Change exosuit name</a><br>
						</div>
						</div>
						<div id='equipment_menu'>[get_equipment_menu()]</div>
						<hr>
						[(/obj/mecha/verb/eject in src.verbs)?"<a href='byond://?src=\ref[src];eject=1'>Eject</a><br>":null]
						"}
	return output

/obj/mecha/proc/get_equipment_menu() //outputs mecha html equipment menu
	var/output
	if(equipment.len)
		output += {"<div class='wr'>
						<div class='header'>Equipment</div>
						<div class='links'>"}
		for(var/obj/item/mecha_parts/mecha_equipment/W in hull_equipment)
			output += "Hull Module: [W.name] <a href='byond://?src=\ref[W];detach=1'>Detach</a><br>"
		for(var/obj/item/mecha_parts/mecha_equipment/W in weapon_equipment)
			output += "Weapon Module: [W.name] <a href='byond://?src=\ref[W];detach=1'>Detach</a><br>"
		for(var/obj/item/mecha_parts/mecha_equipment/W in utility_equipment)
			output += "Utility Module: [W.name] <a href='byond://?src=\ref[W];detach=1'>Detach</a><br>"
		for(var/obj/item/mecha_parts/mecha_equipment/W in universal_equipment)
			output += "Universal Module: [W.name] <a href='byond://?src=\ref[W];detach=1'>Detach</a><br>"
		for(var/obj/item/mecha_parts/mecha_equipment/W in special_equipment)
			output += "Special Module: [W.name] <a href='byond://?src=\ref[W];detach=1'>Detach</a><br>"
		for(var/obj/item/mecha_parts/mecha_equipment/W in micro_utility_equipment) // VOREstation Edit -  Adds micro equipent to the menu
			output += "Micro Utility Module: [W.name] <a href='byond://?src=\ref[W];detach=1'>Detach</a><br>"
		for(var/obj/item/mecha_parts/mecha_equipment/W in micro_weapon_equipment)
			output += "Micro Weapon Module: [W.name] <a href='byond://?src=\ref[W];detach=1'>Detach</a><br>"
	output += {"<b>Available hull slots:</b> [max_hull_equip-hull_equipment.len]<br>
	 <b>Available weapon slots:</b> [max_weapon_equip-weapon_equipment.len]<br>
	 <b>Available micro weapon slots:</b> [max_micro_weapon_equip-micro_weapon_equipment.len]<br>
	 <b>Available utility slots:</b> [max_utility_equip-utility_equipment.len]<br>
	 <b>Available micro utility slots:</b> [max_micro_utility_equip-micro_utility_equipment.len]<br>
	 <b>Available universal slots:</b> [max_universal_equip-universal_equipment.len]<br>
	 <b>Available special slots:</b> [max_special_equip-special_equipment.len]<br>
	 </div></div>
	 "}
	return output

/obj/mecha/proc/get_equipment_list() //outputs mecha equipment list in html
	if(!equipment.len)
		return
	var/output = span_bold("Equipment:") + "<div style=\"margin-left: 15px;\">"
	for(var/obj/item/mecha_parts/mecha_equipment/MT in equipment)
		output += "<div id='\ref[MT]'>[MT.get_equip_info()]</div>"
	output += "</div>"
	return output


/obj/mecha/proc/get_log_html()
	var/output = "<html><head><title>[src.name] Log</title></head><body style='font: 13px 'Courier', monospace;'>"
	for(var/list/entry in log)
		output += {"<div style='font-weight: bold;'>[time2text(entry["time"],"DDD MMM DD hh:mm:ss")] [game_year]</div>
						<div style='margin-left:15px; margin-bottom:10px;'>[entry["message"]]</div>
						"}
	output += "</body></html>"
	return output

/obj/mecha/proc/get_log_tgui()
	var/list/data = list()
	for(var/list/entry in log)
		data.Add(list(list(
			"time" = time2text(entry["time"], "DDD MMM DD hh:mm:ss"),
			"year" = game_year,
			"message" = entry["message"],
		)))
	return data


/obj/mecha/proc/output_access_dialog(obj/item/card/id/id_card, mob/user)
	if(!id_card || !user) return
	var/output = {"<html>
						<head><style>
						h1 {font-size:15px;margin-bottom:4px;}
						body {color: #00ff00; background: #000000; font-family:"Courier New", Courier, monospace; font-size: 12px;}
						a {color:#0f0;}
						</style>
						</head>
						<body>
						<h1>Following keycodes are present in this system:</h1>"}
	for(var/a in operation_req_access)
		output += "[get_access_desc(a)] - <a href='byond://?src=\ref[src];del_req_access=[a];user=\ref[user];id_card=\ref[id_card]'>Delete</a><br>"
	output += "<hr><h1>Following keycodes were detected on portable device:</h1>"
	for(var/a in id_card.GetAccess())
		if(a in operation_req_access) continue
		var/a_name = get_access_desc(a)
		if(!a_name) continue //there's some strange access without a name
		output += "[a_name] - <a href='byond://?src=\ref[src];add_req_access=[a];user=\ref[user];id_card=\ref[id_card]'>Add</a><br>"
	output += "<hr><a href='byond://?src=\ref[src];finish_req_access=1;user=\ref[user]'>Finish</a> <font color='red'>(Warning! The ID upload panel will be locked. It can be unlocked only through Exosuit Interface.)</font>"
	output += "</body></html>"
	user << browse(output, "window=exosuit_add_access")
	onclose(user, "exosuit_add_access")
	return

/obj/mecha/proc/output_maintenance_dialog(obj/item/card/id/id_card,mob/user)
	if(!id_card || !user) return

	var/maint_options = "<a href='byond://?src=\ref[src];set_internal_tank_valve=1;user=\ref[user]'>Set Cabin Air Pressure</a>"
	if (locate(/obj/item/mecha_parts/mecha_equipment/tool/passenger) in contents)
		maint_options += "<a href='byond://?src=\ref[src];remove_passenger=1;user=\ref[user]'>Remove Passenger</a>"

	var/output = {"<html>
						<head>
						<style>
						body {color: #00ff00; background: #000000; font-family:"Courier New", Courier, monospace; font-size: 12px;}
						a {padding:2px 5px; background:#32CD32;color:#000;display:block;margin:2px;text-align:center;text-decoration:none;}
						</style>
						</head>
						<body>
						[add_req_access?"<a href='byond://?src=\ref[src];req_access=1;id_card=\ref[id_card];user=\ref[user]'>Edit operation keycodes</a>":null]
						[maint_access?"<a href='byond://?src=\ref[src];maint_access=1;id_card=\ref[id_card];user=\ref[user]'>Initiate maintenance protocol</a>":null]
						[(state>0) ? maint_options : ""]
						</body>
						</html>"}
	user << browse(output, "window=exosuit_maint_console")
	onclose(user, "exosuit_maint_console")
	return


/////////////////
///// Topic /////
/////////////////

/obj/mecha/Topic(href, href_list)
	..()
	if(href_list["update_content"])
		if(usr != src.occupant)	return
		send_byjax(src.occupant,"exosuit.browser","content",src.get_stats_part())
		return
	if(href_list["close"])
		return
	if(usr.stat > 0)
		return
	var/datum/topic_input/top_filter = new /datum/topic_input(href,href_list)
	if(href_list["select_equip"])
		if(usr != src.occupant)	return
		var/obj/item/mecha_parts/mecha_equipment/equip = top_filter.getObj("select_equip")
		if(equip)
			src.selected = equip
			src.occupant_message("You switch to [equip].")
			src.visible_message("[src] raises [equip].")
			send_byjax(src.occupant,"exosuit.browser","eq_list",src.get_equipment_list())
		return
	if(href_list["eject"])
		if(usr != src.occupant)	return
		src.eject()
		return
	if(href_list["toggle_lights"])
		if(usr != src.occupant)	return
		src.lights()
		return
/*
	if(href_list["toggle_strafing"])
		if(usr != src.occupant)	return
		src.strafing()
		return*/

	if(href_list["toggle_airtank"])
		if(usr != src.occupant)	return
		src.internal_tank()
		return
	if (href_list["toggle_thrusters"])
		src.toggle_thrusters()
	if (href_list["smoke"])
		src.smoke()
	if (href_list["toggle_zoom"])
		src.zoom()
	if(href_list["toggle_defence_mode"])
		src.defence_mode()
	if(href_list["switch_damtype"])
		src.switch_damtype()
	if(href_list["phasing"])
		src.phasing()

	if(href_list["rmictoggle"])
		if(usr != src.occupant)	return
		radio.broadcasting = !radio.broadcasting
		send_byjax(src.occupant,"exosuit.browser","rmicstate",(radio.broadcasting?"Engaged":"Disengaged"))
		return
	if(href_list["rspktoggle"])
		if(usr != src.occupant)	return
		radio.listening = !radio.listening
		send_byjax(src.occupant,"exosuit.browser","rspkstate",(radio.listening?"Engaged":"Disengaged"))
		return
	if(href_list["rfreq"])
		if(usr != src.occupant)	return
		var/new_frequency = (radio.frequency + top_filter.getNum("rfreq"))
		if ((radio.frequency < PUBLIC_LOW_FREQ || radio.frequency > PUBLIC_HIGH_FREQ))
			new_frequency = sanitize_frequency(new_frequency)
		radio.set_frequency(new_frequency)
		send_byjax(src.occupant,"exosuit.browser","rfreq","[format_frequency(radio.frequency)]")
		return
	if(href_list["port_disconnect"])
		if(usr != src.occupant)	return
		src.disconnect_from_port()
		return
	if (href_list["port_connect"])
		if(usr != src.occupant)	return
		src.connect_to_port()
		return
	if (href_list["view_log"])
		if(usr != src.occupant)	return
		src.occupant << browse(src.get_log_html(), "window=exosuit_log")
		onclose(occupant, "exosuit_log")
		return
	if (href_list["change_name"])
		if(usr != src.occupant)	return
		var/newname = sanitizeSafe(tgui_input_text(occupant,"Choose new exosuit name","Rename exosuit",initial(name), MAX_NAME_LEN), MAX_NAME_LEN)
		if(newname)
			name = newname
		else
			tgui_alert_async(occupant, "nope.avi")
		return
	if (href_list["toggle_id_upload"])
		if(usr != src.occupant)	return
		add_req_access = !add_req_access
		send_byjax(src.occupant,"exosuit.browser","t_id_upload","[add_req_access?"L":"Unl"]ock ID upload panel")
		return
	if(href_list["toggle_maint_access"])
		if(usr != src.occupant)	return
		if(state)
			occupant_message(span_red("Maintenance protocols in effect"))
			return
		maint_access = !maint_access
		send_byjax(src.occupant,"exosuit.browser","t_maint_access","[maint_access?"Forbid":"Permit"] maintenance protocols")
		return
	if(href_list["req_access"] && add_req_access)
		if(!in_range(src, usr))	return
		output_access_dialog(top_filter.getObj("id_card"),top_filter.getMob("user"))
		return
	if(href_list["maint_access"] && maint_access)
		if(!in_range(src, usr))	return
		var/mob/user = top_filter.getMob("user")
		if(user)
			if(state==MECHA_OPERATING)
				state = MECHA_BOLTS_SECURED
				to_chat(user, "The securing bolts are now exposed.")
			else if(state==MECHA_BOLTS_SECURED)
				state = MECHA_OPERATING
				to_chat(user, "The securing bolts are now hidden.")
			output_maintenance_dialog(top_filter.getObj("id_card"),user)
		return
	if(href_list["set_internal_tank_valve"] && state >=MECHA_BOLTS_SECURED)
		if(!in_range(src, usr))	return
		var/mob/user = top_filter.getMob("user")
		if(user)
			var/new_pressure = tgui_input_number(user,"Input new output pressure","Pressure setting",internal_tank_valve, round_value=FALSE)
			if(new_pressure)
				internal_tank_valve = new_pressure
				to_chat(user, "The internal pressure valve has been set to [internal_tank_valve]kPa.")
	if(href_list["remove_passenger"] && state >= MECHA_BOLTS_SECURED)
		var/mob/user = top_filter.getMob("user")
		var/list/passengers = list()
		for (var/obj/item/mecha_parts/mecha_equipment/tool/passenger/P in contents)
			if (P.occupant)
				passengers["[P.occupant]"] = P

		if (!passengers)
			to_chat(user, span_warning("There are no passengers to remove."))
			return

		var/pname = tgui_input_list(user, "Choose a passenger to forcibly remove.", "Forcibly Remove Passenger", passengers)

		if (!pname)
			return

		var/obj/item/mecha_parts/mecha_equipment/tool/passenger/P = passengers[pname]
		var/mob/occupant = P.occupant

		user.visible_message(span_infoplain(span_bold("\The [user]") + " begins opening the hatch on \the [P]..."), span_notice("You begin opening the hatch on \the [P]..."))
		if (!do_after(user, 40))
			return

		user.visible_message(span_infoplain(span_bold("\The [user]") + " opens the hatch on \the [P] and removes [occupant]!"), span_notice("You open the hatch on \the [P] and remove [occupant]!"))
		P.go_out()
		P.log_message("[occupant] was removed.")
		return
	if(href_list["add_req_access"] && add_req_access && top_filter.getObj("id_card"))
		if(!in_range(src, usr))	return
		operation_req_access += top_filter.getNum("add_req_access")
		output_access_dialog(top_filter.getObj("id_card"),top_filter.getMob("user"))
		return
	if(href_list["del_req_access"] && add_req_access && top_filter.getObj("id_card"))
		if(!in_range(src, usr))	return
		operation_req_access -= top_filter.getNum("del_req_access")
		output_access_dialog(top_filter.getObj("id_card"),top_filter.getMob("user"))
		return
	if(href_list["finish_req_access"])
		if(!in_range(src, usr))	return
		add_req_access = 0
		var/mob/user = top_filter.getMob("user")
		user << browse(null,"window=exosuit_add_access")
		return
	if(href_list["dna_lock"])
		if(usr != src.occupant)	return
		if(istype(occupant, /mob/living/carbon/brain))
			occupant_message("You are a brain. No.")
			return
		if(src.occupant)
			src.dna = src.occupant.dna.unique_enzymes
			src.occupant_message("You feel a prick as the needle takes your DNA sample.")
		return
	if(href_list["reset_dna"])
		if(usr != src.occupant)	return
		src.dna = null
	if(href_list["repair_int_control_lost"])
		if(usr != src.occupant)	return
		src.occupant_message("Recalibrating coordination system.")
		src.log_message("Recalibration of coordination system started.")
		var/T = src.loc
		if(do_after(100))
			if(T == src.loc)
				src.clearInternalDamage(MECHA_INT_CONTROL_LOST)
				src.occupant_message(span_blue("Recalibration successful."))
				src.log_message("Recalibration of coordination system finished with 0 errors.")
			else
				src.occupant_message(span_red("Recalibration failed."))
				src.log_message("Recalibration of coordination system failed with 1 error.",1)
	if(href_list["drop_from_cargo"])
		var/obj/O = locate(href_list["drop_from_cargo"])
		if(O && (O in src.cargo))
			src.occupant_message(span_notice("You unload [O]."))
			O.forceMove(get_turf(src))
			src.cargo -= O
			var/turf/T = get_turf(O)
			if(T)
				T.Entered(O)
			src.log_message("Unloaded [O]. Cargo compartment capacity: [cargo_capacity - src.cargo.len]")
	return

	//debug
	/*
	if(href_list["debug"])
		if(href_list["set_i_dam"])
			setInternalDamage(top_filter.getNum("set_i_dam"))
		if(href_list["clear_i_dam"])
			clearInternalDamage(top_filter.getNum("clear_i_dam"))
		return
	*/



/*

	if (href_list["ai_take_control"])
		var/mob/living/silicon/ai/AI = locate(href_list["ai_take_control"])
		var/duration = text2num(href_list["duration"])
		var/mob/living/silicon/ai/O = new /mob/living/silicon/ai(src)
		var/cur_occupant = src.occupant
		O.invisibility = 0
		O.canmove = 1
		O.name = AI.name
		O.real_name = AI.real_name
		O.anchored = TRUE
		O.aiRestorePowerRoutine = 0
		O.control_disabled = 1 // Can't control things remotely if you're stuck in a card!
		O.laws = AI.laws
		O.set_stat(AI.stat)
		O.oxyloss = AI.getOxyLoss()
		O.fireloss = AI.getFireLoss()
		O.bruteloss = AI.getBruteLoss()
		O.toxloss = AI.toxloss
		O.updatehealth()
		src.occupant = O
		if(AI.mind)
			AI.mind.transfer_to(O)
		AI.name = "Inactive AI"
		AI.real_name = "Inactive AI"
		AI.icon_state = "ai-empty"
		spawn(duration)
			AI.name = O.name
			AI.real_name = O.real_name
			if(O.mind)
				O.mind.transfer_to(AI)
			AI.control_disabled = 0
			AI.laws = O.laws
			AI.oxyloss = O.getOxyLoss()
			AI.fireloss = O.getFireLoss()
			AI.bruteloss = O.getBruteLoss()
			AI.toxloss = O.toxloss
			AI.updatehealth()
			qdel(O)
			if (!AI.stat)
				AI.icon_state = "ai"
			else
				AI.icon_state = "ai-crash"
			src.occupant = cur_occupant
*/
