
/obj/item/material/fishing_rod
	name = "crude fishing rod"
	desc = "A crude rod made for catching fish."
	description_info = "A tool usable on water-tiles to attempt to catch fish by swiping it over them.\
	You can add or remove cable by wirecutter or coil respectively to allow its use.\
	Any food containing things like protein, sugar, or standard nutriment can be attached to the rod, allowing for faster fishing based on the amount.\
	You can examine the rod to check if it has bait attached, and examine it automatically if so.\
	\
	Ctrl clicking the rod will remove any attached bait from the rod."
	description_antag = "Some fishing rods can be utilized as long-range, sharp weapons, though their pseudo ranged ability comes at the cost of slow speed."
	icon_state = "fishing_rod"
	item_state = "fishing_rod"
	force_divisor = 0.02	//VOREStation Edit
	throwforce = 1		//VOREStation Edit
	sharp = TRUE
	attack_verb = list("whipped", "battered", "slapped", "fished", "hooked")
	hitsound = 'sound/weapons/punchmiss.ogg'
	applies_material_colour = TRUE
	default_material = MAT_WOOD
	can_dull = FALSE
	var/strung = TRUE
	var/line_break = TRUE

	var/obj/item/reagent_containers/food/snacks/Bait
	var/bait_type = /obj/item/reagent_containers/food/snacks

	var/cast = FALSE

	attackspeed = 3 SECONDS

/obj/item/material/fishing_rod/built
	strung = FALSE

/obj/item/material/fishing_rod/examine(mob/user)
	. = ..()
	if(Bait)
		. += span_notice("It has [Bait] hanging on its hook: ")
		. += Bait.examine(user)

/obj/item/material/fishing_rod/CtrlClick(mob/user)
	if((src.loc == user || Adjacent(user)) && Bait)
		Bait.forceMove(get_turf(user))
		to_chat(user, span_notice("You remove the bait from \the [src]."))
		Bait = null
	else
		..()

/obj/item/material/fishing_rod/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/material/fishing_rod/attackby(obj/item/I as obj, mob/user as mob)
	if(I.has_tool_quality(TOOL_WIRECUTTER) && strung)
		strung = FALSE
		to_chat(user, span_notice("You cut \the [src]'s string!"))
		update_icon()
		return
	else if(istype(I, /obj/item/stack/cable_coil) && !strung)
		var/obj/item/stack/cable_coil/C = I
		if(C.get_amount() < 5)
			to_chat(user, span_warning("You do not have enough length in \the [C] to string this!"))
			return
		if(do_after(user, rand(10 SECONDS, 20 SECONDS)))
			C.use(5)
			strung = TRUE
			to_chat(user, span_notice("You string \the [src]!"))
			update_icon()
			return
	else if(istype(I, bait_type))
		if(Bait)
			Bait.forceMove(get_turf(user))
			to_chat(user, span_notice("You swap \the [Bait] with \the [I]."))
		Bait = I
		user.drop_from_inventory(Bait)
		Bait.forceMove(src)
		update_bait()
	return ..()

/obj/item/material/fishing_rod/update_icon()
	cut_overlays()
	..()
	if(strung)
		add_overlay("[icon_state]_string")

/obj/item/material/fishing_rod/proc/update_bait()
	if(istype(Bait, bait_type))
		var/foodvolume
		for(var/datum/reagent/re in Bait.reagents.reagent_list)
			if(re.id == REAGENT_ID_NUTRIMENT || re.id == REAGENT_ID_PROTEIN || re.id == REAGENT_ID_GLUCOSE || re.id == REAGENT_ID_FISHBAIT)
				foodvolume += re.volume

		toolspeed = initial(toolspeed) * 10*(0.01/(0.2*(foodvolume/Bait.reagents.maximum_volume + 0.5))) //VOREStation edit: gives fishing a universal formula because Polaris' doesn't work here. Min value of 1, max value of 1/3, 0.5 at 1/2 filled with bait reagents.

	else
		toolspeed = initial(toolspeed)

/obj/item/material/fishing_rod/proc/consume_bait()
	if(Bait)
		qdel(Bait)
		Bait = null
		return TRUE
	return FALSE

/obj/item/material/fishing_rod/attack(var/mob/M as mob, var/mob/user as mob, var/def_zone)
	if(cast)
		to_chat(user, span_notice("You cannot cast \the [src] when it is already in use!"))
		return FALSE
	update_bait()
	return ..()

/obj/item/material/fishing_rod/modern
	name = "fishing rod"
	desc = "A refined rod for catching fish."
	icon_state = "fishing_rod_modern"
	item_state = "fishing_rod"
	reach = 4
	attackspeed = 2 SECONDS
	default_material = MAT_TITANIUM

	toolspeed = 0.75

/obj/item/material/fishing_rod/modern/built
	strung = FALSE

/obj/item/material/fishing_rod/modern/cheap //A rod sold by the fishing vendor. Done so that the rod sold by mining reward vendors doesn't loose its value.
	name = "cheap fishing rod"
	desc = "Mass produced, but somewhat reliable."
	default_material = MAT_PLASTIC

	toolspeed = 0.9
