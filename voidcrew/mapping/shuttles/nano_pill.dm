/datum/map_template/shuttle/voidcrew/nano_pill
	name = "Nano-Pill"
	catalog_desc = ""
	suffix = "nano_pill"
	short_name = "Nano-Pill"
	part_requirements = list()
	has_upgrade_slots = TRUE
	upgrade_slot_ids = list("bridge", "mid_section", "engineering")
	player_hidden = FALSE
	job_slots = list(
		list(name = "Captain", officer = TRUE, outfit = /datum/outfit/job/captain, category = JOB_CAT_COMMAND, slots = 1),
		list(name = "Crew", outfit = /datum/outfit/job/assistant, category = JOB_CAT_ASSISTANT, slots = 3),
	)
	available_themes = list("standard", "syndicate")

/obj/docking_port/mobile/voidcrew/nano_pill
	name = "Nano-Pill"
	area_type = /area/shuttle/voidcrew/nano_pill
	port_direction = 2
	preferred_direction = NORTH

/area/shuttle/voidcrew/nano_pill
	name = "Nano-Pill"
	icon_state = "station"
