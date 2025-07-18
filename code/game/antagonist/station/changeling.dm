/datum/antagonist/changeling
	id = MODE_CHANGELING
	role_type = BE_CHANGELING
	role_text = "Changeling"
	role_text_plural = "Changelings"
	bantype = "changeling"
	feedback_tag = "changeling_objective"
	avoid_silicons = TRUE
	protected_jobs = list(JOB_SECURITY_OFFICER, JOB_WARDEN, JOB_DETECTIVE, JOB_HEAD_OF_SECURITY, JOB_SITE_MANAGER)
	welcome_text = "Use say \"#g message\" to communicate with your fellow changelings. Remember: you get all of their absorbed DNA if you absorb them."
	antag_sound = 'sound/effects/antag_notice/ling_alert.ogg'
	flags = ANTAG_SUSPICIOUS | ANTAG_RANDSPAWN | ANTAG_VOTABLE
	antaghud_indicator = "hudchangeling"

/datum/antagonist/changeling/get_special_objective_text(var/datum/mind/player)
	if(player.current)
		var/datum/component/antag/changeling/comp = player.current.GetComponent(/datum/component/antag/changeling)
		if(comp)
			return "<br><b>Changeling ID:</b> [comp.changelingID].<br><b>Genomes Absorbed:</b> [comp.absorbedcount]"

/datum/antagonist/changeling/update_antag_mob(var/datum/mind/player)
	..()
	player.current.make_changeling()

/datum/antagonist/changeling/remove_antagonist(datum/mind/player, show_message, implanted)
	. = ..()
	var/datum/component/antag/changeling/comp = player.current.GetComponent(/datum/component/antag/changeling)
	if(comp)
		comp.owner.remove_changeling_powers()
		remove_verb(comp.owner, /mob/proc/EvolutionMenu)
		comp.RemoveComponent()
		if(comp.owner.mind)
			comp.owner.mind.antag_holder.changeling = null

/datum/antagonist/changeling/create_objectives(var/datum/mind/changeling)
	if(!..())
		return

	//OBJECTIVES - Always absorb 5 genomes, plus random traitor objectives.
	//If they have two objectives as well as absorb, they must survive rather than escape
	//No escape alone because changelings aren't suited for it and it'd probably just lead to rampant robusting
	//If it seems like they'd be able to do it in play, add a 10% chance to have to escape alone

	var/datum/objective/absorb/absorb_objective = new
	absorb_objective.owner = changeling
	absorb_objective.gen_amount_goal(2, 3)
	changeling.objectives += absorb_objective

	var/datum/objective/assassinate/kill_objective = new
	kill_objective.owner = changeling
	kill_objective.find_target()
	changeling.objectives += kill_objective

	var/datum/objective/steal/steal_objective = new
	steal_objective.owner = changeling
	steal_objective.find_target()
	changeling.objectives += steal_objective

	switch(rand(1,100))
		if(1 to 80)
			if (!(locate(/datum/objective/escape) in changeling.objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = changeling
				changeling.objectives += escape_objective
		else
			if (!(locate(/datum/objective/survive) in changeling.objectives))
				var/datum/objective/survive/survive_objective = new
				survive_objective.owner = changeling
				changeling.objectives += survive_objective
	return

/datum/antagonist/changeling/can_become_antag(var/datum/mind/player, var/ignore_role)
	if(!..())
		return 0
	if(player.current)
		if(ishuman(player.current))
			var/mob/living/carbon/human/H = player.current
			if(H.isSynthetic())
				return 0
			if(H.species.flags & (NO_SLEEVE|NO_DNA))
				return 0
			return 1
		else if(isnewplayer(player.current))
			if(player.current.client && player.current.client.prefs)
				var/datum/species/S = GLOB.all_species[player.current.client.prefs.species]
				if(S && (S.flags & (NO_SLEEVE|NO_DNA)))
					return 0
				if(player.current.client.prefs.organ_data[BP_TORSO] == "cyborg") // Full synthetic. // TODO, this to issynthetic()?
					return 0
				return 1
	return 0

/datum/antagonist/changeling/print_player_full(var/datum/mind/player)
	var/text = print_player_lite(player)

	var/datum/component/antag/changeling/comp = player.current.GetComponent(/datum/component/antag/changeling)
	if(comp)
		text += " (had [comp.max_geneticpoints] genomes)"
		text += "<br>Bought [english_list(comp.purchased_powers_history)]."

	return text
