///////////// OVERLAY EFFECTS /////////////
/obj/effect/overlay/water
	icon = 'icons/turf/newwater.dmi'
	icon_state = "bottom"
	density = 0
	mouse_opacity = 0
	layer = BELOW_MOB_LAYER
	anchored = TRUE

/obj/effect/overlay/water/top
	icon_state = "top"
	layer = BELOW_MOB_LAYER


/turf/open/water
	gender = PLURAL
	name = "water"
	desc = "Good enough to drink, wet enough to douse fires."
	icon = 'icons/turf/roguefloor.dmi'
	icon_state = "together"
	baseturfs = /turf/open/water
	slowdown = 5
	var/obj/effect/overlay/water/water_overlay
	var/obj/effect/overlay/water/top/water_top_overlay
	bullet_sizzle = TRUE
	bullet_bounce_sound = null //needs a splashing sound one day.
	smooth = SMOOTH_MORE
	canSmoothWith = list(/turf/closed/mineral,/turf/closed/wall/mineral/rogue, /turf/open/floor/rogue)
	footstep = null
	barefootstep = null
	clawfootstep = null
	heavyfootstep = null
	landsound = 'sound/foley/jumpland/waterland.wav'
	neighborlay_override = "edge"
	var/water_color = "#6a9295"
	var/water_reagent = /datum/reagent/water
	var/water_reagent_purified = /datum/reagent/water // If put through a water filtration device, provides this reagent instead
	var/mapped = TRUE // infinite source of water
	var/water_volume = 100 // 100 is 1 bucket
	var/water_maximum = 100
	water_level = 2
	var/wash_in = TRUE
	var/swim_skill = FALSE
	nomouseover = FALSE
	var/swimdir = FALSE
	var/clearwater = FALSE

/turf/open/water/Initialize()
	.  = ..()
	water_overlay = new(src)
	water_top_overlay = new(src)
	update_icon()

/turf/open/water/update_icon()
	if(water_overlay)
		water_overlay.color = water_color
		water_overlay.icon_state = "bottom[water_level]"
	if(water_top_overlay)
		water_top_overlay.color = water_color
		water_top_overlay.icon_state = "top[water_level]"

/turf/open/water/Exited(atom/movable/AM, atom/newloc)
	. = ..()
	if(isliving(AM) && !AM.throwing)
		var/mob/living/user = AM
		if(isliving(user) && !user.is_floor_hazard_immune())
			for(var/obj/structure/S in src)
				if(S.obj_flags & BLOCK_Z_OUT_DOWN)
					return
			if(water_overlay)
				if((get_dir(src, newloc) == SOUTH))
					water_overlay.layer = BELOW_MOB_LAYER
					water_overlay.plane = GAME_PLANE
				else
					spawn(6)
						if(!locate(/mob/living) in src)
							water_overlay.layer = BELOW_MOB_LAYER
							water_overlay.plane = GAME_PLANE
			var/drained = get_stamina_drain(user, get_dir(src, newloc))
			if(drained && !user.rogfat_add(drained))
				user.Immobilize(30)
				addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living, Knockdown), 30), 1 SECONDS)

/turf/open/water/proc/get_stamina_drain(mob/living/swimmer, travel_dir)
	var/const/BASE_STAM_DRAIN = 15
	var/const/MIN_STAM_DRAIN = 1
	var/const/STAM_PER_LEVEL = 5
	var/const/NPC_SWIM_LEVEL = SKILL_LEVEL_APPRENTICE
	var/const/UNSKILLED_ARMOR_PENALTY = 40
	if(!isliving(swimmer))
		return 0
	if(!swim_skill)
		return 0 // no stam cost
	if(swimmer.is_floor_hazard_immune())
		return 0 // floating!
	if(swimdir && travel_dir && travel_dir == dir)
		return 0 // going with the flow
	if(swimmer.buckled)
		return 0
	var/swimming_skill_level = swimmer.mind ? swimmer.mind.get_skill_level(/datum/skill/misc/swimming) : NPC_SWIM_LEVEL
	. = max(BASE_STAM_DRAIN - (swimming_skill_level * STAM_PER_LEVEL), MIN_STAM_DRAIN)
//	. += (swimmer.checkwornweight()*2)
	if(!swimmer.check_armor_skill())
		. += UNSKILLED_ARMOR_PENALTY
	if(.) // this check is expensive so we only run it if we do expect to use stamina	
		for(var/obj/structure/S in src)
			if(S.obj_flags & BLOCK_Z_OUT_DOWN)
				return 0
		for(var/D in GLOB.cardinals) //adjacent to a floor to hold onto
			if(istype(get_step(src, D), /turf/open/floor))
				return 0

// Mobs won't try to path through water if low on stamina,
// and will take advantage of water flow to move faster.
/turf/open/water/get_heuristic_slowdown(mob/traverser, travel_dir)
	/// Mobs will heavily avoid pathing through this turf if their stamina is too low.
	var/const/LOW_STAM_PENALTY = 7 // only go through this if we'd have to go offscreen otherwise
	. = ..()
	if(isliving(traverser) && !HAS_TRAIT(traverser, TRAIT_NOROGSTAM))
		var/mob/living/living_traverser = traverser
		var/remaining_stamina = (living_traverser.maxrogfat - living_traverser.rogfat)
		if(remaining_stamina < get_stamina_drain(living_traverser, travel_dir)) // not enough stamina reserved to cross
			. += LOW_STAM_PENALTY // really want to avoid this unless we don't have any better options

