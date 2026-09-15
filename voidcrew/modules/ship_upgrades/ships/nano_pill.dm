
/datum/ship_theme/nano_pill_standard
	id = "standard"
	name = "Standard"
	for_ship = /datum/map_template/shuttle/voidcrew/nano_pill
	template_suffix = "nano_pill"
	is_default = TRUE
	upgrade_slot_ids = list("bridge", "mid_section", "engineering")

/datum/ship_theme/nano_pill_syndicate
	part_cost = list(PART_CLASS_COMBAT = 1)
	id = "syndicate"
	name = "Syndicate"
	for_ship = /datum/map_template/shuttle/voidcrew/nano_pill
	template_suffix = "nano_pill_syndicate"
	is_default = FALSE
	upgrade_slot_ids = list("bridge", "mid_section", "engineering")
	desc = "Some careless NT Representatives left the keys on the helm. Whoops!"

/datum/ship_upgrade_module/nano_pill_bridge_basic
	id = "bridge_basic"
	name = "Bridge"
	slot = "bridge"
	for_ship = /datum/map_template/shuttle/voidcrew/nano_pill
	for_theme = list("standard", "syndicate")
	map_file = "nano_pill/bridge_basic.dmm"
	is_default = TRUE
	desc = "A standard, well kept bridge. What a view!"

/datum/ship_upgrade_module/nano_pill_mid_section_basic
	id = "mid_section_basic"
	name = "Classic Loadout"
	slot = "mid_section"
	for_ship = /datum/map_template/shuttle/voidcrew/nano_pill
	for_theme = list("standard", "syndicate")
	map_file = "nano_pill/classic_loadout.dmm"
	is_default = TRUE
	desc = "The standard. Comes with a ORM on the exterior and some supplies."

/datum/ship_upgrade_module/nano_pill_engineering_basic
	id = "engineering_basic"
	name = "Standard."
	slot = "engineering"
	for_ship = /datum/map_template/shuttle/voidcrew/nano_pill
	for_theme = list("standard", "syndicate")
	map_file = "nano_pill/standard.dmm"
	is_default = TRUE
	desc = "Standard loadout. Comes with a single ion engine and a supply crate."

/datum/ship_upgrade_module/nano_pill_advanced_engine_bay
	part_cost = list(PART_CLASS_SCIENCE = 2)
	id = "advanced_engine_bay"
	name = "Advanced Engine Bay"
	slot = "engineering"
	for_ship = /datum/map_template/shuttle/voidcrew/nano_pill
	for_theme = list("standard", "syndicate")
	map_file = "nano_pill/advanced_engine_bay.dmm"
	is_default = FALSE
	desc = "Comes with TWICE the engine power, and a RTG. Adds an engineer to the team."

/datum/ship_upgrade_module/nano_pill_rescue_ship
	part_cost = list(PART_CLASS_SCIENCE = 1, PART_CLASS_TRADE = 2, PART_CLASS_MISC = 1)
	job_slots_add = list(list(name = "New job", officer = FALSE, outfit = /datum/outfit/job/assistant, category = "Medical", slots = 1))
	id = "rescue_ship"
	name = "Rescue Ship"
	slot = "mid_section"
	for_ship = /datum/map_template/shuttle/voidcrew/nano_pill
	for_theme = list("standard", "syndicate")
	map_file = "nano_pill/rescue_ship.dmm"
	is_default = FALSE
	desc = "A refit oriented towards providing emergency medical support. Comes with everything needed to revive a corpse, and a Medic!"

/datum/ship_upgrade_module/nano_pill_questers_helm
	part_cost = list(PART_CLASS_TRADE = 2, PART_CLASS_MISC = 1)
	id = "questers_helm"
	name = "Questers Helm."
	slot = "bridge"
	for_ship = /datum/map_template/shuttle/voidcrew/nano_pill
	for_theme = list("standard", "syndicate")
	map_file = "nano_pill/questers_helm.dmm"
	is_default = FALSE
	desc = "Comes with a missions board and a star chart! Live out your merchant mariner dreams.\n"

/datum/ship_upgrade_module/nano_pill_combatant_bridge
	part_cost = list(PART_CLASS_COMBAT = 2)
	id = "combatant_bridge"
	name = "Combatant Bridge"
	slot = "bridge"
	for_ship = /datum/map_template/shuttle/voidcrew/nano_pill
	for_theme = list("standard", "syndicate")
	map_file = "nano_pill/combatant_bridge.dmm"
	is_default = FALSE
	desc = "This varient comes with a weapons officer and shutters over the windows, as well as extra console space."

/datum/ship_upgrade_module/nano_pill_combatant_midsection
	part_cost = list(PART_CLASS_COMBAT = 2, PART_CLASS_SCIENCE = 1, PART_CLASS_MISC = 2)
	id = "combatant_midsection"
	name = "Combatant Midsection"
	slot = "mid_section"
	for_ship = /datum/map_template/shuttle/voidcrew/nano_pill
	for_theme = list("standard", "syndicate")
	map_file = "nano_pill/combatant_midsection.dmm"
	is_default = FALSE
	desc = "Basically an armory. Comes with two MOD's, subpar mining equipment."
