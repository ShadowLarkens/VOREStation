/client/verb/show_appearance_test()
	set name = "Show Appearance Test"
	set category = "Debug"

	var/datum/tgui_module/appearance_test/A = new(src)
	A.tgui_interact(mob)

/datum/tgui_module/appearance_test
	name = "Appearance Test"
	tgui_id = "AppearanceTest"

/datum/tgui_module/appearance_test/tgui_state(mob/user)
	return GLOB.tgui_always_state

/datum/tgui_module/appearance_test/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/json/human_icons)
	)
