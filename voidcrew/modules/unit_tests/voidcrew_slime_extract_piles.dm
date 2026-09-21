/// Every ordinary colour auto-piles by exact type, including extracts created together by a factory.
/datum/unit_test/voidcrew_slime_extract_piles_auto/Run()
	var/turf/floor = run_loc_floor_bottom_left
	var/list/colours = subtypesof(/obj/item/slime_extract)
	for(var/core_type in colours)
		for(var/index in 1 to 3)
			allocate(core_type, floor)
		var/obj/item/slime_extract/modified = allocate(core_type, floor)
		modified.recurring = TRUE // Set after Initialize, as recurring extracts do.
	sleep(1 SECONDS)
	var/piles = 0
	var/loose = 0
	for(var/obj/structure/slime_extract_pile/pile in floor)
		piles++
		TEST_ASSERT_EQUAL(length(pile.contents), 3, "Wrong pile size for [pile.extract_type]")
		TEST_ASSERT(!isitem(pile), "A pile must not be a carryable item")
		TEST_ASSERT_EQUAL(length(pile.overlays), 1, "A pile should only have its normal emissive blocker, not an overlay per core")
		TEST_ASSERT_EQUAL(length(pile.vis_contents), 0, "Piles must not display their individual contents")
		for(var/obj/item/slime_extract/core in pile)
			TEST_ASSERT_EQUAL(core.type, pile.extract_type, "Mixed colours entered one pile")
			TEST_ASSERT(core.is_stackable_extract(), "A modified core entered a pile")
	for(var/obj/item/slime_extract/core in floor)
		loose++
		TEST_ASSERT(core.recurring, "A fresh core failed to auto-pile")
	TEST_ASSERT_EQUAL(piles, length(colours), "Not every extract colour formed its own pile")
	TEST_ASSERT_EQUAL(loose, length(colours), "Factory-modified extracts should stay loose")

/// Reverting a chemical or enhancement does not make an extract fresh again.
/datum/unit_test/voidcrew_slime_extract_piles_freshness/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)
	var/obj/structure/slime_extract_pile/pile = allocate(/obj/structure/slime_extract_pile)
	var/obj/item/slime_extract/grey/core = allocate(/obj/item/slime_extract/grey, user)
	TEST_ASSERT(core.is_stackable_extract(), "A new grey extract was not pristine")
	core.reagents.add_reagent(/datum/reagent/consumable/sugar, 5)
	core.reagents.clear_reagents()
	TEST_ASSERT(!core.is_stackable_extract(), "An injected and emptied extract became pristine again")
	TEST_ASSERT(!pile.add_extract(core), "An injected and emptied extract entered a pile")
	user.put_in_active_hand(core)
	core.melee_attack_chain(user, pile, list())
	TEST_ASSERT_EQUAL(core, user.get_active_held_item(), "Manually inserting a modified core removed it from the hand")
	TEST_ASSERT_EQUAL(length(pile.contents), 0, "Manual insertion bypassed the freshness check")
	user.temporarilyRemoveItemFromInventory(core)

	core = allocate(/obj/item/slime_extract/grey, user)
	core.extract_uses = 0
	TEST_ASSERT(!pile.add_extract(core), "A spent extract entered a pile")
	core = allocate(/obj/item/slime_extract/grey, user)
	var/obj/item/slimepotion/enhancer/enhancer = allocate(/obj/item/slimepotion/enhancer, user)
	core.attackby(enhancer, user)
	TEST_ASSERT_EQUAL(core.extract_uses, 2, "Enhancer did not actually enhance the extract")
	TEST_ASSERT(!pile.add_extract(core), "An enhanced extract entered a pile")
	core.extract_uses = 1
	TEST_ASSERT(!pile.add_extract(core), "An enhanced extract with its uses restored entered a pile")

	core = allocate(/obj/item/slime_extract/grey, user)
	core.recurring = TRUE
	TEST_ASSERT(!pile.add_extract(core), "A recurring extract entered a pile")
	core = allocate(/obj/item/slime_extract/grey, user)
	core.crossbreed_modification = "burning"
	TEST_ASSERT(!pile.add_extract(core), "An extract with altered crossbreeding behaviour entered a pile")
	core = allocate(/obj/item/slime_extract/grey, user)
	core.qdel_timer = "pending reaction"
	TEST_ASSERT(!pile.add_extract(core), "An extract with a delayed reaction entered a pile")
	core = allocate(/obj/item/slime_extract/grey, user)
	allocate(/obj/item/paper, core)
	TEST_ASSERT(!pile.add_extract(core), "An extract containing another item entered a pile")
	var/obj/item/slime_extract/blue/blue = allocate(/obj/item/slime_extract/blue, user)
	TEST_ASSERT(!pile.add_extract(blue), "A different-colour extract entered a grey pile")
	var/obj/item/slime_extract/bluespace/bluespace = allocate(/obj/item/slime_extract/bluespace, user)
	bluespace.teleport_x = 1
	TEST_ASSERT(!bluespace.is_stackable_extract(), "An extract with a teleport anchor was treated as pristine")
	user.set_species(/datum/species/jelly/luminescent)
	core = allocate(/obj/item/slime_extract/grey, user)
	user.put_in_active_hand(core)
	var/datum/action/innate/integrate_extract/integrate = locate() in user.actions
	TEST_ASSERT_NOTNULL(integrate, "Luminescent test user has no extract integration action")
	integrate.Activate()
	integrate.Activate()
	TEST_ASSERT(core.is_stackable_extract(), "Integrating and ejecting an unused core changed its eligibility")

