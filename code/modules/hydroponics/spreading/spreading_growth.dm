#define NEIGHBOR_REFRESH_TIME 100

/obj/effect/plant/proc/get_cardinal_neighbors()
	var/list/cardinal_neighbors = list()
	for(var/check_dir in GLOB.cardinal)
		var/turf/simulated/T = get_step(get_turf(src), check_dir)
		//VOREStation Edit Start - Vines can go up/down stairs, but don't register that they have done this, so do so infinitely, which is annoying and laggy.
		if(istype(T) && !isopenturf(check_dir)) //Let's not have them go on open space where you can't really get to them.
			cardinal_neighbors |= T
		//VOREStation Edit End
	return cardinal_neighbors

/obj/effect/plant/proc/update_neighbors()
	// Update our list of valid neighboring turfs.
	neighbors = list()
	for(var/turf/simulated/floor in get_cardinal_neighbors())
		if(get_dist(parent, floor) > spread_distance)
			continue

		var/blocked = 0
		for(var/obj/effect/plant/other in floor.contents)
			if(other.seed == src.seed)
				blocked = 1
				break
		if(blocked)
			continue

		if(floor.density)
			if(!isnull(seed.chems[REAGENT_ID_PACID]))
				spawn(rand(5,25)) floor.ex_act(3)
			continue

		if(!Adjacent(floor) || !floor.Enter(src))
			continue
		neighbors |= floor

	if(neighbors.len)
		SSplants.add_plant(src)	//if we have neighbours again, start processing

	// Update all of our friends.
	var/turf/T = get_turf(src)
	for(var/obj/effect/plant/neighbor in range(1,src))
		if(neighbor.seed == src.seed)
			neighbor.neighbors -= T

/obj/effect/plant/process()

	// Something is very wrong, kill ourselves.
	if(!seed)
		die_off()
		return 0

	for(var/obj/effect/effect/smoke/chem/smoke in view(1, src))
		if(smoke.reagents.has_reagent(REAGENT_ID_PLANTBGONE))
			die_off()
			return

	// Handle life.
	var/turf/simulated/T = get_turf(src)
	if(istype(T))
		health -= seed.handle_environment(T,T.return_air(),null,1)
	if(health < max_health)
		health += rand(3,5)
		refresh_icon()
		if(health > max_health)
			health = max_health
	else if(health == max_health && !plant)
		plant = new(T,seed)
		plant.dir = src.dir
		plant.transform = src.transform
		plant.age = seed.get_trait(TRAIT_MATURATION)-1
		plant.update_icon()
		if(growth_type==0) //Vines do not become invisible.
			invisibility = INVISIBILITY_MAXIMUM
		else
			plant.layer = layer + 0.1

	if(has_buckled_mobs())
		for(var/mob/living/L as anything in buckled_mobs)
			seed.do_sting(L,src)
			if(seed.get_trait(TRAIT_CARNIVOROUS))
				seed.do_thorns(L,src)

	if(world.time >= last_tick+NEIGHBOR_REFRESH_TIME)
		last_tick = world.time
		update_neighbors()

	if(sampled)
		//Should be between 2-7 for given the default range of values for TRAIT_PRODUCTION
		var/chance = max(1, round(15/seed.get_trait(TRAIT_PRODUCTION)))
		if(prob(chance))
			sampled = 0

	if(is_mature())
		if(!has_buckled_mobs())
			for(var/turf/neighbor in neighbors)
				for(var/mob/living/M in neighbor)
					if(seed.get_trait(TRAIT_SPREAD) >= 2 && (M.lying || prob(round(seed.get_trait(TRAIT_POTENCY)))))
						entangle(M)

		if(seed.get_trait(TRAIT_SPORING) && prob(1))
			visible_message(span_warning("\The [src] hisses, releasing a cloud of spores!"), span_warning("Something nearby hisses loudly!"))
			seed.create_spores(get_turf(src))

		if(length(neighbors) && prob(spread_chance))
			//spread to 1-3 adjacent turfs depending on yield trait.
			var/max_spread = between(1, round(seed.get_trait(TRAIT_YIELD)*3/14), 3)

			for(var/i in 1 to max_spread)
				if(prob(spread_chance))
					sleep(rand(3,5))
					if(!length(neighbors))
						break
					spread_to(pick(neighbors))

	// We shouldn't have spawned if the controller doesn't exist.
	check_health()
	if(has_buckled_mobs() || neighbors.len)
		SSplants.add_plant(src)

//spreading vines aren't created on their final turf.
//Instead, they are created at their parent and then move to their destination.
/obj/effect/plant/proc/spread_to(turf/target_turf)
	//VOREStation Edit Start - Vines can go up/down stairs, but don't register that they have done this, so do so infinitely, which is annoying and laggy.
	if(isopenturf(target_turf))
		return
	//VOREStation Edit End
	var/obj/effect/plant/child = new(get_turf(src),seed,parent)

	spawn(1) // This should do a little bit of animation.
		if(QDELETED(child))
			return

		//move out to the destination
		child.anchored = FALSE
		child.Move(target_turf)	// Do a normal move, so we can cross and uncross things we need to. Stairs, Open space "falling", etc.
		child.anchored = TRUE
		child.update_icon()

		//see if anything is there
		for(var/thing in child.loc)
			if(thing != child && istype(thing, /obj/effect/plant))
				var/obj/effect/plant/other = thing
				if(other.seed != child.seed)
					other.vine_overrun(child.seed, src) //vine fight
				qdel(child)
				return
			if(istype(thing, /obj/effect/dead_plant))
				qdel(thing)
				qdel(child)
				return
			if(isliving(thing) && (seed.get_trait(TRAIT_CARNIVOROUS) || (seed.get_trait(TRAIT_SPREAD) >= 2 && prob(round(seed.get_trait(TRAIT_POTENCY))))))
				entangle(thing)
				qdel(child)
				return

		// Update neighboring squares.
		for(var/obj/effect/plant/neighbor in range(1, child.loc)) //can use the actual final child loc now
			if(child.seed == neighbor.seed) //neighbors of different seeds will continue to try to overrun each other
				neighbor.neighbors -= target_turf

		child.finish_spreading()

/obj/effect/plant/proc/die_off()
	// Kill off our plant.
	if(plant) plant.die()
	// This turf is clear now, let our buddies know.
	for(var/turf/simulated/check_turf in get_cardinal_neighbors())
		if(!istype(check_turf))
			continue
		for(var/obj/effect/plant/neighbor in check_turf.contents)
			neighbor.neighbors |= check_turf
			SSplants.add_plant(neighbor)
	spawn(1) if(src) qdel(src)

#undef NEIGHBOR_REFRESH_TIME
