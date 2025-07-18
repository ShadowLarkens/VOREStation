//These procs handle putting s tuff in your hand. It's probably best to use these rather than setting stuff manually
//as they handle all relevant stuff like adding it to the player's screen and such

//Returns the thing in our active hand (whatever is in our active module-slot, in this case)
/mob/living/silicon/robot/get_active_hand(atom/A)
	if(module_active == A) //If we are interacting with the item itself (I.E swapping multibelt items)
		return module_active
	else if(istype(module_active, /obj/item/robotic_multibelt)) //If we are hitting something with a multibelt
		var/obj/item/robotic_multibelt/belt = module_active
		if(belt.selected_item)
			return belt.selected_item
	return module_active

/*-------TODOOOOOOOOOO--------*/

//Verbs used by hotkeys.
/mob/living/silicon/robot/verb/cmd_unequip_module()
	set name = "unequip-module"
	set hidden = 1
	uneq_active()

/mob/living/silicon/robot/verb/cmd_toggle_module(module as num)
	set name = "toggle-module"
	set hidden = 1
	toggle_module(module)

/mob/living/silicon/robot/proc/uneq_specific(obj/item/I)
	if(!istype(I))
		return

	if(module_state_1 == I)
		if(istype(module_state_1,/obj/item/robotic_multibelt))
			var/obj/item/robotic_multibelt/toolbelt = module_state_1
			toolbelt.original_state()
		if(istype(module_state_1,/obj/item/borg/sight))
			sight_mode &= ~module_state_1:sight_mode
		if (client)
			client.screen -= module_state_1
		contents -= module_state_1
		module_active = null
		module_state_1:loc = module //So it can be used again later
		module_state_1 = null
		inv1.icon_state = "inv1"
	else if(module_state_2 == I)
		if(istype(module_state_2,/obj/item/robotic_multibelt))
			var/obj/item/robotic_multibelt/toolbelt = module_state_2
			toolbelt.original_state()
		if(istype(module_state_2,/obj/item/borg/sight))
			sight_mode &= ~module_state_2:sight_mode
		if (client)
			client.screen -= module_state_2
		contents -= module_state_2
		module_active = null
		module_state_2:loc = module //So it can be used again later
		module_state_2 = null
		inv2.icon_state = "inv2"
	else if(module_state_3 == I)
		if(istype(module_state_3,/obj/item/robotic_multibelt))
			var/obj/item/robotic_multibelt/toolbelt = module_state_3
			toolbelt.original_state()
		if(istype(module_state_3,/obj/item/borg/sight))
			sight_mode &= ~module_state_3:sight_mode
		if (client)
			client.screen -= module_state_3
		contents -= module_state_3
		module_active = null
		module_state_3:loc = module //So it can be used again later
		module_state_3 = null
		inv3.icon_state = "inv3"
	else
		return

	for(var/datum/action/A as anything in I.actions)
		A.Remove(src)

	after_equip()
	update_icon()
	hud_used.update_robot_modules_display()

/mob/living/silicon/robot/proc/uneq_active()
	if(isnull(module_active))
		return

	var/obj/item/I = module_active
	for(var/datum/action/A as anything in I.actions)
		A.Remove(src)

	uneq_specific(I)

/mob/living/silicon/robot/proc/uneq_all()
	module_active = null

	if(module_state_1)
		if(istype(module_state_1,/obj/item/borg/sight))
			sight_mode &= ~module_state_1:sight_mode
		if (client)
			client.screen -= module_state_1
		contents -= module_state_1
		var/obj/item/I = module_state_1
		for(var/datum/action/A as anything in I.actions)
			A.Remove(src)
		module_state_1:loc = module
		module_state_1 = null
		inv1.icon_state = "inv1"
	if(module_state_2)
		if(istype(module_state_2,/obj/item/borg/sight))
			sight_mode &= ~module_state_2:sight_mode
		if (client)
			client.screen -= module_state_2
		var/obj/item/I = module_state_2
		for(var/datum/action/A as anything in I.actions)
			A.Remove(src)
		contents -= module_state_2
		module_state_2:loc = module
		module_state_2 = null
		inv2.icon_state = "inv2"
	if(module_state_3)
		if(istype(module_state_3,/obj/item/borg/sight))
			sight_mode &= ~module_state_3:sight_mode
		if (client)
			client.screen -= module_state_3
		var/obj/item/I = module_state_3
		for(var/datum/action/A as anything in I.actions)
			A.Remove(src)
		contents -= module_state_3
		module_state_3:loc = module
		module_state_3 = null
		inv3.icon_state = "inv3"
	after_equip()
	update_icon()

