/proc/accuracy_check(zone, mob/living/user, mob/living/target, associated_skill, datum/intent/used_intent, obj/item/I)
	if(!zone)
		return
	if(user == target)
		return zone
	if(zone == BODY_ZONE_CHEST)
		return zone
	if(HAS_TRAIT(user, TRAIT_CIVILIZEDBARBARIAN) && (zone == BODY_ZONE_L_LEG || zone == BODY_ZONE_R_LEG))
		return zone
	if(target.grabbedby == user)
		if(user.grab_state >= GRAB_AGGRESSIVE)
			return zone
	if(!(target.mobility_flags & MOBILITY_STAND))
		return zone
	if( (target.dir == turn(get_dir(target,user), 180)))
		return zone

	var/chance2hit = 0

	if(check_zone(zone) == zone)
		chance2hit += 10

	if(user.mind)
		chance2hit += (user.mind.get_skill_level_capped(associated_skill) * 8)

	if(used_intent)
		if(used_intent.blade_class == BCLASS_STAB)
			chance2hit += 10
		if(used_intent.blade_class == BCLASS_CUT)
			chance2hit += 6

	if(I)
		if(I.wlength == WLENGTH_SHORT)
			chance2hit += 10

	if(user.STAPER > 10)
		chance2hit += ((user.STAPER-10)*6)

	if(user.STAPER < 10)
		chance2hit -= ((10-user.STAPER)*6)

	if(istype(user.rmb_intent, /datum/rmb_intent/aimed))
		chance2hit += 20
	if(istype(user.rmb_intent, /datum/rmb_intent/swift))
		chance2hit -= 20

	chance2hit = CLAMP(chance2hit, 5, 95)

	if(prob(chance2hit))
		return zone
	else
		if(prob(chance2hit+(user.STAPER - 10)))
			if(check_zone(zone) == zone)
				return zone
			to_chat(user, span_warning("Accuracy fail! [chance2hit]%"))
			if(user.STAPER >= 11)
				if(user.client?.prefs.showrolls)
					return check_zone(zone)
			else
				return BODY_ZONE_CHEST
		else
			if(user.client?.prefs.showrolls)
				to_chat(user, span_warning("Double accuracy fail! [chance2hit]%"))
			return BODY_ZONE_CHEST

/mob/proc/get_generic_parry_drain()
	return 30

/mob/living/proc/checkmiss(mob/living/user)
	if(user == src)
		return FALSE
	if(stat)
		return FALSE
	if(!(mobility_flags & MOBILITY_STAND))
		return FALSE
	if(user.badluck(4))
		var/list/usedp = list("Critical miss!", "Damn! Critical miss!", "No! Critical miss!", "It can't be! Critical miss!", "Bad luck! Critical miss!", "Curse creation! Critical miss!", "What?! Critical miss!")
		to_chat(user, span_boldwarning("[pick(usedp)]"))
		flash_fullscreen("blackflash2")
		user.aftermiss()
		return TRUE


/mob/living/proc/checkdefense(datum/intent/intenty, mob/living/user)
	testing("begin defense")
	if(!cmode)
		return FALSE
	if(stat)
		return FALSE
	if(!canparry && !candodge) //mob can do neither of these
		return FALSE
	if(!cmode)
		return FALSE
	if(user == src)
		return FALSE
	if(!(mobility_flags & MOBILITY_MOVE))
		return FALSE

	if(client && used_intent)
		if(client.charging && used_intent.tranged && !used_intent.tshield)
			return FALSE

	var/prob2defend = user.defprob
	var/mob/living/H = src
	var/mob/living/U = user
	if(H && U)
		prob2defend = 0

	if(!can_see_cone(user))
		if(d_intent == INTENT_PARRY)
			return FALSE
		else
			prob2defend = max(prob2defend-15,0)

