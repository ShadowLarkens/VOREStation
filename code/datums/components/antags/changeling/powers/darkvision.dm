/datum/power/changeling/darksight
	name = "Dark Sight"
	desc = "We change the composition of our eyes, banishing the shadows from our vision."
	helptext = "We will be able to see in the dark."
	ability_icon_state = "ling_augmented_eyesight"
	genomecost = 0
	verbpath = /mob/proc/changeling_darksight

/mob/proc/changeling_darksight()
	set category = "Changeling"
	set name = "Toggle Darkvision"
	set desc = "We are able see in the dark."

	var/datum/component/antag/changeling/changeling = changeling_power(0,0,100,UNCONSCIOUS)
	if(!changeling)
		return 0

	if(istype(src,/mob/living/carbon))
		var/mob/living/carbon/C = src
		C.seedarkness = !C.seedarkness
		if(C.seedarkness)
			to_chat(C, span_notice("We allow the shadows to return."))
		else
			to_chat(C, span_notice("We no longer need light to see."))

	return 0