// Just used for pretty display in TGUI
/mob/living/silicon/robot/proc/get_slot_from_module(obj/item/I)
	if(module_state_1 == I)
		return 1
	else if(module_state_2 == I)
		return 2
	else if(module_state_3 == I)
		return 3
	else
		return 0

/mob/living/silicon/robot/proc/activated(obj/item/O)
	var/belt_check = using_multibelt(O)
	if(belt_check)
		return belt_check
	if(module_state_1 == O)
		return 1
	else if(module_state_2 == O)
		return 1
	else if(module_state_3 == O)
		return 1
	else
		return 0

/mob/living/silicon/robot/proc/using_multibelt(obj/item/O)
	for(var/obj/item/robotic_multibelt/materials/material_belt in contents)
		if(material_belt.selected_item == O)
			return TRUE
	for(var/obj/item/gripper/gripper in contents)
		if(gripper.current_pocket == O)
			return TRUE
	return FALSE

/mob/living/silicon/robot/proc/get_active_modules()
	return list(module_state_1, module_state_2, module_state_3)

// This one takes an object's type instead of an instance, as above.
/mob/living/silicon/robot/proc/has_active_type(var/type_to_compare, var/explicit = FALSE)
	var/list/active_modules = get_active_modules()
	if(is_type_in_modules(type_to_compare, active_modules, explicit))
		return TRUE
	return FALSE

/// Searches through a provided list to see if we have a module that is in that list.
/mob/living/silicon/robot/proc/has_active_type_list(var/list/type_to_compare, var/explicit = FALSE)
	var/list/active_modules = get_active_modules()
	if(islist(type_to_compare))
		for(var/object_to_compare in type_to_compare)
			if(is_type_in_modules(object_to_compare, active_modules, explicit))
				return TRUE
	return FALSE

// Checks if the activated module is of the given type
/mob/living/silicon/robot/proc/activated_module_type_list(var/list/type_to_compare, var/explicit = FALSE)
	if(!islist(type_to_compare))
		return FALSE
	for(var/type in type_to_compare)
		if(istype(module_active, type))
			return TRUE
	return FALSE

/mob/living/silicon/robot/proc/is_type_in_modules(var/type, var/list/modules, var/explicit = FALSE)
	for(var/atom/module in modules)
		if(explicit && isatom(module))
			if(module.type == type)
				return TRUE
		else if(istype(module, type))
			return TRUE
	return FALSE

//Helper procs for cyborg modules on the UI.
//These are hackish but they help clean up code elsewhere.

//module_selected(module) - Checks whether the module slot specified by "module" is currently selected.
/mob/living/silicon/robot/proc/module_selected(var/module) //Module is 1-3
	return module == get_selected_module()

//module_active(module) - Checks whether there is a module active in the slot specified by "module".
/mob/living/silicon/robot/proc/module_active(var/module) //Module is 1-3
	if(module < 1 || module > 3) return 0

	switch(module)
		if(1)
			if(module_state_1)
				return 1
		if(2)
			if(module_state_2)
				return 1
		if(3)
			if(module_state_3)
				return 1
	return 0

//get_selected_module() - Returns the slot number of the currently selected module.  Returns 0 if no modules are selected.
/mob/living/silicon/robot/proc/get_selected_module()
	if(module_state_1 && module_active == module_state_1)
		return 1
	else if(module_state_2 && module_active == module_state_2)
		return 2
	else if(module_state_3 && module_active == module_state_3)
		return 3

	return 0

//select_module(module) - Selects the module slot specified by "module"
/mob/living/silicon/robot/proc/select_module(var/module) //Module is 1-3
	if(module < 1 || module > 3) return

	if(!module_active(module)) return

	switch(module)
		if(1)
			if(module_active != module_state_1)
				inv1.icon_state = "inv1 +a"
				inv2.icon_state = "inv2"
				inv3.icon_state = "inv3"
				module_active = module_state_1
				update_icon()
				return
		if(2)
			if(module_active != module_state_2)
				inv1.icon_state = "inv1"
				inv2.icon_state = "inv2 +a"
				inv3.icon_state = "inv3"
				module_active = module_state_2
				update_icon()
				return
		if(3)
			if(module_active != module_state_3)
				inv1.icon_state = "inv1"
				inv2.icon_state = "inv2"
				inv3.icon_state = "inv3 +a"
				module_active = module_state_3
				update_icon()
				return
	return

