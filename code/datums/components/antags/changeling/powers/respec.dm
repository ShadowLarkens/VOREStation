/mob/proc/changeling_respec()
	set category = "Changeling"
	set name = "Re-adapt"
	set desc = "Allows us to refund our purchased abilities."

	var/datum/component/antag/changeling/changeling = changeling_power(0,0,100)
	if(!changeling)
		return
	if(changeling.readapts <= 0)
		to_chat(src, span_warning("We must first absorb another compatible creature!"))
		changeling.readapts = 0
		return

	src.remove_changeling_powers() //First, remove the verbs.
	var/datum/component/antag/changeling/ling_datum = changeling
	ling_datum.readapts--
	ling_datum.purchased_powers = list() //Then wipe all the powers we bought.
	ling_datum.geneticpoints = ling_datum.max_geneticpoints //Now refund our points to the maximum.
	ling_datum.chem_recharge_rate = 0.5 //If glands were bought, revert that upgrade.
	ling_datum.thermal_sight = FALSE
	changeling.recursive_enhancement = 0 //Ensures this is cleared

	ling_datum.chem_storage = 50
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
	//	H.does_not_breathe = 0 //If self respiration was bought, revert that too.
		H.remove_modifiers_of_type(/datum/modifier/endoarmor) //Revert endoarmor too.
	src.make_changeling() //And give back our freebies.

	to_chat(src, span_notice("We have removed our evolutions from this form, and are now ready to readapt."))

	ling_datum.purchased_powers_history.Add("Re-adapt (Reset to [ling_datum.max_geneticpoints])")