/turf/open/water/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum, damage_flag = "blunt")
	..()
	playsound(src, pick('sound/foley/water_land1.ogg','sound/foley/water_land2.ogg','sound/foley/water_land3.ogg'), 100, FALSE)


/turf/open/water/cardinal_smooth(adjacencies)
	roguesmooth(adjacencies)

/turf/open/water/roguesmooth(adjacencies)
	var/list/Yeah = ..()
	if(water_overlay)
		water_overlay.cut_overlays(TRUE)
		if(Yeah)
			water_overlay.add_overlay(Yeah)
	if(water_top_overlay)
		water_top_overlay.cut_overlays(TRUE)
		if(Yeah)
			water_top_overlay.add_overlay(Yeah)

/turf/open/water/Entered(atom/movable/AM, atom/oldLoc)
	. = ..()
	for(var/obj/structure/S in src)
		if(S.obj_flags & BLOCK_Z_OUT_DOWN)
			return
	if(isliving(AM) && !AM.throwing)
		var/mob/living/L = AM
		if(!(L.mobility_flags & MOBILITY_STAND) || water_level == 3)
			L.SoakMob(FULL_BODY)
		else
			if(water_level == 2)
				L.SoakMob(BELOW_CHEST)
		if(water_overlay)
			if(water_level > 1 && !istype(oldLoc, type))
				playsound(AM, 'sound/foley/waterenter.ogg', 100, FALSE)
			else
				playsound(AM, pick('sound/foley/watermove (1).ogg','sound/foley/watermove (2).ogg'), 100, FALSE)
			if(istype(oldLoc, type) && (get_dir(src, oldLoc) != SOUTH))
				water_overlay.layer = ABOVE_MOB_LAYER
				water_overlay.plane = GAME_PLANE_UPPER
			else
				spawn(6)
					if(AM.loc == src)
						water_overlay.layer = ABOVE_MOB_LAYER
						water_overlay.plane = GAME_PLANE_UPPER

/turf/open/water/attackby(obj/item/C, mob/user, params)
	if(user.used_intent.type == /datum/intent/fill)
		if(C.reagents)
			if(C.reagents.holder_full())
				to_chat(user, span_warning("[C] is full."))
				return
			playsound(user, 'sound/foley/drawwater.ogg', 100, FALSE)
			if(do_after(user, 8, target = src))
				user.changeNext_move(CLICK_CD_MELEE)
				C.reagents.add_reagent(water_reagent, 200)
				to_chat(user, span_notice("I fill [C] from [src]."))
				// If the user is filling a water purifier and the water isn't already clean...
				if (istype(C, /obj/item/reagent_containers/glass/bottle/waterskin/purifier) && water_reagent != water_reagent_purified)
					var/obj/item/reagent_containers/glass/bottle/waterskin/purifier/P = C
					P.cleanwater(user)
			return
	. = ..()

/turf/open/water/attack_right(mob/user)
	if(isliving(user))
		var/mob/living/L = user
		if(L.stat != CONSCIOUS)
			return
		var/list/wash = list('sound/foley/waterwash (1).ogg','sound/foley/waterwash (2).ogg')
		playsound(user, pick_n_take(wash), 100, FALSE)
		var/item2wash = user.get_active_held_item()
		if(!item2wash)
			user.visible_message(span_info("[user] starts to wash in [src]."))
			if(do_after(L, 3 SECONDS, target = src))
				if(wash_in)
					wash_atom(user, CLEAN_STRONG)
				playsound(user, pick(wash), 100, FALSE)
		else
			user.visible_message(span_info("[user] starts to wash [item2wash] in [src]."))
			if(do_after(L, 30, target = src))
				if(wash_in)
					wash_atom(item2wash, CLEAN_STRONG)
				playsound(user, pick(wash), 100, FALSE)
		return
	..()

/turf/open/water/onbite(mob/user)
	if(isliving(user))
		var/mob/living/L = user
		if(L.stat != CONSCIOUS)
			return
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			if(C.is_mouth_covered())
				return
		playsound(user, pick('sound/foley/waterwash (1).ogg','sound/foley/waterwash (2).ogg'), 100, FALSE)
		user.visible_message(span_info("[user] starts to drink from [src]."))
		if(do_after(L, 25, target = src))
			var/list/waterl = list()
			waterl[water_reagent] = 2
			var/datum/reagents/reagents = new()
			reagents.add_reagent_list(waterl)
			reagents.trans_to(L, reagents.total_volume, transfered_by = user, method = INGEST)
			playsound(user,pick('sound/items/drink_gen (1).ogg','sound/items/drink_gen (2).ogg','sound/items/drink_gen (3).ogg'), 100, TRUE)
		return
	..()

/turf/open/water/Destroy()
	. = ..()
	if(water_overlay)
		QDEL_NULL(water_overlay)
	if(water_top_overlay)
		QDEL_NULL(water_top_overlay)

/turf/open/water/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum, damage_flag = "blunt")
	if(isobj(AM))
		var/obj/O = AM
		O.extinguish()

/turf/open/water/get_slowdown(mob/user)
	var/returned = slowdown
	if(user?.mind && swim_skill)
		returned = returned - (user.mind.get_skill_level(/datum/skill/misc/swimming))
	return returned

//turf/open/water/Initialize()
//	dir = pick(NORTH,SOUTH,WEST,EAST)
//	. = ..()