//deselect_module(module) - Deselects the module slot specified by "module"
/mob/living/silicon/robot/proc/deselect_module(var/module) //Module is 1-3
	if(module < 1 || module > 3) return

	switch(module)
		if(1)
			if(module_active == module_state_1)
				inv1.icon_state = "inv1"
				module_active = null
				update_icon()
				return
		if(2)
			if(module_active == module_state_2)
				inv2.icon_state = "inv2"
				module_active = null
				update_icon()
				return
		if(3)
			if(module_active == module_state_3)
				inv3.icon_state = "inv3"
				module_active = null
				update_icon()
				return
	return

//toggle_module(module) - Toggles the selection of the module slot specified by "module".
/mob/living/silicon/robot/proc/toggle_module(var/module) //Module is 1-3
	if(module < 1 || module > 3) return

	if(module_selected(module))
		deselect_module(module)
	else
		if(module_active(module))
			select_module(module)
		else
			deselect_module(get_selected_module()) //If we can't do select anything, at least deselect the current module.
	return

//cycle_modules() - Cycles through the list of selected modules.
/mob/living/silicon/robot/proc/cycle_modules()
	var/slot_start = get_selected_module()
	if(slot_start) deselect_module(slot_start) //Only deselect if we have a selected slot.

	var/slot_num
	if(slot_start == 0)
		slot_num = 1
	else
		slot_num = slot_start + 1
		if(slot_num > 3)
			return
	// Attempt to rotate through the slots until we're past slot 3, or find the next usable slot. Allows skipping empty slots, while still having an empty slot at end of rotation.
	while(slot_num <= 3)
		if(module_active(slot_num))
			select_module(slot_num)
			return
		slot_num++

	return

/mob/living/silicon/robot/proc/activate_module(var/obj/item/O)
	if(!(locate(O) in src.module.modules) && !(locate(O) in src.module.emag))
		return
	if(activated(O))
		to_chat(src, span_notice("Already activated"))
		return
	if(!module_state_1)
		module_state_1 = O
		O.hud_layerise()
		O.screen_loc = inv1.screen_loc
		contents += O
		if(istype(module_state_1,/obj/item/borg/sight))
			sight_mode |= module_state_1:sight_mode
		update_icon()
	else if(!module_state_2)
		module_state_2 = O
		O.hud_layerise()
		O.screen_loc = inv2.screen_loc
		contents += O
		if(istype(module_state_2,/obj/item/borg/sight))
			sight_mode |= module_state_2:sight_mode
		update_icon()
	else if(!module_state_3)
		module_state_3 = O
		O.hud_layerise()
		O.screen_loc = inv3.screen_loc
		contents += O
		if(istype(module_state_3,/obj/item/borg/sight))
			sight_mode |= module_state_3:sight_mode
		update_icon()
	else
		to_chat(src, span_notice("You need to disable a module first!"))
		return
	after_equip(O)

/mob/living/silicon/robot/proc/after_equip(var/obj/item/O)
	if(istype(O, /obj/item/gps))
		var/obj/item/gps/tracker = O
		if(tracker.tracking)
			tracker.tracking = FALSE
			tracker.toggle_tracking()
	if(sight_mode & BORGANOMALOUS)
		var/obj/item/dogborg/pounce/pounce = has_upgrade_module(/obj/item/dogborg/pounce)
		if(pounce)
			pounce.name = "bluespace pounce"
			pounce.icon_state = "bluespace_pounce"
			pounce.bluespace = TRUE
	else
		var/obj/item/dogborg/pounce/pounce = has_upgrade_module(/obj/item/dogborg/pounce)
		if(pounce)
			pounce.name = initial(pounce.name)
			pounce.icon_state = initial(pounce.icon_state)
			pounce.desc = initial(pounce.desc)
			pounce.bluespace = initial(pounce.bluespace)
	if(O)
		for(var/datum/action/A as anything in O.actions)
			A.Grant(src)

/mob/living/silicon/robot/put_in_hands(var/obj/item/W) // No hands.
	W.forceMove(get_turf(src))
	return 1

/mob/living/silicon/robot/is_holding_item_of_type(typepath)
	for(var/obj/item/I in list(module_state_1, module_state_2, module_state_3))
		if(istype(I, typepath))
			return I
	return FALSE

// Returns a list of all held items in a borg's 'hands'.
/mob/living/silicon/robot/get_all_held_items()
	. = list()
	if(module_state_1)
		. += module_state_1
	if(module_state_2)
		. += module_state_2
	if(module_state_3)
		. += module_state_3