/// Cosmetic changes and physical damage survive grouping and retrieval without excluding unused cores.
/datum/unit_test/voidcrew_slime_extract_piles_cosmetic_damage/Run()
	var/turf/floor = run_loc_floor_bottom_left
	var/list/health_by_core = list()
	for(var/index in 1 to 3)
		var/obj/item/slime_extract/core = allocate(/obj/item/slime_extract/grey, floor)
		core.take_damage(index, sound_effect = FALSE)
		core.repair_damage(1)
		health_by_core[core] = core.get_integrity()
	var/obj/item/slime_extract/custom_core = health_by_core[1]
	custom_core.name = "labelled grey core"
	ADD_TRAIT(custom_core, TRAIT_HAS_LABEL, "test label")
	custom_core.add_atom_colour(COLOR_RED, FIXED_COLOUR_PRIORITY)
	var/original_colour = custom_core.color
	custom_core.transform = matrix().Scale(2)
	sleep(1 SECONDS)
	var/obj/structure/slime_extract_pile/pile = locate() in floor
	TEST_ASSERT_NOTNULL(pile, "Damage and cosmetics prevented unused cores from stacking")
	TEST_ASSERT_EQUAL(length(pile.contents), 3, "Damaged or cosmetically changed cores were excluded")
	for(var/index in 1 to 3)
		var/obj/item/slime_extract/retrieved = pile.take_extract(floor)
		TEST_ASSERT_NOTNULL(retrieved, "Could not retrieve a damaged or cosmetically changed core")
		TEST_ASSERT_EQUAL(retrieved.get_integrity(), health_by_core[retrieved], "Piling changed a core's health")
	TEST_ASSERT_EQUAL(custom_core.name, "labelled grey core", "Piling erased a core's name")
	TEST_ASSERT(HAS_TRAIT(custom_core, TRAIT_HAS_LABEL), "Piling erased a core's label")
	TEST_ASSERT_EQUAL(custom_core.color, original_colour, "Piling erased a core's colour")
	var/matrix/custom_transform = custom_core.transform
	TEST_ASSERT_EQUAL(custom_transform.a, 2, "Piling erased a core's cosmetic transform")