/turf/open/water/bath
	name = "water"
	desc = "Soothing water, with soapy bubbles on the surface."
	icon = 'icons/turf/roguefloor.dmi'
	icon_state = "bathtileW"
	water_level = 2
	water_color = "#FFFFFF"
	slowdown = 3
	water_reagent = /datum/reagent/water/bathwater

/turf/open/water/bath/Initialize()
	.  = ..()
	icon_state = "bathtile"

/turf/open/water/sewer
	name = "sewage"
	desc = "This dark water smells like dead rats and sulphur!"
	icon = 'icons/turf/roguefloor.dmi'
	icon_state = "pavingW"
	water_level = 1
	water_color = "#705a43"
	slowdown = 1
	wash_in = FALSE
	water_reagent = /datum/reagent/water/gross

/turf/open/water/sewer/Initialize()
	icon_state = "paving"
	water_color = pick("#705a43","#697043")
	.  = ..()

/turf/open/water/swamp
	name = "murk"
	desc = "Weeds and algae cover the surface of the water."
	icon = 'icons/turf/roguefloor.dmi'
	icon_state = "dirtW2"
	water_level = 2
	water_color = "#705a43"
	slowdown = 3
	wash_in = TRUE
	water_reagent = /datum/reagent/water/gross

/turf/open/water/swamp/Initialize()
	icon_state = "dirt"
	dir = pick(GLOB.cardinals)
	water_color = pick("#705a43")
	.  = ..()

/turf/open/water/swamp/Entered(atom/movable/AM, atom/oldLoc)
	. = ..()
	if(isliving(AM) && !AM.throwing)
		if(ishuman(AM))
			var/mob/living/carbon/human/C = AM
			var/chance = 3
			if(C.m_intent == MOVE_INTENT_RUN)
				chance = 6
			if(C.m_intent == MOVE_INTENT_SNEAK)
				chance = 1
			if(HAS_TRAIT(C,TRAIT_LEECHIMMUNE))
				return
			if(!prob(chance))
				return
			if(C.blood_volume <= 0)
				return
			var/list/zonee = list(BODY_ZONE_R_LEG, BODY_ZONE_L_LEG, BODY_ZONE_CHEST)
			for(var/i = 0, i <= zonee.len, i++)
				var/zone = pick(zonee)
				var/obj/item/bodypart/BP = C.get_bodypart(zone)
				if(!BP)
					continue
				if(BP.skeletonized)
					continue
				var/obj/item/natural/worms/leech/I = new(C)
				BP.add_embedded_object(I, silent = TRUE)
				return .

/turf/open/water/swamp/deep
	name = "murk"
	desc = "Deep water with several weeds and algae on the surface."
	icon_state = "dirtW"
	water_level = 3
	water_color = "#705a43"
	slowdown = 5
	swim_skill = TRUE

/turf/open/water/swamp/deep/Entered(atom/movable/AM, atom/oldLoc)
	. = ..()
	if(isliving(AM) && !AM.throwing)
		if(ishuman(AM))
			var/mob/living/carbon/human/C = AM
			var/chance = 6
			if(C.m_intent == MOVE_INTENT_RUN)
				chance = 12		//yikes
			if(C.m_intent == MOVE_INTENT_SNEAK)
				chance = 2
			if(!prob(chance))
				return
			if(C.blood_volume <= 0)
				return
			var/list/zonee = list(BODY_ZONE_CHEST,BODY_ZONE_R_LEG,BODY_ZONE_L_LEG,BODY_ZONE_R_ARM,BODY_ZONE_L_ARM)
			for(var/i = 0, i <= zonee.len, i++)
				var/zone = pick(zonee)
				var/obj/item/bodypart/BP = C.get_bodypart(zone)
				if(!BP)
					continue
				if(BP.skeletonized)
					continue
				var/obj/item/natural/worms/leech/I = new(C)
				BP.add_embedded_object(I, silent = TRUE)
				return .

/turf/open/water/cleanshallow
	name = "water"
	desc = "Clear and shallow water, what a blessing!"
	icon = 'icons/turf/roguefloor.dmi'
	icon_state = "rockw2"
	water_level = 2
	slowdown = 3
	wash_in = TRUE
	water_reagent = /datum/reagent/water
	clearwater = TRUE

/turf/open/water/cleanshallow/Initialize()
	icon_state = "rock"
	dir = pick(GLOB.cardinals)
	.  = ..()

/turf/open/water/river
	name = "river"
	desc = "Crystal clear water! Flowing swiflty along the river."
	icon = 'icons/turf/roguefloor.dmi'
	icon_state = "rivermove"
	water_level = 3
	slowdown = 5
	wash_in = TRUE
	swim_skill = TRUE
	var/river_processing
	swimdir = TRUE

/turf/open/water/river/update_icon()
	if(water_overlay)
		water_overlay.color = water_color
		water_overlay.icon_state = "riverbot"
		water_overlay.dir = dir
	if(water_top_overlay)
		water_top_overlay.color = water_color
		water_top_overlay.icon_state = "rivertop"
		water_top_overlay.dir = dir

/turf/open/water/river/Initialize()
	icon_state = "rock"
	.  = ..()

/turf/open/water/river/Entered(atom/movable/AM, atom/oldLoc)
	. = ..()
	if(isliving(AM))
		if(!river_processing)
			river_processing = addtimer(CALLBACK(src, PROC_REF(process_river)), 5, TIMER_STOPPABLE)