//	if(!cmode) // not currently used, see cmode check above
//		prob2defend = max(prob2defend-15,0)

	if(m_intent == MOVE_INTENT_RUN)
		prob2defend = max(prob2defend-15,0)

	switch(d_intent)
		if(INTENT_PARRY)
			if(HAS_TRAIT(src, TRAIT_CHUNKYFINGERS))
				return FALSE
			if(pulledby == user && pulledby.grab_state >= GRAB_AGGRESSIVE)
				return FALSE
			if(pulling == user && grab_state >= GRAB_AGGRESSIVE)
				return FALSE
			if(world.time < last_parry + setparrytime)
				if(!istype(rmb_intent, /datum/rmb_intent/riposte))
					return FALSE
			if(has_status_effect(/datum/status_effect/debuff/feinted))
				return FALSE
			if(has_status_effect(/datum/status_effect/debuff/riposted))
				return FALSE
			last_parry = world.time
			if(intenty && !intenty.canparry)
				return FALSE
			var/drained = user.defdrain
			var/weapon_parry = FALSE
			var/offhand_defense = 0
			var/mainhand_defense = 0
			var/highest_defense = 0
			var/obj/item/mainhand = get_active_held_item()
			var/obj/item/offhand = get_inactive_held_item()
			var/obj/item/used_weapon = mainhand
			var/obj/item/rogueweapon/shield/buckler/skiller = get_inactive_held_item()  // buckler code
			var/obj/item/rogueweapon/shield/buckler/skillerbuck = get_active_held_item()

			if(istype(offhand, /obj/item/rogueweapon/shield/buckler))
				skiller.bucklerskill(H)
			if(istype(mainhand, /obj/item/rogueweapon/shield/buckler))
				skillerbuck.bucklerskill(H)  //buckler code end

			if(mainhand)
				if(mainhand.can_parry)
					mainhand_defense += (H.mind ? (H.mind.get_skill_level_capped(mainhand.associated_skill) * 20) : 20)
					mainhand_defense += (mainhand.wdefense * 10)
			if(offhand)
				if(offhand.can_parry)
					offhand_defense += (H.mind ? (H.mind.get_skill_level_capped(offhand.associated_skill) * 20) : 20)
					offhand_defense += (offhand.wdefense * 10)

			if(mainhand_defense >= offhand_defense)
				highest_defense += mainhand_defense
			else
				used_weapon = offhand
				highest_defense += offhand_defense

			var/defender_skill = 0
			var/attacker_skill = 0

			if(highest_defense <= (H.mind ? (H.mind.get_skill_level(/datum/skill/combat/unarmed) * 20) : 20))
				defender_skill = H.mind?.get_skill_level(/datum/skill/combat/unarmed)
				prob2defend += (defender_skill * 20)
				weapon_parry = FALSE
			else
				defender_skill = H.mind?.get_skill_level_capped(used_weapon.associated_skill)
				prob2defend += highest_defense
				weapon_parry = TRUE

			if(U.mind)
				if(intenty.masteritem)
					attacker_skill = U.mind.get_skill_level_capped(intenty.masteritem.associated_skill)
					prob2defend -= (attacker_skill * 20)
					if((intenty.masteritem.wbalance > 0) && (user.STASPD > src.STASPD)) //enemy weapon is quick, so get a bonus based on spddiff
						prob2defend -= ( intenty.masteritem.wbalance * ((user.STASPD - src.STASPD) * 10) )
				else
					attacker_skill = U.mind.get_skill_level(/datum/skill/combat/unarmed)
					prob2defend -= (attacker_skill * 20)

			if(HAS_TRAIT(src, TRAIT_GUIDANCE))
				prob2defend += 15

			if(user.has_status_effect(/datum/status_effect/buff/chargedriposte)) // one-time use attack
				prob2defend -= 200
				remove_status_effect(/datum/status_effect/buff/chargedriposte)

			if(HAS_TRAIT(user, TRAIT_GUIDANCE))
				prob2defend -= 15

			// parrying while knocked down sucks ass
			if(!(mobility_flags & MOBILITY_STAND))
				prob2defend *= 0.65

			if(HAS_TRAIT(H, TRAIT_SENTINELOFWITS))
				if(ishuman(H))
					var/mob/living/carbon/human/SH = H
					var/sentinel = SH.calculate_sentinel_bonus()
					prob2defend += sentinel

			prob2defend = clamp(prob2defend, 5, 90)
			if(HAS_TRAIT(user, TRAIT_HARDSHELL) && H.client)	//Dwarf-merc specific limitation w/ their armor on in pvp
				prob2defend = clamp(prob2defend, 5, 70)

			if(src.dodgecharges > 0 && has_status_effect(/datum/status_effect/buff/carthusgrace)) //fullblock hits until you run out of charges, with flourish
				prob2defend = 100
				src.dodgecharges--
				src.visible_message(span_info("[src] moves with unnatural grace, effortlessly fending off [user]'s attack"))

			if(src.dodgecharges > 0 && !has_status_effect(/datum/status_effect/buff/carthusgrace)) //fullblock hits until you run out of charges
				prob2defend = 100
				src.dodgecharges--
				src.visible_message(span_info("[src]'s arm snaps out, fending off [user] at the last second"))

			if(src.dodgecharges == 0 && has_status_effect(/datum/status_effect/buff/carthusinstinct)) //if you have the buff and use all your charges, gain a riposte
				src.remove_status_effect(/datum/status_effect/buff/carthusinstinct)
				src.remove_status_effect(/datum/status_effect/buff/carthusgrace)
				src.visible_message(span_info("[src]'s arms glow with the vestiges of their divine boon, while the rest of them slows down"))
				src.apply_status_effect(/datum/status_effect/buff/chargedriposte)
				
			//Dual Wielding
			var/attacker_dualw
			var/defender_dualw
			var/extraattroll
			var/extradefroll

			//Dual Wielder defense disadvantage
			if(HAS_TRAIT(src, TRAIT_DUALWIELDER) && istype(offhand, mainhand))
				extradefroll = prob(prob2defend)
				defender_dualw = TRUE

			//Dual Wielder attack advantage
			var/obj/item/mainh = user.get_active_held_item()
			var/obj/item/offh = user.get_inactive_held_item()
			if(mainh && offh && HAS_TRAIT(user, TRAIT_DUALWIELDER))
				if(istype(mainh, offh))
					extraattroll = prob(prob2defend)
					attacker_dualw = TRUE

			if(src.client?.prefs.showrolls)
				var/text = "Roll to parry... [prob2defend]%"
				if((defender_dualw || attacker_dualw))
					if(defender_dualw && attacker_dualw)
						text += " Our dual wielding cancels out!"
					else//If we're defending against or as a dual wielder, we roll disadv. But if we're both dual wielding it cancels out.
						text += " Twice! Disadvantage! ([(prob2defend / 100) * (prob2defend / 100) * 100]%)"
				to_chat(src, span_info("[text]"))

			var/attacker_feedback
			if(user.client?.prefs.showrolls && (attacker_dualw || defender_dualw))
				attacker_feedback = "Attacking with advantage. ([100 - ((prob2defend / 100) * (prob2defend / 100) * 100)]%)"

			var/parry_status = FALSE
			if((defender_dualw && attacker_dualw) || (!defender_dualw && !attacker_dualw)) //They cancel each other out
				if(attacker_feedback)
					attacker_feedback = "Advantage cancelled out!"
				if(prob(prob2defend))
					parry_status = TRUE
			else if(attacker_dualw)
				if(prob(prob2defend) && extraattroll)
					parry_status = TRUE
			else if(defender_dualw)
				if(prob(prob2defend) && extradefroll)
					parry_status = TRUE

			if(attacker_feedback)
				to_chat(user, span_info("[attacker_feedback]"))

			if(parry_status)
				if(intenty.masteritem)
					if(intenty.masteritem.wbalance < 0 && user.STASTR > src.STASTR) //enemy weapon is heavy, so get a bonus scaling on strdiff
						drained = drained + ( intenty.masteritem.wbalance * ((user.STASTR - src.STASTR) * -5) )
			else
				to_chat(src, span_warning("The enemy defeated my parry!"))
				if(HAS_TRAIT(src, TRAIT_MAGEARMOR))
					if(H.magearmor == 0)
						H.magearmor = 1
						H.apply_status_effect(/datum/status_effect/buff/magearmor)
						to_chat(src, span_boldwarning("My mage armor absorbs the hit and dissipates!"))
						return TRUE
					else
						return FALSE
				else
					return FALSE

			drained = max(drained, 5)

			var/exp_multi = 1

			if(!U.mind)
				exp_multi = exp_multi/2
			if(istype(user.rmb_intent, /datum/rmb_intent/weak))
				exp_multi = exp_multi/2

			if(weapon_parry == TRUE)
				if(do_parry(used_weapon, drained, user)) //show message
					if ((mobility_flags & MOBILITY_STAND))
						var/skill_target = attacker_skill
						if(!HAS_TRAIT(U, TRAIT_GOODTRAINER))
							skill_target -= SKILL_LEVEL_NOVICE
						if (can_train_combat_skill(src, used_weapon.associated_skill, skill_target))
							mind.add_sleep_experience(used_weapon.associated_skill, max(round(STAINT*exp_multi), 0), FALSE)

					var/obj/item/AB = intenty.masteritem

					//attacker skill gain

					if(U.mind)
						var/attacker_skill_type
						if(AB)
							attacker_skill_type = AB.associated_skill
						else
							attacker_skill_type = /datum/skill/combat/unarmed
						if ((mobility_flags & MOBILITY_STAND))
							var/skill_target = defender_skill
							if(!HAS_TRAIT(src, TRAIT_GOODTRAINER))
								skill_target -= SKILL_LEVEL_NOVICE
							if (can_train_combat_skill(U, attacker_skill_type, skill_target))
								U.mind.add_sleep_experience(attacker_skill_type, max(round(STAINT*exp_multi), 0), FALSE)

					if(prob(66) && AB)
						if((used_weapon.flags_1 & CONDUCT_1) && (AB.flags_1 & CONDUCT_1))
							flash_fullscreen("whiteflash")
							user.flash_fullscreen("whiteflash")
							var/datum/effect_system/spark_spread/S = new()
							var/turf/front = get_step(src,src.dir)
							S.set_up(1, 1, front)
							S.start()
						else
							flash_fullscreen("blackflash2")
					else
						flash_fullscreen("blackflash2")

					var/dam2take = round((get_complex_damage(AB,user,used_weapon.blade_dulling)/2),1)
					if(dam2take)
						used_weapon.take_damage(max(dam2take,1), BRUTE, used_weapon.d_type)
					return TRUE
				else
					return FALSE

			if(weapon_parry == FALSE)
				if(do_unarmed_parry(drained, user))
					if((mobility_flags & MOBILITY_STAND))
						var/skill_target = attacker_skill
						if(!HAS_TRAIT(U, TRAIT_GOODTRAINER))
							skill_target -= SKILL_LEVEL_NOVICE
						if(can_train_combat_skill(H, /datum/skill/combat/unarmed, skill_target))
							H.mind?.add_sleep_experience(/datum/skill/combat/unarmed, max(round(STAINT*exp_multi), 0), FALSE)
					flash_fullscreen("blackflash2")
					return TRUE
				else
					testing("failparry")
					return FALSE
		if(INTENT_DODGE)
			if(pulledby && pulledby.grab_state >= GRAB_AGGRESSIVE)
				return FALSE
			if(pulling == user)
				return FALSE
			if(world.time < last_dodge + dodgetime)
				if(!istype(rmb_intent, /datum/rmb_intent/riposte))
					return FALSE
			if(has_status_effect(/datum/status_effect/debuff/riposted))
				return FALSE
			if(has_status_effect(/datum/status_effect/debuff/feinted))
				return FALSE
			last_dodge = world.time
			if(src.loc == user.loc)
				return FALSE
			if(intenty)
				if(!intenty.candodge)
					return FALSE
			if(candodge)
				var/list/dirry = list()
				var/dx = x - user.x
				var/dy = y - user.y
				if(abs(dx) < abs(dy))
					if(dy > 0)
						dirry += NORTH
						dirry += WEST
						dirry += EAST
					else
						dirry += SOUTH
						dirry += WEST
						dirry += EAST
				else
					if(dx > 0)
						dirry += EAST
						dirry += SOUTH
						dirry += NORTH
					else
						dirry += WEST
						dirry += NORTH
						dirry += SOUTH
				var/turf/turfy
				for(var/x in shuffle(dirry.Copy()))
					turfy = get_step(src,x)
					if(turfy)
						if(turfy.density)
							continue
						for(var/atom/movable/AM in turfy)
							if(AM.density)
								continue
						break
				if(pulledby)
					return FALSE
				if(!turfy)
					to_chat(src, span_boldwarning("There's nowhere to dodge to!"))
					return FALSE
				else
					if(do_dodge(user, turfy))
						flash_fullscreen("blackflash2")
						user.aftermiss()
						return TRUE
					else
						if(HAS_TRAIT(src, TRAIT_MAGEARMOR))
							if(H.magearmor == 0)
								H.magearmor = 1
								H.apply_status_effect(/datum/status_effect/buff/magearmor)
								to_chat(src, span_boldwarning("My mage armor absorbs the hit and dissipates!"))
								return TRUE
							else
								return FALSE
						else
							return FALSE
			else
				return FALSE

