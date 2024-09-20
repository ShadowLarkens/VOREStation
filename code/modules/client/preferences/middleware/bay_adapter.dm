/datum/preference_middleware/bay_adapter
	key = "legacy"

/datum/preference_middleware/bay_adapter/get_ui_data(mob/user)
	var/list/data = ..()

	var/list/legacy = list()
	var/list/categories = preferences.player_setup.categories
	for(var/datum/category_group/player_setup_category/category as anything in categories)
		var/list/items = category.items
		for(var/datum/category_item/player_setup_item/item as anything in items)
			legacy += item.tgui_data(user)
	data["legacy"] = legacy

	return data

/datum/preference_middleware/bay_adapter/get_ui_static_data(mob/user)
	var/list/data = ..()

	var/list/legacy = list()
	var/list/categories = preferences.player_setup.categories
	for(var/datum/category_group/player_setup_category/category as anything in categories)
		var/list/items = category.items
		for(var/datum/category_item/player_setup_item/item as anything in items)
			legacy += item.tgui_static_data(user)
	data["legacy"] = legacy

	return data

/datum/preference_middleware/bay_adapter/get_constant_data()
	var/list/data = list()

	var/datum/category_collection/player_setup_collection/collection = new()

	var/list/legacy = list()
	var/list/categories = collection.categories
	for(var/datum/category_group/player_setup_category/category as anything in categories)
		var/list/items = category.items
		for(var/datum/category_item/player_setup_item/item as anything in items)
			legacy += item.tgui_constant_data()
	data["legacy"] = legacy

	return data