/turf/open/water/river/get_heuristic_slowdown(mob/traverser, travel_dir)
	var/const/UPSTREAM_PENALTY = 2
	var/const/DOWNSTREAM_BONUS = -2
	. = ..()
	if(traverser.is_floor_hazard_immune())
		return
	for(var/obj/structure/S in src)
		if(S.obj_flags & BLOCK_Z_OUT_DOWN)
			return
	if(travel_dir == dir) // downriver
		. += DOWNSTREAM_BONUS // faster!
	else if(travel_dir == GLOB.reverse_dir[dir]) // upriver
		. += UPSTREAM_PENALTY // slower

/turf/open/water/river/proc/process_river()
	river_processing = null
	for(var/atom/movable/A in contents)
		for(var/obj/structure/S in src)
			if(S.obj_flags & BLOCK_Z_OUT_DOWN)
				return
		if((A.loc == src) && A.has_gravity())
			A.ConveyorMove(dir)

/turf/open/water/ocean
	name = "salt water"
	desc = "The waves lap at the coast, hungry to swallow the land. Doesn't look too deep."
	icon_state = "ash"
	icon = 'icons/turf/roguefloor.dmi'
	water_level = 2
	water_color = "#3e7459"
	slowdown = 4
	swim_skill = TRUE
	wash_in = TRUE
	water_reagent = /datum/reagent/water/salty
	clearwater = TRUE

/turf/open/water/ocean/deep
	name = "salt water"
	desc = "Deceptively deep, be careful not to find yourself this far out."
	icon_state = "water"
	icon = 'icons/turf/roguefloor.dmi'
	water_level = 3
	water_color = "#3e7459"
	slowdown = 8
	swim_skill = TRUE
	wash_in = TRUE

/turf/open/water/pond
	name = "pond"
	desc = "Still and idyllic water that flows through meadows."
	icon_state = "pond"
	icon = 'icons/turf/roguefloor.dmi'
	water_level = 3
	water_color = "#367e94"
	slowdown = 3
	swim_skill = TRUE
	wash_in = TRUE
	water_reagent = /datum/reagent/water
	clearwater = TRUE

