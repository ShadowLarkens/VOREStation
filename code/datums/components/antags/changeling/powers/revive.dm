/datum/power/changeling/changeling_revive
	name = "Revive"
	desc = "We revive from our death-like state."
	helptext = "Regeneration must first be started via Regenerative Stasis."
	ability_icon_state = "ling_revive"
	genomecost = 0
	allowduringlesserform = TRUE
	verbpath = /mob/proc/changeling_revive

//Revive from revival stasis
/mob/proc/changeling_revive()
	set category = "Changeling"
	set name = "Revive"
	set desc = "We are ready to revive ourselves on command."

	var/datum/component/antag/changeling/changeling = changeling_power(0,0,100,DEAD)
	if(!changeling)
		return FALSE

	if(stat != DEAD)
		to_chat(src, span_danger("We are not dead."))
		return FALSE
	if(!changeling.is_reviving)
		to_chat(src, span_danger("We have not begun the regeneration process yet.."))
		return FALSE
	if(changeling.is_on_cooldown(FAKE_DEATH))
		to_chat(src, span_danger("We are still recovering. We will be able to revive again in [(changeling.get_cooldown(FAKE_DEATH) - world.time)/10] seconds."))
		return FALSE

	if(changeling.max_geneticpoints < 0) //Absorbed by another ling
		to_chat(src, span_danger("You have no genomes, not even your own, and cannot revive."))
		return FALSE

	if(src.stat == DEAD)
		GLOB.dead_mob_list -= src
		GLOB.living_mob_list += src
	var/mob/living/carbon/C = src

	C.tod = null
	C.setToxLoss(0)
	C.setOxyLoss(0)
	C.setCloneLoss(0)
	C.SetParalysis(0)
	C.SetStunned(0)
	C.SetWeakened(0)
	C.radiation = 0
	C.heal_overall_damage(C.getBruteLoss(), C.getFireLoss())
	C.reagents.clear_reagents()
	if(ishuman(C))
		var/mob/living/carbon/human/H = src
		H.species.create_organs(H)
		H.restore_all_organs(ignore_prosthetic_prefs=1) //Covers things like fractures and other things not covered by the above.
		H.restore_blood()
		H.mutations.Remove(HUSK)
		H.status_flags &= ~DISFIGURED
		H.update_icons_body()
		for(var/limb in H.organs_by_name)
			var/obj/item/organ/external/current_limb = H.organs_by_name[limb]
			if(current_limb)
				current_limb.relocate()
				current_limb.open = 0

		BITSET(H.hud_updateflag, HEALTH_HUD)
		BITSET(H.hud_updateflag, STATUS_HUD)
		BITSET(H.hud_updateflag, LIFE_HUD)

		if(H.handcuffed)
			var/obj/item/W = H.handcuffed
			H.handcuffed = null
			if(H.buckled && H.buckled.buckle_require_restraints)
				H.buckled.unbuckle_mob()
			H.update_handcuffed()
			if (H.client)
				H.client.screen -= W
			W.forceMove(H.loc)
			W.dropped(H)
			if(W)
				W.layer = initial(W.layer)
		if(H.legcuffed)
			var/obj/item/W = H.legcuffed
			H.legcuffed = null
			H.update_inv_legcuffed()
			if(H.client)
				H.client.screen -= W
			W.forceMove(H.loc)
			W.dropped(H)
			if(W)
				W.layer = initial(W.layer)
		if(istype(H.wear_suit, /obj/item/clothing/suit/straight_jacket))
			var/obj/item/clothing/suit/straight_jacket/SJ = H.wear_suit
			SJ.forceMove(H.loc)
			SJ.dropped(H)
			H.wear_suit = null
		H.UpdateAppearance()

	C.halloss = 0
	C.shock_stage = 0 //Pain
	to_chat(C, span_notice("We have regenerated."))
	C.update_canmove()
	feedback_add_details("changeling_powers","CR")
	C.set_stat(CONSCIOUS)
	C.forbid_seeing_deadchat = FALSE
	C.timeofdeath = null
	changeling.is_reviving = FALSE

	return TRUE