// origin is used for multi-step dodges like jukes
/mob/living/proc/get_dodge_destinations(mob/living/attacker, atom/origin = src)
	var/dodge_dir = get_dir(attacker, origin)
	if(!dodge_dir)
		return null
	var/list/dirry = list()
	// pick a random dir
	var/list/turf/dodge_candidates = list()
	for(var/dir_to_check in dirry)
		var/turf/dodge_candidate = get_step(origin, dir_to_check)
		if(!dodge_candidate)
			continue
		if(dodge_candidate.density)
			continue
		var/has_impassable_atom = FALSE
		for(var/atom/movable/AM in dodge_candidate)
			if(!AM.CanPass(src, dodge_candidate))
				has_impassable_atom = TRUE
				break
		if(has_impassable_atom)
			continue
		dodge_candidates += dodge_candidate
	return dodge_candidates

/mob/proc/do_parry(obj/item/W, parrydrain as num, mob/living/user)
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.rogfat_add(parrydrain))
			if(W)
				playsound(get_turf(src), pick(W.parrysound), 100, FALSE)
			if(istype(rmb_intent, /datum/rmb_intent/riposte))
				src.visible_message(span_boldwarning("<b>[src]</b> ripostes [user] with [W]!"))
			else
				src.visible_message(span_boldwarning("<b>[src]</b> parries [user] with [W]!"))
			return TRUE
		else
			to_chat(src, span_warning("I'm too tired to parry!"))
			return FALSE //crush through
	else
		if(W)
			playsound(get_turf(src), pick(W.parrysound), 100, FALSE)
		return TRUE