/// Real item interactions consume or modify exactly one core and preserve the remaining stock.
/datum/unit_test/voidcrew_slime_extract_piles_interactions/Run()
	var/turf/floor = run_loc_floor_bottom_left
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent, floor)
	for(var/index in 1 to 5)
		allocate(/obj/item/slime_extract/grey, floor)
	sleep(1 SECONDS)
	var/obj/structure/slime_extract_pile/pile = locate() in floor
	TEST_ASSERT_NOTNULL(pile, "Fresh extracts did not auto-pile")
	pile.attack_hand(user, list())
	var/obj/item/slime_extract/held_core = user.get_active_held_item()
	TEST_ASSERT(istype(held_core), "Empty-hand interaction did not take one core")
	TEST_ASSERT_EQUAL(length(pile.contents), 4, "Taking one core changed the wrong number of cores")
	held_core.melee_attack_chain(user, pile, list())
	TEST_ASSERT_EQUAL(held_core.loc, pile, "Manually returning a fresh core did not add it to the pile")
	TEST_ASSERT_NULL(user.get_active_held_item(), "Returning a core left a stale hand reference")
	pile.attack_hand(user, list())
	held_core = user.get_active_held_item()
	user.dropItemToGround(held_core)
	sleep(1 SECONDS)
	TEST_ASSERT_EQUAL(held_core.loc, pile, "Dropping an untouched core did not return it to the pile")

	var/obj/item/reagent_containers/syringe/syringe = allocate(/obj/item/reagent_containers/syringe, user)
	user.put_in_active_hand(syringe)
	syringe.reagents.add_reagent(/datum/reagent/consumable/sugar, 5)
	syringe.melee_attack_chain(user, pile, list())
	TEST_ASSERT_EQUAL(length(pile.contents), 4, "Injection should separate exactly one core")
	TEST_ASSERT_EQUAL(syringe.reagents.total_volume, 0, "The syringe did not inject the separated core")
	var/obj/item/slime_extract/injected = locate() in floor
	TEST_ASSERT_NOTNULL(injected, "The injected core was not placed on the floor")
	TEST_ASSERT_EQUAL(injected.reagents.total_volume, 5, "Injected reagents were lost")
	TEST_ASSERT(!injected.is_stackable_extract(), "Injection did not mark the core modified")
	syringe.melee_attack_chain(user, injected, list(RIGHT_CLICK = "1"))
	TEST_ASSERT_EQUAL(injected.reagents.total_volume, 0, "The injected core could not be drawn from normally")
	injected.forceMove(get_step(floor, EAST))
	injected.forceMove(floor)
	sleep(1 SECONDS)
	TEST_ASSERT_EQUAL(injected.loc, floor, "An emptied used core rejoined the pile")

	syringe.reagents.clear_reagents()
	syringe.reagents.add_reagent(/datum/reagent/blood, 5)
	syringe.melee_attack_chain(user, pile, list())
	TEST_ASSERT_EQUAL(length(pile.contents), 3, "A slime reaction consumed more than one core")
	var/obj/item/food/monkeycube/cube = locate() in floor
	TEST_ASSERT_NOTNULL(cube, "Injecting a grey pile with blood did not run its normal reaction on the floor")
	for(var/obj/item/slime_extract/core in pile)
		TEST_ASSERT(core.is_stackable_extract(), "A reaction contaminated another core in the pile")

	// Direct modification of a contained core must eject it immediately.
	var/obj/item/slime_extract/changed_in_pile = pile.contents[1]
	changed_in_pile.reagents.add_reagent(/datum/reagent/consumable/sugar, 1)
	TEST_ASSERT_EQUAL(changed_in_pile.loc, floor, "A core modified inside a pile stayed hidden")
	TEST_ASSERT_EQUAL(length(pile.contents), 2, "Ejecting a modified core lost another extract")
	var/obj/item/slime_extract/last = pile.take_extract(floor)
	TEST_ASSERT_NOTNULL(last, "Could not take a core from a two-core pile")
	sleep(1 SECONDS)
	TEST_ASSERT(QDELETED(pile), "A singleton pile should dissolve")
	TEST_ASSERT_EQUAL(last.loc, floor, "A core taken out for use auto-piled again")
	TEST_ASSERT(!QDELETED(last), "Dissolving the pile deleted a removed core")
	var/obj/item/slime_extract/new_arrival = allocate(/obj/item/slime_extract/grey, floor)
	sleep(1 SECONDS)
	pile = locate() in floor
	TEST_ASSERT_NOTNULL(pile, "The last untouched core did not auto-pile with a new arrival")
	TEST_ASSERT_EQUAL(length(pile.contents), 2, "New arrivals included deliberately separated or used cores")
	TEST_ASSERT_EQUAL(new_arrival.loc, pile, "A newly spawned core did not enter the pile")

/// Bulk collection honours bag capacity; physical destruction scatters stock, while cleanup deletes it.
/datum/unit_test/voidcrew_slime_extract_piles_storage/Run()
	var/turf/floor = run_loc_floor_bottom_left
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent, floor)
	var/list/cores = list()
	for(var/index in 1 to 30)
		cores += allocate(/obj/item/slime_extract/purple, floor)
	sleep(1 SECONDS)
	var/obj/structure/slime_extract_pile/pile = locate() in floor
	TEST_ASSERT_NOTNULL(pile, "Bulk extracts did not auto-pile")
	var/obj/item/storage/bag/xeno/bag = allocate(/obj/item/storage/bag/xeno, user)
	user.put_in_active_hand(bag)
	bag.melee_attack_chain(user, pile, list())
	TEST_ASSERT_EQUAL(length(bag.contents), bag.atom_storage.max_slots, "Bio bag collection did not honour its capacity")
	TEST_ASSERT_EQUAL(length(pile.contents), 30 - bag.atom_storage.max_slots, "Bulk collection lost extracts")
	pile.deconstruct(FALSE)
	sleep(1 SECONDS)
	for(var/obj/item/slime_extract/core as anything in cores)
		TEST_ASSERT(!QDELETED(core), "Breaking a pile deleted a stored extract")
		TEST_ASSERT(core.loc == bag || core.loc == floor, "An extract was lost when the pile was broken")
	TEST_ASSERT_NULL(locate(/obj/structure/slime_extract_pile) in floor, "A destroyed pile immediately re-formed")
	var/list/scattered = cores - bag.contents
	for(var/obj/item/slime_extract/core as anything in scattered)
		core.forceMove(get_step(floor, EAST))
		core.forceMove(floor)
	sleep(1 SECONDS)
	pile = locate() in floor
	TEST_ASSERT_NOTNULL(pile, "Moving the scattered cores did not let them form a new pile")
	qdel(pile)
	for(var/obj/item/slime_extract/core as anything in scattered)
		TEST_ASSERT(QDELETED(core), "Direct cleanup of a pile leaked a stored extract")

