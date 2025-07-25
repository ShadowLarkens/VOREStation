//Updated
// Hivemind

/datum/power/changeling/hive_upload
	name = "Hive Channel"
	desc = "We can channel a DNA into the airwaves, allowing our fellow changelings to absorb it and transform into it as if they acquired the DNA themselves."
	helptext = "Allows other changelings to absorb the DNA you channel from the airwaves. Will not help them towards their absorb objectives."
	genomecost = 0
	make_hud_button = FALSE
	verbpath = /mob/proc/changeling_hiveupload

/datum/power/changeling/hive_download
	name = "Hive Absorb"
	desc = "We can absorb a single DNA from the airwaves, allowing us to use more disguises with help from our fellow changelings."
	helptext = "Allows you to absorb a single DNA and use it. Does not count towards your absorb objective."
	genomecost = 0
	make_hud_button = FALSE
	verbpath = /mob/proc/changeling_hivedownload

// HIVE MIND UPLOAD/DOWNLOAD DNA

var/list/datum/dna/hivemind_bank = list()

/mob/proc/changeling_hiveupload()
	set category = "Changeling"
	set name = "Hive Channel (10)"
	set desc = "Allows you to channel DNA in the airwaves to allow other changelings to absorb it."

	var/datum/component/antag/changeling/changeling = changeling_power(10,1)
	if(!changeling)
		return

	var/list/names = list()
	for(var/datum/absorbed_dna/DNA in changeling.absorbed_dna)
		if(!(DNA in hivemind_bank))
			names += DNA.name

	if(names.len <= 0)
		to_chat(src, span_notice("The airwaves already have all of our DNA."))
		return

	var/S = tgui_input_list(src, "Select a DNA to channel:", "Channel DNA", names)
	if(!S)
		return

	var/datum/absorbed_dna/chosen_dna = changeling.GetDNA(S)
	if(!chosen_dna)
		return

	changeling.chem_charges -= 10
	hivemind_bank += chosen_dna
	to_chat(src, span_notice("We channel the DNA of [S] to the air."))
	feedback_add_details("changeling_powers","HU")
	return TRUE

/mob/proc/changeling_hivedownload()
	set category = "Changeling"
	set name = "Hive Absorb (20)"
	set desc = "Allows you to absorb DNA that is being channeled in the airwaves."

	var/datum/component/antag/changeling/changeling = changeling_power(20,1)
	if(!changeling)
		return

	var/list/names = list()
	for(var/datum/absorbed_dna/DNA in hivemind_bank)
		if(!(DNA in changeling.absorbed_dna))
			names[DNA.name] = DNA

	if(names.len <= 0)
		to_chat(src, span_notice("There's no new DNA to absorb from the air."))
		return

	var/S = tgui_input_list(src, "Select a DNA to absorb:", "Absorb DNA", names)
	if(!S)
		return
	var/datum/absorbed_dna/chosen_dna = names[S]
	if(!chosen_dna)
		return

	changeling.chem_charges -= 20
	absorbDNA(chosen_dna)
	to_chat(src, span_notice("We absorb the DNA of [S] from the air."))
	feedback_add_details("changeling_powers","HD")
	return TRUE