/mob/proc/do_unarmed_parry(parrydrain as num, mob/living/user)
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.rogfat_add(parrydrain))
			playsound(get_turf(src), pick(parry_sound), 100, FALSE)
			src.visible_message(span_warning("<b>[src]</b> parries [user]!"))
			return TRUE
		else
			to_chat(src, span_boldwarning("I'm too tired to parry!"))
			return FALSE
	else
		playsound(get_turf(src), pick(parry_sound), 100, FALSE)
		return TRUE


/mob/proc/do_dodge(mob/user, turf/turfy)
	if(dodgecd)
		return FALSE
	var/mob/living/L = src
	var/mob/living/U = user
	var/mob/living/carbon/human/H
	var/mob/living/carbon/human/UH
	var/obj/item/I
	var/drained = 10
	if(ishuman(src))
		H = src
	if(ishuman(user))
		UH = user
		I = UH.used_intent.masteritem
	var/prob2defend = U.defprob
	if(L.rogfat >= L.maxrogfat)
		return FALSE
	if(L)
		if(H?.check_dodge_skill())
			prob2defend = prob2defend + (L.STASPD * 15)
		else
			prob2defend = prob2defend + (L.STASPD * 10)
	if(U)
		prob2defend = prob2defend - (U.STASPD * 10)
	if(I)
		if(I.wbalance > 0 && U.STASPD > L.STASPD) //nme weapon is quick, so they get a bonus based on spddiff
			prob2defend = prob2defend - ( I.wbalance * ((U.STASPD - L.STASPD) * 10) )
		if(I.wbalance < 0 && L.STASPD > U.STASPD) //nme weapon is slow, so its easier to dodge if we're faster
			prob2defend = prob2defend + ( I.wbalance * ((U.STASPD - L.STASPD) * 10) )
		if(UH?.mind)
			prob2defend = prob2defend - (UH.mind.get_skill_level_capped(I.associated_skill) * 10)
	if(H)
		if(!H?.check_armor_skill() || H?.legcuffed)
			H.Knockdown(1)
			return FALSE
		/* Commented out due to gaping imbalance
			if(H?.check_dodge_skill())
				drained = drained - 5  commented out for being too much. It was giving effectively double stamina efficiency compared to everyone else.
			if(H.mind)
				drained = drained + max((H.checkwornweight() * 10)-(mind.get_skill_level(/datum/skill/misc/athletics) * 10),0)
			else
				drained = drained + (H.checkwornweight() * 10)
		*/
		if(I) //the enemy attacked us with a weapon
			if(!I.associated_skill) //the enemy weapon doesn't have a skill because its improvised, so penalty to attack
				prob2defend = prob2defend + 10
			else
				if(H.mind)
					prob2defend = prob2defend + (H.mind.get_skill_level_capped(I.associated_skill) * 10)
				/* Commented out due to encumbrance being seemingly broken and nonfunctional
				var/thing = H.encumbrance
				if(thing > 0)
					drained = drained + (thing * 10)
				*/
		else //the enemy attacked us unarmed or is nonhuman
			if(UH)
				if(UH.used_intent.unarmed)
					if(UH.mind)
						prob2defend = prob2defend - (UH.mind.get_skill_level(/datum/skill/combat/unarmed) * 10)
					if(H.mind)
						prob2defend = prob2defend + (H.mind.get_skill_level(/datum/skill/combat/unarmed) * 10)

		if(HAS_TRAIT(L, TRAIT_GUIDANCE))
			prob2defend += 15

		if(HAS_TRAIT(U, TRAIT_GUIDANCE))
			prob2defend -= 15

		if(U.has_status_effect(/datum/status_effect/buff/chargedriposte)) // one-time use attack
			prob2defend -= 200
			U.remove_status_effect(/datum/status_effect/buff/chargedriposte)

		// dodging while knocked down sucks ass
		if(!(L.mobility_flags & MOBILITY_STAND))
			prob2defend *= 0.25

		if(HAS_TRAIT(H, TRAIT_SENTINELOFWITS))
			var/sentinel = H.calculate_sentinel_bonus()
			prob2defend += sentinel

		prob2defend = clamp(prob2defend, 5, 90)

		if(L.dodgecharges > 0 && L.has_status_effect(/datum/status_effect/buff/carthusgrace)) //fullblock hits until you run out of charges, with flourish
			prob2defend = 100
			L.dodgecharges--
			L.visible_message(span_info("[L] moves with unnatural grace, effortlessly dancing around [U]'s attack"))

		if(L.dodgecharges > 0 && !L.has_status_effect(/datum/status_effect/buff/carthusgrace)) //fullblock hits until you run out of charges
			prob2defend = 100
			L.dodgecharges--
			L.visible_message(span_info("[L]'s suddenly sidesteps, dodging [U]'s blow"))

		if(L.dodgecharges == 0 && L.has_status_effect(/datum/status_effect/buff/carthusinstinct)) //if you have the buff and use all your charges, gain a riposte
			L.remove_status_effect(/datum/status_effect/buff/carthusinstinct)
			L.remove_status_effect(/datum/status_effect/buff/carthusgrace)
			L.visible_message(span_info("[L]'s arms glow with the vestiges of their divine boon, while the rest of them slows down"))
			L.apply_status_effect(/datum/status_effect/buff/chargedriposte)
			
		//------------Dual Wielding Checks------------
		var/attacker_dualw
		var/defender_dualw
		var/extraattroll
		var/extradefroll
		var/mainhand = L.get_active_held_item()
		var/offhand	= L.get_inactive_held_item()

		//Dual Wielder defense disadvantage
		if(mainhand && offhand)
			if(HAS_TRAIT(src, TRAIT_DUALWIELDER) && istype(offhand, mainhand))
				extradefroll = prob(prob2defend)
				defender_dualw = TRUE

		//dual-wielder attack advantage
		var/obj/item/mainh = U.get_active_held_item()
		var/obj/item/offh = U.get_inactive_held_item()
		if(mainh && offh && HAS_TRAIT(U, TRAIT_DUALWIELDER))
			if(istype(mainh, offh))
				extraattroll = prob(prob2defend)
				attacker_dualw = TRUE
		//----------Dual Wielding check end---------

		var/attacker_feedback
		if(user.client?.prefs.showrolls && (attacker_dualw || defender_dualw))
			attacker_feedback = "Attacking with advantage. ([100 - ((prob2defend / 100) * (prob2defend / 100) * 100)]%)"

		if(src.client?.prefs.showrolls)
			var/text = "Roll to dodge... [prob2defend]%"
			if((defender_dualw || attacker_dualw))
				if(defender_dualw && attacker_dualw)
					text += " Our dual wielding cancels out!"
				else//If we're defending against or as a dual wielder, we roll disadv. But if we're both dual wielding it cancels out.
					text += " Twice! Disadvantage! ([(prob2defend / 100) * (prob2defend / 100) * 100]%)"
			to_chat(src, span_info("[text]"))

		var/dodge_status = FALSE
		if((!defender_dualw && !attacker_dualw) || (defender_dualw && attacker_dualw)) //They cancel each other out
			if(attacker_feedback)
				attacker_feedback = "Advantage cancelled out!"
			if(prob(prob2defend))
				dodge_status = TRUE
		else if(attacker_dualw)
			if(prob(prob2defend) && extraattroll)
				dodge_status = TRUE
		else if(defender_dualw)
			if(prob(prob2defend) && extradefroll)
				dodge_status = TRUE

		if(attacker_feedback)
			to_chat(user, span_info("[attacker_feedback]"))

		if(!dodge_status)
			return FALSE
		if(!H.rogfat_add(max(drained,5)))
			to_chat(src, span_warning("I'm too tired to dodge!"))
			return FALSE
	else //we are a non human
		prob2defend = clamp(prob2defend, 5, 90)
		if(client?.prefs.showrolls)
			to_chat(src, span_info("Roll to dodge... [prob2defend]%"))
		if(!prob(prob2defend))
			return FALSE
	dodgecd = TRUE
	playsound(src, 'sound/combat/dodge.ogg', 100, FALSE)
	throw_at(turfy, 1, 2, src, FALSE)
	if(drained > 0)
		src.visible_message(span_warning("<b>[src]</b> dodges [user]'s attack!"))
	else
		src.visible_message(span_warning("<b>[src]</b> easily dodges [user]'s attack!"))
	dodgecd = FALSE
