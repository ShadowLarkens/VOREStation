/**
 * This is a silly proc used in hud code code to determine what icon and icon state we should be using
 * for hud elements (such as action buttons) that don't have their own icon and icon state set.
 *
 * It returns a list, which is pretty much just a struct of info
 */
// /datum/hud/proc/get_action_buttons_icons()
// 	. = list()
// 	.["bg_icon"] = ui_style
// 	.["bg_state"] = "template"
// 	.["bg_state_active"] = "template_active"

/obj/screen/movable/action_button
	var/datum/action/linked_action
	var/datum/hud/our_hud
	screen_loc = "WEST,NORTH"

/obj/screen/movable/action_button/Click(location,control,params)
	var/list/modifiers = params2list(params)
	if(modifiers["shift"])
		moved = FALSE
		linked_action?.owner?.update_action_buttons()
		return 1
	if(!usr.checkClickCooldown())
		return
	linked_action.Trigger()
	return 1

/obj/screen/movable/action_button/proc/UpdateIcon()
	if(!linked_action)
		return
	icon = linked_action.button_icon
	icon_state = linked_action.background_icon_state

	cut_overlays()
	var/image/img
	if(linked_action.action_type == AB_ITEM && linked_action.target)
		var/obj/item/I = linked_action.target
		img = image(I.icon, src , I.icon_state)
	else if(linked_action.button_icon && linked_action.button_icon_state)
		img = image(linked_action.button_icon,src,linked_action.button_icon_state)
	img.pixel_x = 0
	img.pixel_y = 0
	add_overlay(img)

	if(!linked_action.IsAvailable())
		color = rgb(128,0,0,128)
	else
		color = rgb(255,255,255,255)

//Hide/Show Action Buttons ... Button
/obj/screen/movable/action_button/hide_toggle
	name = "Hide Buttons"
	icon = 'icons/mob/actions/actions.dmi'
	icon_state = "bg_default"
	var/hidden = 0

/obj/screen/movable/action_button/hide_toggle/Click()
	usr.hud_used.action_buttons_hidden = !usr.hud_used.action_buttons_hidden

	hidden = usr.hud_used.action_buttons_hidden
	if(hidden)
		name = "Show Buttons"
	else
		name = "Hide Buttons"
	UpdateIcon()
	usr.update_action_buttons()

/obj/screen/movable/action_button/hide_toggle/proc/InitialiseIcon(var/mob/living/user)
	if(isalien(user))
		icon_state = "bg_alien"
	else
		icon_state = "bg_default"
	UpdateIcon()
	return

/obj/screen/movable/action_button/hide_toggle/UpdateIcon()
	cut_overlays()
	var/image/img = image(icon,src,hidden?"show":"hide")
	add_overlay(img)
	return