/// Piles must not shield their contents from hazards, and damage alone does not affect extract behaviour.
/datum/unit_test/voidcrew_slime_extract_piles_exposure/Run()
	var/turf/floor = run_loc_floor_bottom_left
	var/list/cores = list()
	for(var/index in 1 to 3)
		cores += allocate(/obj/item/slime_extract/grey, floor)
	sleep(1 SECONDS)
	var/obj/structure/slime_extract_pile/pile = locate() in floor
	TEST_ASSERT_NOTNULL(pile, "Extracts did not auto-pile before exposure")
	pile.fire_act(100, 1)
	var/list/health_by_core = list()
	for(var/obj/item/slime_extract/core as anything in cores)
		TEST_ASSERT(core.get_integrity() < core.max_integrity, "The pile shielded an extract from fire")
		TEST_ASSERT(core.is_stackable_extract(), "Fire damage alone disqualified an unused extract")
		TEST_ASSERT_EQUAL(core.loc, pile, "Fire damage alone ejected an unused extract")
		health_by_core[core] = core.get_integrity()
	var/obj/item/slime_extract/retrieved = pile.take_extract(floor)
	TEST_ASSERT(retrieved in cores, "Could not retrieve a fire-damaged extract")
	TEST_ASSERT_EQUAL(retrieved.get_integrity(), health_by_core[retrieved], "Retrieving a fire-damaged extract repaired it")

/// Undamaged stock released by a destroyed fridge must still auto-pile.
/datum/unit_test/voidcrew_slime_extract_piles_fridge_spill/Run()
	var/turf/floor = run_loc_floor_bottom_left
	var/obj/machinery/smartfridge/extract/fridge = allocate(/obj/machinery/smartfridge/extract, floor)
	for(var/index in 1 to 10)
		allocate(/obj/item/slime_extract/grey, fridge)
	fridge.ex_act(EXPLODE_DEVASTATE)
	TEST_ASSERT(QDELETED(fridge), "The explosion did not destroy the fridge")
	sleep(1 SECONDS)
	var/obj/structure/slime_extract_pile/pile = locate() in floor
	TEST_ASSERT_NOTNULL(pile, "Undamaged extracts released from a destroyed fridge did not stack")
	TEST_ASSERT_EQUAL(length(pile.contents), 10, "The fridge spill lost fresh extracts")

/// An actual blast destroys the fridge and damages its contents without making unused cores ineligible.
/datum/unit_test/voidcrew_slime_extract_piles_fridge_blast/Run()
	var/turf/floor = run_loc_floor_bottom_left
	var/obj/machinery/smartfridge/extract/fridge = allocate(/obj/machinery/smartfridge/extract, floor)
	var/list/cores = list()
	for(var/index in 1 to 10)
		cores += allocate(/obj/item/slime_extract/grey, fridge)
	var/obj/item/slime_extract/used_core = allocate(/obj/item/slime_extract/grey, fridge)
	used_core.reagents.add_reagent(/datum/reagent/consumable/sugar, 1)
	used_core.reagents.clear_reagents()
	// Guarantee the fridge breaks in one light blast while its cores survive with ordinary health.
	fridge.update_integrity(1)
	explosion(fridge, light_impact_range = 1, flame_range = 0, flash_range = 0, adminlog = FALSE, silent = TRUE, smoke = FALSE)
	sleep(3 SECONDS)
	TEST_ASSERT(QDELETED(fridge), "The light blast did not destroy the weakened fridge")
	var/obj/item/slime_extract/first_core = cores[1]
	var/obj/structure/slime_extract_pile/pile = first_core.loc
	TEST_ASSERT(istype(pile), "Blast-damaged unused cores released from the fridge did not stack")
	TEST_ASSERT_EQUAL(length(pile.contents), length(cores), "The blast pile lost fresh cores or accepted a used core")
	for(var/obj/item/slime_extract/core as anything in cores)
		TEST_ASSERT(!QDELETED(core), "One light blast unexpectedly destroyed a test core")
		TEST_ASSERT(core.get_integrity() < core.max_integrity, "The blast did not damage a stored extract")
		TEST_ASSERT(core.is_stackable_extract(), "Blast damage disqualified an unused extract")
		TEST_ASSERT_EQUAL(core.loc, pile, "A surviving unused core did not join the blast pile")
		TEST_ASSERT_EQUAL(core.extract_uses, initial(core.extract_uses), "The blast changed the core's uses")
	TEST_ASSERT(isturf(used_core.loc), "A previously injected core joined the blast pile")
