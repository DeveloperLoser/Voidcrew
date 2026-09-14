
/datum/ship_upgrade_module/workshop_bogatyr_laboratory_basic
	id = "laboratory_basic"
	name = "Laboratory"
	slot = "laboratory"
	for_ship = /datum/map_template/shuttle/voidcrew/bogatyr
	for_theme = list("proffesional_crew", "bogatyr")
	map_file = "bogatyr/workshop/laboratory_basic.dmm"
	is_default = TRUE

/datum/ship_upgrade_module/workshop_bogatyr_cargo_bay_basic
	id = "cargo_bay_basic"
	name = "Cargo Bay"
	slot = "cargo_bay"
	for_ship = /datum/map_template/shuttle/voidcrew/bogatyr
	for_theme = list("proffesional_crew", "bogatyr")
	map_file = "bogatyr/workshop/cargo_bay_basic.dmm"
	is_default = TRUE

/datum/ship_upgrade_module/workshop_bogatyr_engines_basic
	id = "engines_basic"
	name = "Engines"
	slot = "engines"
	for_ship = /datum/map_template/shuttle/voidcrew/bogatyr
	for_theme = list("proffesional_crew", "bogatyr")
	map_file = "bogatyr/workshop/engines_basic.dmm"
	is_default = TRUE

/datum/ship_upgrade_module/workshop_bogatyr_medical_basic
	id = "medical_basic"
	name = "Medical"
	slot = "medical"
	for_ship = /datum/map_template/shuttle/voidcrew/bogatyr
	for_theme = list("proffesional_crew", "bogatyr")
	map_file = "bogatyr/workshop/medical_basic.dmm"
	is_default = TRUE

/datum/ship_theme/bogatyr/proffesional_crew
	part_cost = list()
	id = "proffesional_crew"
	name = "Proffesional Crew"
	for_ship = /datum/map_template/shuttle/voidcrew/bogatyr
	template_suffix = "bogatyr"
	is_default = FALSE
	desc = "This varient is run by a group of ex-militants, with a strong respect for the chain of command and getting the job done, cleanly. Comes with clothing for 6 people, comes clean, and rations. "
	upgrade_slot_ids = list("laboratory", "cargo_bay", "engines", "medical")

/datum/ship_theme/bogatyr/bogatyr
	part_cost = list()
	id = "bogatyr"
	name = "Bogatyr."
	for_ship = /datum/map_template/shuttle/voidcrew/bogatyr
	template_suffix = "bogatyr_bogatyr"
	is_default = TRUE
	desc = "A ratty, badly wired, unwelcoming pirate ship. Crewed by a rag tag group of Space Russians, this heap comes with a durable reinforced hull, defensible entry points, and a bare bones armory."
	upgrade_slot_ids = list("laboratory", "cargo_bay", "engines", "medical")

/datum/ship_upgrade_module/workshop_bogatyr_salvage_bay
	part_cost = list()
	id = "salvage_bay"
	name = "Salvage Bay"
	slot = "cargo_bay"
	for_ship = /datum/map_template/shuttle/voidcrew/bogatyr
	for_theme = list("bogatyr", "proffesional_crew")
	map_file = "bogatyr/workshop/salvage_bay.dmm"
	is_default = FALSE
	desc = "A Salvage Bay. Comes equipped with 2 Miner MOD's, 2 EVA suits, and a toolbox."

/datum/ship_upgrade_module/workshop_bogatyr_chemistry_suite
	part_cost = list()
	id = "chemistry_suite"
	name = "Chemistry Suite"
	slot = "medical"
	for_ship = /datum/map_template/shuttle/voidcrew/bogatyr
	for_theme = list("bogatyr")
	map_file = "bogatyr/workshop/chemistry_suite.dmm"
	is_default = FALSE
	desc = "Comes with a bomb makers dream chemistry setup."
