/obj/item/slime_extract
	/// Remembers chemical use or enhancement even after reagents are emptied or uses are restored.
	var/extract_modified = FALSE
	/// A core taken out for use stays separate until moved away from this turf.
	var/turf/extract_pile_excluded_turf

/obj/item/slime_extract/proc/initialize_extract_piling()
	RegisterSignals(reagents, list(COMSIG_REAGENTS_HOLDER_UPDATED, COMSIG_REAGENTS_TEMP_CHANGE), PROC_REF(mark_extract_modified))
	RegisterSignal(src, COMSIG_MOVABLE_THROW_LANDED, PROC_REF(queue_extract_piling))
	queue_extract_piling()

/obj/item/slime_extract/Moved()
	. = ..()
	if(loc != extract_pile_excluded_turf)
		extract_pile_excluded_turf = null
	if(flags_1 & INITIALIZED_1)
		queue_extract_piling()

/obj/item/slime_extract/proc/mark_extract_modified()
	SIGNAL_HANDLER
	if(QDELETED(src))
		return
	extract_modified = TRUE
	if(istype(loc, /obj/structure/slime_extract_pile))
		forceMove(drop_location())

/// Do not let factory-created recurring/cloned extracts pile before their creator finishes configuring them.
/obj/item/slime_extract/proc/queue_extract_piling()
	SIGNAL_HANDLER
	if(isturf(loc) && loc != extract_pile_excluded_turf && !extract_modified)
		addtimer(CALLBACK(src, PROC_REF(try_extract_piling)), 0, TIMER_UNIQUE)

/// Only extract chemistry and use state affect eligibility; stored items retain their health and appearance.
/obj/item/slime_extract/proc/is_stackable_extract()
	if(QDELETED(src) || extract_modified || recurring || qdel_timer || length(contents))
		return FALSE
	if(extract_uses != initial(extract_uses) || crossbreed_modification != initial(crossbreed_modification))
		return FALSE
	return reagents && !reagents.total_volume && !length(reagents.reagent_list) && !reagents.is_reacting

/obj/item/slime_extract/bluespace/is_stackable_extract()
	return ..() && !teleport_ready && !teleport_x && !teleport_y && !teleport_z

/// Only scan when a core arrives on a turf, never periodically or for cores already stored in a pile.
/obj/item/slime_extract/proc/try_extract_piling()
	if(!isturf(loc) || loc == extract_pile_excluded_turf || throwing || !is_stackable_extract())
		return
	var/turf/floor = loc
	var/obj/structure/slime_extract_pile/pile
	for(var/obj/structure/slime_extract_pile/candidate in floor)
		if(!QDELETED(candidate) && candidate.extract_type == type)
			pile = candidate
			break
	if(pile)
		pile.add_extract(src)
		return

	for(var/obj/item/slime_extract/other in floor)
		if(other == src || other.type != type || other.throwing || other.extract_pile_excluded_turf == floor || !other.is_stackable_extract())
			continue
		pile = new(floor, type)
		pile.add_extract(src)
		pile.add_extract(other)
		break
	if(!pile)
		return
	for(var/obj/item/slime_extract/other in floor)
		if(other.type == type && !other.throwing && other.extract_pile_excluded_turf != floor)
			pile.add_extract(other)

/// A floor-only collection: its contents remain real items, but only one core sprite and a count are displayed.
/obj/structure/slime_extract_pile
	name = "slime extract pile"
	desc = "A pile of unused slime extracts."
	icon = 'icons/mob/simple/slimes.dmi'
	icon_state = "grey-core"
	layer = OBJ_LAYER
	anchored = TRUE
	density = FALSE
	max_integrity = 20
	flags_ricochet = NONE
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND
	/// Piles are homogeneous by exact type, not just their visible colour.
	var/obj/item/slime_extract/extract_type = /obj/item/slime_extract/grey

/obj/structure/slime_extract_pile/Initialize(mapload, obj/item/slime_extract/core_type)
	. = ..()
	if(core_type)
		extract_type = core_type
	icon = initial(extract_type.icon)
	icon_state = initial(extract_type.icon_state)
	name = "[initial(extract_type.name)] pile"
	update_appearance()
	queue_pile_update()

