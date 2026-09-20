// Ship Workshop crew outfits. Edit these through the crew editor.

/datum/outfit/job/workshop_bogatyr_job_1
	parent_type = /datum/outfit/job/engineer/syndicate
	name = "Bogatyr-class Explorator — Engines Guy"
	backpack_contents = list()

/datum/outfit/job/workshop_bogatyr_job_1/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	. = ..()
	backpack_contents = list()

/datum/outfit/job/workshop_bogatyr_job_8
	parent_type = /datum/outfit/job/engineer/syndicate
	name = "Bogatyr-class Explorator — Engines Guy"
	backpack_contents = list()

/datum/outfit/job/workshop_bogatyr_job_8/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	. = ..()
	backpack_contents = list()

/datum/outfit/job/workshop_bogatyr_job_5
	parent_type = /datum/outfit/job/miner/equipped
	name = "Bogatyr-class Explorator — Guy Given a Pickaxe"
	r_pocket = null
	backpack_contents = list(/obj/item/knife/combat/survival = 1)

/datum/outfit/job/workshop_bogatyr_job_5/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	. = ..()
	r_pocket = null
	backpack_contents = list(/obj/item/knife/combat/survival = 1)

/datum/outfit/job/workshop_bogatyr_job_3
	parent_type = /datum/outfit/job/engineer/syndicate
	name = "Bogatyr-class Explorator — Engines Guy"
	backpack_contents = list()

/datum/outfit/job/workshop_bogatyr_job_3/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	. = ..()
	backpack_contents = list()

/datum/outfit/job/workshop_bogatyr_job_2
	parent_type = /datum/outfit/job/scientist
	name = "Bogatyr-class Explorator — Plauge Master"
	suit = null
	head = null
	ears = /obj/item/radio/headset
	gloves = /obj/item/clothing/gloves/latex/nitrile
	id = /obj/item/card/id/advanced
	suit_store = null
	backpack_contents = list(/obj/item/storage/medkit/regular = 1)

/datum/outfit/job/workshop_bogatyr_job_2/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	. = ..()
	suit = null
	head = null
	ears = /obj/item/radio/headset
	gloves = /obj/item/clothing/gloves/latex/nitrile
	id = /obj/item/card/id/advanced
	suit_store = null
	backpack_contents = list(/obj/item/storage/medkit/regular = 1)

/datum/outfit/job/workshop_bogatyr_job_10
	parent_type = /datum/outfit/job/captain
	name = "Bogatyr-class Explorator — The DJ"
	glasses = /obj/item/clothing/glasses/sunglasses/reagent
	neck = /obj/item/bedsheet/cosmos
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/wheelys
	belt = /obj/item/modular_computer/pda/clear
	id = /obj/item/card/id/advanced/rainbow

/datum/outfit/job/workshop_bogatyr_job_10/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	. = ..()
	glasses = /obj/item/clothing/glasses/sunglasses/reagent
	neck = /obj/item/bedsheet/cosmos
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/wheelys
	belt = /obj/item/modular_computer/pda/clear
	id = /obj/item/card/id/advanced/rainbow

/datum/outfit/job/workshop_bogatyr_job_11
	parent_type = /datum/outfit/job/scientist
	name = "Bogatyr-class Explorator — The Lights and Sound Guy"
	belt = /obj/item/modular_computer/pda/clear
	id = /obj/item/card/id/advanced/rainbow

/datum/outfit/job/workshop_bogatyr_job_11/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	. = ..()
	belt = /obj/item/modular_computer/pda/clear
	id = /obj/item/card/id/advanced/rainbow

/datum/outfit/job/workshop_bogatyr_job_12
	parent_type = /datum/outfit/job/miner
	name = "Bogatyr-class Explorator — Urbexer"
	belt = /obj/item/modular_computer/pda/clear
	id = /obj/item/card/id/advanced/rainbow

/datum/outfit/job/workshop_bogatyr_job_12/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	. = ..()
	belt = /obj/item/modular_computer/pda/clear
	id = /obj/item/card/id/advanced/rainbow

/datum/outfit/job/workshop_bogatyr_job_13
	parent_type = /datum/outfit/job/doctor
	name = "Bogatyr-class Explorator — The Drug Dealer"
	belt = /obj/item/modular_computer/pda/clear
	id = /obj/item/card/id/advanced/rainbow

/datum/outfit/job/workshop_bogatyr_job_13/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	. = ..()
	belt = /obj/item/modular_computer/pda/clear
	id = /obj/item/card/id/advanced/rainbow

/datum/outfit/job/workshop_bogatyr_job_14
	parent_type = /datum/outfit/job/cargo_tech
	name = "Bogatyr-class Explorator — The Supplier"
	belt = /obj/item/modular_computer/pda/clear
	id = /obj/item/card/id/advanced/rainbow

/datum/outfit/job/workshop_bogatyr_job_14/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	. = ..()
	belt = /obj/item/modular_computer/pda/clear
	id = /obj/item/card/id/advanced/rainbow

/datum/outfit/job/workshop_bogatyr_job_15
	parent_type = /datum/outfit/job/assistant
	name = "Bogatyr-class Explorator — Clubber"
	uniform = /obj/item/clothing/under/color/random
	head = /obj/item/clothing/head/wig/random
	shoes = /obj/item/clothing/shoes/sneakers/random
	belt = /obj/item/modular_computer/pda/clear
	id = /obj/item/card/id/advanced/rainbow

/datum/outfit/job/workshop_bogatyr_job_15/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	. = ..()
	uniform = /obj/item/clothing/under/color/random
	head = /obj/item/clothing/head/wig/random
	shoes = /obj/item/clothing/shoes/sneakers/random
	belt = /obj/item/modular_computer/pda/clear
	id = /obj/item/card/id/advanced/rainbow