/turf/open/water/MiddleClick(mob/user)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		return
	if(!clearwater)
		return

	var/mob/living/carbon/human/H = user
	
	if(!HAS_TRAIT(H, TRAIT_MIRROR_MAGIC))
		to_chat(H, span_warning("You look into the still water but see only your normal reflection."))
		return

	var/should_update = FALSE
	var/list/choices = list("hairstyle", "facial hairstyle", "accessory", "face detail", "tail", "tail color one", "tail color two", "hair color", "facial hair color", "eye color", "natural gradient", "natural gradient color", "dye gradient", "dye gradient color", "penis", "testicles", "breasts", "vagina", "breast size", "penis size", "testicle size")
	var/chosen = input(user, "Change what?", "Appearance") as null|anything in choices
	
	if(!chosen)
		return
		
	switch(chosen)
		if("hairstyle")
			var/datum/customizer_choice/bodypart_feature/hair/head/humanoid/hair_choice = CUSTOMIZER_CHOICE(/datum/customizer_choice/bodypart_feature/hair/head/humanoid)
			var/list/valid_hairstyles = list()
			for(var/hair_type in hair_choice.sprite_accessories)
				var/datum/sprite_accessory/hair/head/hair = new hair_type()
				valid_hairstyles[hair.name] = hair_type
			
			var/new_style = input(user, "Choose your hairstyle", "Hair Styling") as null|anything in valid_hairstyles
			if(new_style)
				var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
				if(head && head.bodypart_features)
					var/datum/bodypart_feature/hair/head/current_hair = null
					for(var/datum/bodypart_feature/hair/head/hair_feature in head.bodypart_features)
						current_hair = hair_feature
						break
					
					if(current_hair)
						var/datum/customizer_entry/hair/hair_entry = new()
						hair_entry.hair_color = current_hair.hair_color
						
						if(istype(current_hair, /datum/bodypart_feature/hair/head))
							hair_entry.natural_gradient = current_hair.natural_gradient
							hair_entry.natural_color = current_hair.natural_color
							if(hasvar(current_hair, "hair_dye_gradient"))
								hair_entry.dye_gradient = current_hair.hair_dye_gradient
							if(hasvar(current_hair, "hair_dye_color"))
								hair_entry.dye_color = current_hair.hair_dye_color
						
						var/datum/bodypart_feature/hair/head/new_hair = new()
						new_hair.set_accessory_type(valid_hairstyles[new_style], hair_entry.hair_color, H)
						
						hair_choice.customize_feature(new_hair, H, null, hair_entry)
						
						head.remove_bodypart_feature(current_hair)
						head.add_bodypart_feature(new_hair)
						H.update_hair()
						should_update = TRUE

		if("hair color")
			var/new_hair_color = color_pick_sanitized_lumi(user, "Choose your hair color", "Hair Color", H.hair_color)
			if(new_hair_color)
				var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
				if(head && head.bodypart_features)
					var/datum/customizer_choice/bodypart_feature/hair/head/humanoid/hair_choice = CUSTOMIZER_CHOICE(/datum/customizer_choice/bodypart_feature/hair/head/humanoid)
					
					var/datum/customizer_entry/hair/hair_entry = new()
					hair_entry.hair_color = sanitize_hexcolor(new_hair_color, 6, TRUE)
					
					var/datum/bodypart_feature/hair/head/current_hair = null
					for(var/datum/bodypart_feature/hair/head/hair_feature in head.bodypart_features)
						current_hair = hair_feature
						break
					
					if(current_hair)
						var/datum/bodypart_feature/hair/head/new_hair = new()
						
						new_hair.set_accessory_type(current_hair.accessory_type, null, H)
						
						hair_choice.customize_feature(new_hair, H, null, hair_entry)
						
						H.hair_color = hair_entry.hair_color
						H.dna.update_ui_block(DNA_HAIR_COLOR_BLOCK)
						
						head.remove_bodypart_feature(current_hair)
						head.add_bodypart_feature(new_hair)
						
						H.dna.species.handle_body(H)
						H.update_body()
						H.update_hair()
						H.update_body_parts()
						should_update = TRUE

		if("facial hair color")
			var/new_facial_hair_color = color_pick_sanitized_lumi(user, "Choose your facial hair color", "Facial Hair Color", H.facial_hair_color)
			if(new_facial_hair_color)
				var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
				if(head && head.bodypart_features)
					var/datum/customizer_choice/bodypart_feature/hair/facial/humanoid/facial_choice = CUSTOMIZER_CHOICE(/datum/customizer_choice/bodypart_feature/hair/facial/humanoid)
					
					var/datum/customizer_entry/hair/facial/facial_entry = new()
					
					var/datum/bodypart_feature/hair/facial/current_facial = null
					for(var/datum/bodypart_feature/hair/facial/facial_feature in head.bodypart_features)
						current_facial = facial_feature
						break
					
					if(current_facial)
						facial_entry.hair_color = sanitize_hexcolor(new_facial_hair_color, 6, TRUE)
						facial_entry.accessory_type = current_facial.accessory_type
						
						var/datum/bodypart_feature/hair/facial/new_facial = new()
						new_facial.set_accessory_type(current_facial.accessory_type, null, H)
						facial_choice.customize_feature(new_facial, H, null, facial_entry)
						
						H.facial_hair_color = facial_entry.hair_color
						H.dna.update_ui_block(DNA_FACIAL_HAIR_COLOR_BLOCK)
						head.remove_bodypart_feature(current_facial)
						head.add_bodypart_feature(new_facial)
						should_update = TRUE

		if("eye color")
			var/new_eye_color = color_pick_sanitized_lumi(user, "Choose your eye color", "Eye Color", H.eye_color)
			if(new_eye_color)
				new_eye_color = sanitize_hexcolor(new_eye_color, 6, TRUE)
				var/obj/item/organ/eyes/eyes = H.getorganslot(ORGAN_SLOT_EYES)
				if(eyes)
					eyes.Remove(H)
					eyes.eye_color = new_eye_color
					eyes.Insert(H, TRUE, FALSE)
				H.eye_color = new_eye_color
				H.dna.features["eye_color"] = new_eye_color
				H.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
				H.update_body_parts()
				should_update = TRUE

		if("natural gradient")
			var/datum/customizer_choice/bodypart_feature/hair/head/humanoid/hair_choice = CUSTOMIZER_CHOICE(/datum/customizer_choice/bodypart_feature/hair/head/humanoid)
			var/list/valid_gradients = list()
			for(var/gradient_type in GLOB.hair_gradients)
				valid_gradients[gradient_type] = gradient_type
			
			var/new_style = input(user, "Choose your natural gradient", "Hair Gradient") as null|anything in valid_gradients
			if(new_style)
				var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
				if(head && head.bodypart_features)
					var/datum/bodypart_feature/hair/head/current_hair = null
					for(var/datum/bodypart_feature/hair/head/hair_feature in head.bodypart_features)
						current_hair = hair_feature
						break
					
					if(current_hair)
						var/datum/customizer_entry/hair/hair_entry = new()
						hair_entry.hair_color = current_hair.hair_color
						hair_entry.natural_gradient = valid_gradients[new_style]
						hair_entry.natural_color = current_hair.natural_color
						hair_entry.dye_gradient = current_hair.hair_dye_gradient
						hair_entry.dye_color = current_hair.hair_dye_color
						hair_entry.accessory_type = current_hair.accessory_type
						
						var/datum/bodypart_feature/hair/head/new_hair = new()
						new_hair.set_accessory_type(current_hair.accessory_type, null, H)
						hair_choice.customize_feature(new_hair, H, null, hair_entry)
						
						head.remove_bodypart_feature(current_hair)
						head.add_bodypart_feature(new_hair)
						should_update = TRUE

		if("natural gradient color")
			var/new_gradient_color = color_pick_sanitized_lumi(user, "Choose your natural gradient color", "Natural Gradient Color", H.hair_color)
			if(new_gradient_color)
				var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
				if(head && head.bodypart_features)
					var/datum/customizer_choice/bodypart_feature/hair/head/humanoid/hair_choice = CUSTOMIZER_CHOICE(/datum/customizer_choice/bodypart_feature/hair/head/humanoid)
					
					var/datum/customizer_entry/hair/hair_entry = new()
					
					var/datum/bodypart_feature/hair/head/current_hair = null
					for(var/datum/bodypart_feature/hair/head/hair_feature in head.bodypart_features)
						current_hair = hair_feature
						break
					
					if(current_hair)
						hair_entry.hair_color = current_hair.hair_color
						hair_entry.natural_gradient = current_hair.natural_gradient
						hair_entry.natural_color = sanitize_hexcolor(new_gradient_color, 6, TRUE)
						hair_entry.dye_gradient = current_hair.hair_dye_gradient
						hair_entry.dye_color = current_hair.hair_dye_color
						hair_entry.accessory_type = current_hair.accessory_type
						
						var/datum/bodypart_feature/hair/head/new_hair = new()
						new_hair.set_accessory_type(current_hair.accessory_type, null, H)
						hair_choice.customize_feature(new_hair, H, null, hair_entry)
						
						head.remove_bodypart_feature(current_hair)
						head.add_bodypart_feature(new_hair)
						should_update = TRUE

		if("dye gradient")
			var/datum/customizer_choice/bodypart_feature/hair/head/humanoid/hair_choice = CUSTOMIZER_CHOICE(/datum/customizer_choice/bodypart_feature/hair/head/humanoid)
			var/list/valid_gradients = list()
			for(var/gradient_type in GLOB.hair_gradients)
				valid_gradients[gradient_type] = gradient_type
			
			var/new_style = input(user, "Choose your dye gradient", "Hair Gradient") as null|anything in valid_gradients
			if(new_style)
				var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
				if(head && head.bodypart_features)
					var/datum/bodypart_feature/hair/head/current_hair = null
					for(var/datum/bodypart_feature/hair/head/hair_feature in head.bodypart_features)
						current_hair = hair_feature
						break
					
					if(current_hair)
						var/datum/customizer_entry/hair/hair_entry = new()
						hair_entry.hair_color = current_hair.hair_color
						hair_entry.natural_gradient = current_hair.natural_gradient
						hair_entry.natural_color = current_hair.natural_color
						hair_entry.dye_gradient = valid_gradients[new_style]
						hair_entry.dye_color = current_hair.hair_dye_color
						hair_entry.accessory_type = current_hair.accessory_type
						
						var/datum/bodypart_feature/hair/head/new_hair = new()
						new_hair.set_accessory_type(current_hair.accessory_type, null, H)
						hair_choice.customize_feature(new_hair, H, null, hair_entry)
						
						head.remove_bodypart_feature(current_hair)
						head.add_bodypart_feature(new_hair)
						should_update = TRUE

		if("dye gradient color")
			var/new_gradient_color = color_pick_sanitized_lumi(user, "Choose your dye gradient color", "Dye Gradient Color", H.hair_color)
			if(new_gradient_color)
				var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
				if(head && head.bodypart_features)
					var/datum/customizer_choice/bodypart_feature/hair/head/humanoid/hair_choice = CUSTOMIZER_CHOICE(/datum/customizer_choice/bodypart_feature/hair/head/humanoid)
					
					var/datum/customizer_entry/hair/hair_entry = new()
					
					var/datum/bodypart_feature/hair/head/current_hair = null
					for(var/datum/bodypart_feature/hair/head/hair_feature in head.bodypart_features)
						current_hair = hair_feature
						break
					
					if(current_hair)
						hair_entry.hair_color = current_hair.hair_color
						hair_entry.natural_gradient = current_hair.natural_gradient
						hair_entry.natural_color = current_hair.natural_color
						hair_entry.dye_gradient = current_hair.hair_dye_gradient
						hair_entry.dye_color = sanitize_hexcolor(new_gradient_color, 6, TRUE)
						hair_entry.accessory_type = current_hair.accessory_type
						
						var/datum/bodypart_feature/hair/head/new_hair = new()
						new_hair.set_accessory_type(current_hair.accessory_type, null, H)
						hair_choice.customize_feature(new_hair, H, null, hair_entry)
						
						head.remove_bodypart_feature(current_hair)
						head.add_bodypart_feature(new_hair)
						should_update = TRUE

		if("facial hairstyle")
			var/datum/customizer_choice/bodypart_feature/hair/facial/humanoid/facial_choice = CUSTOMIZER_CHOICE(/datum/customizer_choice/bodypart_feature/hair/facial/humanoid)
			var/list/valid_facial_hairstyles = list()
			for(var/facial_type in facial_choice.sprite_accessories)
				var/datum/sprite_accessory/hair/facial/facial = new facial_type()
				valid_facial_hairstyles[facial.name] = facial_type
			
			var/new_style = input(user, "Choose your facial hairstyle", "Hair Styling") as null|anything in valid_facial_hairstyles
			if(new_style)
				var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
				if(head && head.bodypart_features)
					var/datum/bodypart_feature/hair/facial/current_facial = null
					for(var/datum/bodypart_feature/hair/facial/facial_feature in head.bodypart_features)
						current_facial = facial_feature
						break
					
					if(current_facial)
						// Create a new facial hair entry with the SAME color as the current facial hair
						var/datum/customizer_entry/hair/facial/facial_entry = new()
						facial_entry.hair_color = current_facial.hair_color
						
						// Create the new facial hair with the new style but preserve color
						var/datum/bodypart_feature/hair/facial/new_facial = new()
						new_facial.set_accessory_type(valid_facial_hairstyles[new_style], facial_entry.hair_color, H)
						
						// Apply all the color data from the entry
						facial_choice.customize_feature(new_facial, H, null, facial_entry)
						
						head.remove_bodypart_feature(current_facial)
						head.add_bodypart_feature(new_facial)
						H.update_hair()
						should_update = TRUE

		if("accessory")
			var/datum/customizer_choice/bodypart_feature/accessory/accessory_choice = CUSTOMIZER_CHOICE(/datum/customizer_choice/bodypart_feature/accessory)
			var/list/valid_accessories = list("none")
			for(var/accessory_type in accessory_choice.sprite_accessories)
				var/datum/sprite_accessory/accessory/acc = new accessory_type()
				valid_accessories[acc.name] = accessory_type
			
			var/new_style = input(user, "Choose your accessory", "Accessory Styling") as null|anything in valid_accessories
			if(new_style)
				var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
				if(head && head.bodypart_features)
					// Remove existing accessory if any
					for(var/datum/bodypart_feature/accessory/old_acc in head.bodypart_features)
						head.remove_bodypart_feature(old_acc)
						break
					
					// Add new accessory if not "none"
					if(new_style != "none")
						var/datum/bodypart_feature/accessory/accessory_feature = new()
						accessory_feature.set_accessory_type(valid_accessories[new_style], H.hair_color, H)
						head.add_bodypart_feature(accessory_feature)
					should_update = TRUE

		if("face detail")
			var/datum/customizer_choice/bodypart_feature/face_detail/face_choice = CUSTOMIZER_CHOICE(/datum/customizer_choice/bodypart_feature/face_detail)
			var/list/valid_details = list("none")
			for(var/detail_type in face_choice.sprite_accessories)
				var/datum/sprite_accessory/face_detail/detail = new detail_type()
				valid_details[detail.name] = detail_type
			
			var/new_detail = input(user, "Choose your face detail", "Face Detail") as null|anything in valid_details
			if(new_detail)
				var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
				if(head && head.bodypart_features)
					// Remove existing face detail if any
					for(var/datum/bodypart_feature/face_detail/old_detail in head.bodypart_features)
						head.remove_bodypart_feature(old_detail)
						break
					
					// Add new face detail if not "none"
					if(new_detail != "none")
						var/datum/bodypart_feature/face_detail/detail_feature = new()
						detail_feature.set_accessory_type(valid_details[new_detail], H.hair_color, H)
						head.add_bodypart_feature(detail_feature)
					should_update = TRUE

		if("penis")
			var/list/valid_penis_types = list("none")
			for(var/penis_path in subtypesof(/datum/sprite_accessory/penis))
				var/datum/sprite_accessory/penis/penis = new penis_path()
				valid_penis_types[penis.name] = penis_path
			
			var/new_style = input(user, "Choose your penis type", "Penis Customization") as null|anything in valid_penis_types
			if(new_style)
				if(new_style == "none")
					var/obj/item/organ/penis/penis = H.getorganslot(ORGAN_SLOT_PENIS)
					if(penis)
						penis.Remove(H)
						qdel(penis)
						H.update_body()
						should_update = TRUE
				else
					var/obj/item/organ/penis/penis = H.getorganslot(ORGAN_SLOT_PENIS)
					if(!penis)
						penis = new()
						penis.Insert(H, TRUE, FALSE)
					penis.accessory_type = valid_penis_types[new_style]
					penis.color = H.dna.features["mcolor"]
					H.update_body()
					should_update = TRUE

		if("testicles")
			var/list/valid_testicle_types = list("none")
			for(var/testicle_path in subtypesof(/datum/sprite_accessory/testicles))
				var/datum/sprite_accessory/testicles/testicles = new testicle_path()
				valid_testicle_types[testicles.name] = testicle_path
			
			var/new_style = input(user, "Choose your testicles type", "Testicles Customization") as null|anything in valid_testicle_types
			if(new_style)
				if(new_style == "none")
					var/obj/item/organ/testicles/testicles = H.getorganslot(ORGAN_SLOT_TESTICLES)
					if(testicles)
						testicles.Remove(H)
						qdel(testicles)
						H.update_body()
						should_update = TRUE
				else
					var/obj/item/organ/testicles/testicles = H.getorganslot(ORGAN_SLOT_TESTICLES)
					if(!testicles)
						testicles = new()
						testicles.Insert(H, TRUE, FALSE)
					testicles.accessory_type = valid_testicle_types[new_style]
					testicles.color = H.dna.features["mcolor"]
					H.update_body()
					should_update = TRUE

		if("breasts")
			var/list/valid_breast_types = list("none")
			for(var/breast_path in subtypesof(/datum/sprite_accessory/breasts))
				var/datum/sprite_accessory/breasts/breasts = new breast_path()
				valid_breast_types[breasts.name] = breast_path
			
			var/new_style = input(user, "Choose your breast type", "Breast Customization") as null|anything in valid_breast_types

			if(new_style)
				if(new_style == "none")
					var/obj/item/organ/breasts/breasts = H.getorganslot(ORGAN_SLOT_BREASTS)
					if(breasts)
						breasts.Remove(H)
						qdel(breasts)
						H.update_body()
						should_update = TRUE
				else
					var/obj/item/organ/breasts/breasts = H.getorganslot(ORGAN_SLOT_BREASTS)
					if(!breasts)
						breasts = new()
						breasts.Insert(H, TRUE, FALSE)
					
					breasts.accessory_type = valid_breast_types[new_style]
					breasts.color = H.dna.features["mcolor"]
					H.update_body()
					should_update = TRUE

		if("vagina")
			var/list/valid_vagina_types = list("none", "human", "hairy", "spade", "furred", "gaping", "cloaca")
			var/new_style = input(user, "Choose your vagina type", "Vagina Customization") as null|anything in valid_vagina_types

			if(new_style)
				if(new_style == "none")
					var/obj/item/organ/vagina/vagina = H.getorganslot(ORGAN_SLOT_VAGINA)
					if(vagina)
						vagina.Remove(H)
						qdel(vagina)
						H.update_body()
						should_update = TRUE
				else
					var/obj/item/organ/vagina/vagina = H.getorganslot(ORGAN_SLOT_VAGINA)
					if(!vagina)
						vagina = new()
						vagina.Insert(H, TRUE, FALSE)
					vagina.accessory_type = valid_vagina_types[new_style]
					
					var/new_color = color_pick_sanitized_lumi(user, "Choose your vagina color", "Vagina Color", vagina.color || H.dna.features["mcolor"])
					if(new_color)
						vagina.color = sanitize_hexcolor(new_color, 6, TRUE)
					else
						vagina.color = H.dna.features["mcolor"]
						
					H.update_body()
					should_update = TRUE

		if("breast size")
			var/list/breast_sizes = list("flat", "very small", "small", "average", "large", "enormous")
			var/new_size = input(user, "Choose your breast size", "Breast Size") as null|anything in breast_sizes
			if(new_size)
				var/obj/item/organ/breasts/breasts = H.getorganslot(ORGAN_SLOT_BREASTS)
				if(breasts)
					var/size_num
					switch(new_size)
						if("flat")
							size_num = 0
						if("very small")
							size_num = 1
						if("small")
							size_num = 2
						if("average")
							size_num = 3
						if("large")
							size_num = 4
						if("enormous")
							size_num = 5
					
					breasts.breast_size = size_num
					H.update_body()
					should_update = TRUE

		if("penis size")
			var/list/penis_sizes = list("small", "average", "large")
			var/new_size = input(user, "Choose your penis size", "Penis Size") as null|anything in penis_sizes
			if(new_size)
				var/obj/item/organ/penis/penis = H.getorganslot(ORGAN_SLOT_PENIS)
				if(penis)
					var/size_num
					switch(new_size)
						if("small")
							size_num = 1
						if("average")
							size_num = 2
						if("large")
							size_num = 3
					
					penis.penis_size = size_num
					H.update_body()
					should_update = TRUE

		if("testicle size")
			var/list/testicle_sizes = list("small", "average", "large")
			var/new_size = input(user, "Choose your testicle size", "Testicle Size") as null|anything in testicle_sizes
			if(new_size)
				var/obj/item/organ/testicles/testicles = H.getorganslot(ORGAN_SLOT_TESTICLES)
				if(testicles)
					var/size_num
					switch(new_size)
						if("small")
							size_num = 1
						if("average")
							size_num = 2
						if("large")
							size_num = 3
					
					testicles.ball_size = size_num
					H.update_body()
					should_update = TRUE

		if("tail")
			var/list/valid_tails = list("none")
			for(var/tail_path in subtypesof(/datum/sprite_accessory/tail))
				var/datum/sprite_accessory/tail/tail = new tail_path()
				valid_tails[tail.name] = tail_path
			
			var/new_style = input(user, "Choose your tail", "Tail Customization") as null|anything in valid_tails
			if(new_style)
				if(new_style == "none")
					var/obj/item/organ/tail/tail = H.getorganslot(ORGAN_SLOT_TAIL)
					if(tail)
						tail.Remove(H)
						qdel(tail)
						H.update_body()
						should_update = TRUE
				else
					var/obj/item/organ/tail/tail = H.getorganslot(ORGAN_SLOT_TAIL)
					if(!tail)
						tail = new /obj/item/organ/tail/anthro()
						tail.Insert(H, TRUE, FALSE)
					tail.accessory_type = valid_tails[new_style]
					var/datum/sprite_accessory/tail/tail_type = SPRITE_ACCESSORY(tail.accessory_type)
					tail.accessory_colors = tail_type.get_default_colors(list())
					H.update_body()
					should_update = TRUE

		if("tail color one")
			var/obj/item/organ/tail/tail = H.getorganslot(ORGAN_SLOT_TAIL)
			if(tail)
				var/new_color = color_pick_sanitized_lumi(user, "Choose your primary tail color", "Tail Color One", "#FFFFFF")
				if(new_color)
					tail.Remove(H)
					var/list/colors = list()
					if(tail.accessory_colors)
						colors = color_string_to_list(tail.accessory_colors)
					if(!length(colors))
						colors = list("#FFFFFF", "#FFFFFF") // Default colors if none set
					colors[1] = sanitize_hexcolor(new_color, 6, TRUE)
					tail.accessory_colors = color_list_to_string(colors)
					tail.Insert(H, TRUE, FALSE)
					H.dna.features["tail_color"] = colors[1]  // Update DNA features
					H.update_body()
					should_update = TRUE
			else
				to_chat(user, span_warning("You don't have a tail!"))

		if("tail color two")
			var/obj/item/organ/tail/tail = H.getorganslot(ORGAN_SLOT_TAIL)
			if(tail)
				var/new_color = color_pick_sanitized_lumi(user, "Choose your secondary tail color", "Tail Color Two", "#FFFFFF")
				if(new_color)
					tail.Remove(H)
					var/list/colors = list()
					if(tail.accessory_colors)
						colors = color_string_to_list(tail.accessory_colors)
					if(!length(colors))
						colors = list("#FFFFFF", "#FFFFFF") // Default colors if none set
					colors[2] = sanitize_hexcolor(new_color, 6, TRUE)
					tail.accessory_colors = color_list_to_string(colors)
					tail.Insert(H, TRUE, FALSE)
					H.dna.features["tail_color2"] = colors[2]  // Update DNA features
					H.update_body()
					should_update = TRUE
			else
				to_chat(user, span_warning("You don't have a tail!"))

	if(should_update)
		H.update_hair()
		H.update_body()
		H.update_body_parts()