/obj/structure/slime_extract_pile/atom_deconstruct(disassembled = TRUE)
	// Breaking the pile scatters its stock. Direct deletion still cleans up its contents normally.
	var/turf/floor = get_turf(src)
	if(floor)
		for(var/obj/item/slime_extract/core in contents)
			core.extract_pile_excluded_turf = floor
			core.forceMove(floor)
	return ..()

/obj/structure/slime_extract_pile/Exited(atom/movable/gone, direction)
	. = ..()
	if(!QDELETED(src))
		queue_pile_update()

/obj/structure/slime_extract_pile/proc/queue_pile_update()
	addtimer(CALLBACK(src, PROC_REF(update_pile)), 0, TIMER_UNIQUE)

/obj/structure/slime_extract_pile/proc/update_pile()
	if(length(contents) < 2)
		// The last untouched core can join future arrivals; only deliberately removed cores stay separate.
		for(var/obj/item/slime_extract/core in contents)
			core.forceMove(drop_location())
		qdel(src)
		return
	maptext = MAPTEXT("<span style='color: white;'>[length(contents)]</span>")

/obj/structure/slime_extract_pile/proc/add_extract(obj/item/slime_extract/core)
	if(QDELETED(src) || QDELETED(core) || core.type != extract_type || !core.is_stackable_extract())
		return FALSE
	core.forceMove(src)
	queue_pile_update()
	return TRUE

/obj/structure/slime_extract_pile/proc/take_extract(atom/destination)
	for(var/obj/item/slime_extract/core in contents)
		if(QDELETED(core))
			continue
		// Recheck on use in case code changed a stored core directly rather than through a signal.
		if(!core.is_stackable_extract())
			core.mark_extract_modified()
			continue
		if(isturf(destination))
			core.extract_pile_excluded_turf = destination
		core.forceMove(destination)
		return core

/obj/structure/slime_extract_pile/examine(mob/user)
	. = ..()
	. += span_notice("It contains [length(contents)] extracts. Take one by hand, or use a syringe on the pile to inject one.")

/obj/structure/slime_extract_pile/attack_hand(mob/living/user, list/modifiers)
	if(..())
		return TRUE
	var/obj/item/slime_extract/core = take_extract(drop_location())
	if(core)
		core.attack_hand(user, modifiers)
	return TRUE

/obj/structure/slime_extract_pile/attack_paw(mob/living/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/slime_extract_pile/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/slime_extract))
		var/obj/item/slime_extract/core = tool
		if(core.type != extract_type || !core.is_stackable_extract())
			balloon_alert(user, "only matching unused extracts!")
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(core, src))
			return ITEM_INTERACT_BLOCKING
		queue_pile_update()
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/storage/bag/xeno))
		for(var/obj/item/slime_extract/core in contents.Copy())
			if(!tool.atom_storage.attempt_insert(core, user))
				break
		return ITEM_INTERACT_SUCCESS
	var/obj/item/slime_extract/core = take_extract(drop_location())
	if(!core)
		return ITEM_INTERACT_BLOCKING
	// Run the normal interaction on one real, now loose extract, including secondary syringe drawing.
	tool.melee_attack_chain(user, core, modifiers)
	return ITEM_INTERACT_SUCCESS

/obj/structure/slime_extract_pile/fire_act(exposed_temperature, exposed_volume)
	for(var/obj/item/slime_extract/core in contents.Copy())
		core.fire_act(exposed_temperature, exposed_volume)
	return ..()

/obj/structure/slime_extract_pile/expose_reagents(list/exposed_reagents, datum/reagents/source, methods = TOUCH, volume_modifier = 1, show_message = TRUE)
	for(var/obj/item/slime_extract/core in contents.Copy())
		core.expose_reagents(exposed_reagents, source, methods, volume_modifier, show_message)
	return ..()

/obj/structure/slime_extract_pile/contents_explosion(severity, target)
	// A pile provides no blast protection to the individual extracts.
	switch(severity)
		if(EXPLODE_DEVASTATE)
			SSexplosions.high_mov_atom += contents
		if(EXPLODE_HEAVY)
			SSexplosions.med_mov_atom += contents
		if(EXPLODE_LIGHT)
			SSexplosions.low_mov_atom += contents
