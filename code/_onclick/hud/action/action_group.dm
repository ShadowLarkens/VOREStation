/datum/action_group
	/// The hud we're owned by
	var/datum/hud/owner
	/// The actions we're managing
	var/list/obj/screen/movable/action_button/actions
	/// The initial vertical offset of our action buttons
	var/north_offset = 0
	/// The pixel vertical offset of our action buttons
	var/pixel_north_offset = 0
	/// Max amount of buttons we can have per row
	/// Indexes at 1
	var/column_max = 0
	/// How far "ahead" of the first row we start. Lets us "scroll" our rows
	/// Indexes at 1
	var/row_offset = 0
	/// How many rows of actions we can have at max before we just stop hiding
	/// Indexes at 1
	var/max_rows = INFINITY
	/// The screen location we go by
	var/location
	/// Our landing screen object
	var/obj/screen/action_landing/landing

/datum/action_group/New(datum/hud/owner)
	..()
	actions = list()
	src.owner = owner

/datum/action_group/Destroy()
	owner = null
	QDEL_NULL(landing)
	QDEL_LIST(actions)
	return ..()



/// Generates and fills new action groups with our mob's current actions
/datum/hud/proc/build_action_groups()
	listed_actions = new(src)
	palette_actions = new(src)
	floating_actions = list()
	for(var/datum/action/action as anything in mymob.actions)
		var/obj/screen/movable/action_button/button = action.button // action.viewers[src]
		// if(!button)
		// 	action.ShowTo(mymob)
		// else
		// 	position_action(button, button.location)

/datum/action_group/palette
	north_offset = 2
	column_max = 3
	max_rows = 3
	location = SCRN_OBJ_IN_PALETTE

// /datum/action_group/palette/insert_action(atom/movable/screen/action, index)
// 	. = ..()
// 	var/atom/movable/screen/button_palette/palette = owner.toggle_palette
// 	palette.play_item_added()

// /datum/action_group/palette/remove_action(atom/movable/screen/action)
// 	. = ..()
// 	var/atom/movable/screen/button_palette/palette = owner.toggle_palette
// 	palette.play_item_removed()
// 	if(!length(actions))
// 		palette.set_expanded(FALSE)

// /datum/action_group/palette/refresh_actions()
// 	var/atom/movable/screen/button_palette/palette = owner.toggle_palette
// 	var/atom/movable/screen/palette_scroll/scroll_down = owner.palette_down
// 	var/atom/movable/screen/palette_scroll/scroll_up = owner.palette_up

// 	var/actions_above = round((owner.listed_actions.size() - 1) / owner.listed_actions.column_max)
// 	north_offset = initial(north_offset) + actions_above

// 	palette.screen_loc = ui_action_palette_offset(actions_above)
// 	var/action_count = length(owner?.mymob?.actions)
// 	var/our_row_count = round((length(actions) - 1) / column_max)
// 	if(!action_count)
// 		palette.screen_loc = null

// 	if(palette.expanded && action_count && our_row_count >= max_rows)
// 		scroll_down.screen_loc = ui_palette_scroll_offset(actions_above)
// 		scroll_up.screen_loc = ui_palette_scroll_offset(actions_above)
// 	else
// 		scroll_down.screen_loc = null
// 		scroll_up.screen_loc = null

// 	return ..()

// /datum/action_group/palette/ButtonNumberToScreenCoords(number, landing)
// 	var/atom/movable/screen/button_palette/palette = owner.toggle_palette
// 	if(palette.expanded)
// 		return ..()

// 	if(!landing)
// 		return null

// 	// We only render the landing in this case, so we force it to be the second item displayed (Second rather then first since it looks nicer)
// 	// Remember the number var indexes at 0
// 	return ..(1 + (row_offset * column_max), landing)

/datum/action_group/listed
	pixel_north_offset = 6
	column_max = 10
	location = SCRN_OBJ_IN_LIST

// /datum/action_group/listed/refresh_actions()
// 	. = ..()
// 	owner.palette_actions.refresh_actions() // We effect them, so we gotta refresh em
