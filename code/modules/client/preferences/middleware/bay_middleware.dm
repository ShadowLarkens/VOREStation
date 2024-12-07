/datum/preference_middleware/bay

/datum/preference_middleware/bay/get_character_preferences(mob/user)
	return preferences.player_setup.tgui_data(user)

/datum/category_collection/player_setup_collection/tgui_data(mob/user)
	var/list/data = ..()

	for(var/datum/category_group/player_setup_category/PS in categories)
		data += PS.tgui_data(user)

	return list("misc" = data)

/datum/category_group/player_setup_category/tgui_data(mob/user)
	var/list/data = ..()

	for(var/datum/category_item/player_setup_item/PI in items)
		data += PI.tgui_data(user)

	return data