//		if(H)
//			if(H.IsOffBalanced())
//				H.Knockdown(1)
//				to_chat(H, span_danger("I tried to dodge off-balance!"))
//		if(isturf(loc))
//			var/turf/T = loc
//			if(T.landsound)
//				playsound(T, T.landsound, 100, FALSE)
	return TRUE

/mob/proc/food_tempted(/obj/item/W, mob/user)
	return

/mob/proc/taunted(mob/user)
	return

/mob/proc/shood(mob/user)
	return

/mob/proc/beckoned(mob/user)
	return

/mob/proc/get_punch_dmg()
	return


/mob/proc/add_family_hud(antag_hud_type, antag_hud_name)
	var/datum/atom_hud/antag/hud = GLOB.huds[antag_hud_type]
	hud.join_hud(src)
	set_antag_hud(src, antag_hud_name)


/mob/proc/remove_family_hud(antag_hud_type)
	var/datum/atom_hud/antag/hud = GLOB.huds[antag_hud_type]
	hud.leave_hud(src)
	set_antag_hud(src, null)

/mob/living/carbon/human/proc/calculate_sentinel_bonus()
	if(STAINT > 10)
		var/fakeint = STAINT
		if(status_effects.len)
			for(var/S in status_effects)
				var/datum/status_effect/status = S
				if(status.effectedstats.len)
					if(status.effectedstats["intelligence"])
						if(status.effectedstats["intelligence"] > 0)
							fakeint -= status.effectedstats["intelligence"]
		if(fakeint > 10)
			var/bonus = round(((fakeint - 10) / 2)) * 10
			if(bonus > 0)
				if(is_combat_class(src))
					bonus = clamp(bonus, 0, 25)
				else
					bonus = clamp(bonus, 0, 50)//20-21 INT
			return bonus
		else
			return 0
	else
		return 0

