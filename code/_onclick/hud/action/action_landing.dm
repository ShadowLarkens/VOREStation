/// Exists so you have a place to put your buttons when you move them around
/obj/screen/action_landing
	name = "Button Space"
	desc = "<b>Drag and drop</b> a button into this spot<br>to add it to the group"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "reserved"
	// We want our whole 32x32 space to be clickable, so dropping's forgiving
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	var/datum/action_group/owner

/obj/screen/action_landing/Destroy()
	if(owner)
		owner.landing = null
		owner?.owner?.mymob?.client?.screen -= src
		// TODO: this
		// owner.refresh_actions()
		owner = null
	return ..()

/obj/screen/action_landing/proc/set_owner(datum/action_group/owner)
	src.owner = owner
	refresh_owner()

/obj/screen/action_landing/proc/refresh_owner()
	var/datum/hud/our_hud = owner.owner
	var/mob/viewer = our_hud.mymob
	if(viewer.client)
		viewer.client.screen |= src

	// TODO: hud icon support
	// var/list/settings = our_hud.get_action_buttons_icons()
	// icon = settings["bg_icon"]

/// Reacts to having a button dropped on it
/obj/screen/action_landing/proc/hit_by(obj/screen/movable/action_button/button)
	var/datum/hud/our_hud = owner.owner
	our_hud.position_action(button, owner.location)
