/datum/asset/json/preferences
	name = "preferences"

/datum/asset/json/preferences/generate()
	var/datum/category_collection/player_setup_collection/P = new()
	. = P.get_constant_data()
	qdel(P)

/datum/preferences/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/json/preferences)
	)

/datum/preferences/tgui_status(mob/user, datum/tgui_state/state)
	if(user != client?.mob)
		return STATUS_CLOSE
	return ..()

/datum/preferences/tgui_state(mob/user)
	return GLOB.tgui_always_state

/datum/preferences/tgui_interact(mob/user, datum/tgui/ui, datum/tgui/parent_ui, custom_state)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PreferencesMenu", "Preferences")
		ui.open()

/datum/preferences/tgui_static_data(mob/user)
	var/list/data = ..()
	data["player_setup"] = player_setup.tgui_static_data(user)
	return data

/datum/preferences/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(.)
		return

	// TODO: Global actions go here
	switch(action)
		if("meow") // TODO: remove test
			to_chat(ui.user, "meow")
			. = TRUE

	if(.)
		update_tgui_static_data(ui.user, ui)
		return

	. = player_setup.tgui_act(action, params, ui, state)
	if(.)
		update_tgui_static_data(ui.user, ui)
