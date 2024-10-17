/obj/screen/button_palette
	desc = "<b>Drag</b> buttons to move them<br><b>Shift-click</b> any button to reset it<br><b>Alt-click any button</b> to begin binding it to a key<br><b>Alt-click this</b> to reset all buttons"
	icon = 'icons/mob/actions/64x16_actions.dmi'
	icon_state = "screen_gen_palette"
	screen_loc = ui_action_palette
	var/datum/hud/our_hud
	var/expanded = FALSE
	/// Id of any currently running timers that set our color matrix
	var/color_timer_id

/obj/screen/button_palette/Destroy()
	if(our_hud)
		our_hud.mymob?.client?.screen -= src
		our_hud.toggle_palette = null
		our_hud = null
	return ..()

/obj/screen/button_palette/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	update_appearance()

/obj/screen/button_palette/proc/set_hud(datum/hud/our_hud)
	src.our_hud = our_hud
	refresh_owner()

// TODO: real update_appearance()
/obj/screen/button_palette/proc/update_appearance()
	update_name()

/obj/screen/button_palette/proc/update_name(updates)
	// . = ..()
	if(expanded)
		name = "Hide Buttons"
	else
		name = "Show Buttons"

/obj/screen/button_palette/proc/refresh_owner()
	var/mob/viewer = our_hud.mymob
	if(viewer.client)
		viewer.client.screen |= src

	// var/list/settings = our_hud.get_action_buttons_icons()
	// var/ui_icon = "[settings["bg_icon"]]"
	// var/list/ui_segments = splittext(ui_icon, ".")
	// var/list/ui_paths = splittext(ui_segments[1], "/")
	// var/ui_name = ui_paths[length(ui_paths)]

	// icon_state = "[ui_name]_palette"

/obj/screen/button_palette/MouseEntered(location, control, params)
	. = ..()
	if(QDELETED(src))
		return
	show_tooltip(params)

/obj/screen/button_palette/MouseExited()
	closeToolTip(usr)
	return ..()

/obj/screen/button_palette/proc/show_tooltip(params)
	openToolTip(usr, src, params, title = name, content = desc)

GLOBAL_LIST_INIT(palette_added_matrix, list(0.4,0.5,0.2,0, 0,1.4,0,0, 0,0.4,0.6,0, 0,0,0,1, 0,0,0,0))
GLOBAL_LIST_INIT(palette_removed_matrix, list(1.4,0,0,0, 0.7,0.4,0,0, 0.4,0,0.6,0, 0,0,0,1, 0,0,0,0))

/obj/screen/button_palette/proc/play_item_added()
	color_for_now(GLOB.palette_added_matrix)

/obj/screen/button_palette/proc/play_item_removed()
	color_for_now(GLOB.palette_removed_matrix)

/obj/screen/button_palette/proc/color_for_now(list/color)
	if(color_timer_id)
		return
	add_atom_colour(color, TEMPORARY_COLOUR_PRIORITY) //We unfortunately cannot animate matrix colors. Curse you lummy it would be ~~non~~trivial to interpolate between the two valuessssssssss
	color_timer_id = addtimer(CALLBACK(src, PROC_REF(remove_color), color), 2 SECONDS)

/obj/screen/button_palette/proc/remove_color(list/to_remove)
	color_timer_id = null
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, to_remove)

// /obj/screen/button_palette/proc/can_use(mob/user)
// 	if (isobserver(user))
// 		var/mob/dead/observer/O = user
// 		return !O.observetarget
// 	return TRUE

/obj/screen/button_palette/Click(location, control, params)
	// if(!can_use(usr))
	// 	return

	var/list/modifiers = params2list(params)

	if(LAZYACCESS(modifiers, ALT_CLICK))
		// for(var/datum/action/action as anything in usr.actions) // Reset action positions to default
		// 	for(var/datum/hud/hud as anything in action.viewers)
		// 		var/obj/screen/movable/action_button/button = action.viewers[hud]
		// 		hud.position_action(button, SCRN_OBJ_DEFAULT)
		to_chat(usr, span_notice("Action button positions have been reset."))
		return TRUE

	set_expanded(!expanded)

/obj/screen/button_palette/proc/clicked_while_open(datum/source, atom/target, atom/location, control, params, mob/user)
	if(istype(target, /obj/screen/movable/action_button) || istype(target, /obj/screen/palette_scroll) || target == src) // If you're clicking on an action button, or us, you can live
		return
	set_expanded(FALSE)
	if(source)
		UnregisterSignal(source, COMSIG_CLIENT_CLICK)

/obj/screen/button_palette/proc/set_expanded(new_expanded)
	// var/datum/action_group/our_group = our_hud.palette_actions
	// if(!length(our_group.actions)) //Looks dumb, trust me lad
	// 	new_expanded = FALSE
	if(expanded == new_expanded)
		return

	expanded = new_expanded
	// our_group.refresh_actions()
	update_appearance()

	if(!usr.client)
		return

	if(expanded)
		RegisterSignal(usr.client, COMSIG_CLIENT_CLICK, PROC_REF(clicked_while_open))
	else
		UnregisterSignal(usr.client, COMSIG_CLIENT_CLICK)

	closeToolTip(usr) //Our tooltips are now invalid, can't seem to update them in one frame, so here, just close them


/**************************/
/* Palette Scroll Buttons */
/**************************/
/obj/screen/palette_scroll
	icon = 'icons/mob/screen_gen.dmi'
	screen_loc = ui_palette_scroll
	/// How should we move the palette's actions?
	/// Positive scrolls down the list, negative scrolls back
	var/scroll_direction = 0
	var/datum/hud/our_hud

// /obj/screen/palette_scroll/proc/can_use(mob/user)
// 	if (isobserver(user))
// 		var/mob/dead/observer/O = user
// 		return !O.observetarget
// 	return TRUE

/obj/screen/palette_scroll/proc/set_hud(datum/hud/our_hud)
	src.our_hud = our_hud
	refresh_owner()

/obj/screen/palette_scroll/proc/refresh_owner()
	var/mob/viewer = our_hud.mymob
	if(viewer.client)
		viewer.client.screen |= src

	// var/list/settings = our_hud.get_action_buttons_icons()
	// icon = settings["bg_icon"]

/obj/screen/palette_scroll/Click(location, control, params)
	// if(!can_use(usr))
	// 	return
	// our_hud.palette_actions.scroll(scroll_direction)

/obj/screen/palette_scroll/MouseEntered(location, control, params)
	. = ..()
	if(QDELETED(src))
		return
	openToolTip(usr, src, params, title = name, content = desc)

/obj/screen/palette_scroll/MouseExited()
	closeToolTip(usr)
	return ..()

/obj/screen/palette_scroll/down
	name = "Scroll Down"
	desc = "<b>Click</b> on this to scroll the actions above down"
	icon_state = "scroll_down"
	scroll_direction = 1

/obj/screen/palette_scroll/down/Destroy()
	if(our_hud)
		our_hud.mymob?.client?.screen -= src
		our_hud.palette_down = null
		our_hud = null
	return ..()

/obj/screen/palette_scroll/up
	name = "Scroll Up"
	desc = "<b>Click</b> on this to scroll the actions above up"
	icon_state = "scroll_up"
	scroll_direction = -1

/obj/screen/palette_scroll/up/Destroy()
	if(our_hud)
		our_hud.mymob?.client?.screen -= src
		our_hud.palette_up = null
		our_hud = null
	return ..()
