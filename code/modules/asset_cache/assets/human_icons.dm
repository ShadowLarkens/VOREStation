/datum/asset/json/human_icons
	name = "human_icons"

/datum/asset/json/human_icons/generate()
	var/list/data = list()

	var/list/hair_data = list() // "80s" => list("icon" = "icons/mob/Human_face_m.dmi", "icon_add" = "icons/mob/Human_face_m.dmi", "icon_state" = "hair_80s_s")
	for(var/hair_style in hair_styles_list)
		var/datum/sprite_accessory/hair/S = hair_styles_list[hair_style]
		hair_data[hair_style] = list(
			"icon" = "[S.icon]",
			"icon_add" = "[S.icon_add]",
			"icon_state" = "[S.icon_state]_s",
		)

	data["hair"] = hair_data

	return data
