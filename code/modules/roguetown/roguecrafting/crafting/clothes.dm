
/datum/crafting_recipe/roguetown/survival/skullmask
	name = "skull mask"
	category = "Clothes"
	result = /obj/item/clothing/mask/rogue/skullmask
	reqs = list(/obj/item/natural/bone = 3,
				/obj/item/natural/fibers = 1)
	sellprice = 10
	verbage_simple = "craft"
	verbage = "crafted"
	craftdiff = 0


/datum/crafting_recipe/roguetown/survival/antlerhood
	name = "antlerhood"
	category = "Clothes"
	result = /obj/item/clothing/head/roguetown/antlerhood
	reqs = list(/obj/item/natural/hide = 1,
				/obj/item/natural/bone = 2)
	sellprice = 12
	tools = list(/obj/item/needle)
	skillcraft = /datum/skill/misc/sewing
	verbage_simple = "sew"
	verbage = "sews"
	craftdiff = 0
	
/datum/crafting_recipe/roguetown/survival/tribalrags
	name = "tribal rags (1 fibers, 1 hide)"
	category = "Clothes"
	result = /obj/item/clothing/suit/roguetown/shirt/tribalrag
	reqs = list(/obj/item/natural/hide = 1,
				/obj/item/natural/fibers = 1)
	sellprice = 6
	tools = list(/obj/item/needle)
	skillcraft = /datum/skill/misc/sewing
	verbage_simple = "sew"
	verbage = "sews"
	craftdiff = 0

/datum/crafting_recipe/roguetown/survival/wickercloak
	name = "wickercloak"
	category = "Clothes"
	result = /obj/item/clothing/cloak/wickercloak
	reqs = list(/obj/item/natural/dirtclod = 1,
				/obj/item/grown/log/tree/stick = 5,
				/obj/item/natural/fibers = 3)
	craftdiff = 0

/datum/crafting_recipe/roguetown/survival/collar
	name = "collar"
	category = "Clothes"
	result = /obj/item/clothing/neck/roguetown/collar
	reqs = list(/obj/item/natural/hide/cured = 1)
	craftdiff = 0

/datum/crafting_recipe/roguetown/survival/bell_collar
	name = "bell Collar"
	category = "Clothes"
	result = /obj/item/clothing/neck/roguetown/collar/bell_collar
	reqs = list(
				/obj/item/natural/hide/cured = 1,
				/obj/item/jingle_bells = 1,
				)
	craftdiff = 0

/datum/crafting_recipe/roguetown/survival/feldcollar
	name = "feldcollar"
	category = "Clothes"
	result = /obj/item/clothing/neck/roguetown/collar/feldcollar
	reqs = list(/obj/item/natural/cloth = 2)
	craftdiff = 0

/datum/crafting_recipe/roguetown/survival/surgcollar
	name = "surgcollar"
	category = "Clothes"
	result = /obj/item/clothing/neck/roguetown/collar/surgcollar
	reqs = list(/obj/item/natural/cloth = 2)
	craftdiff = 0

// BOUQUETS & CROWNS

/datum/crafting_recipe/roguetown/survival/bouquet_rosa
	name = "rosa bouquet"
	category = "Clothes"
	result = /obj/item/bouquet/rosa
	reqs = list(/obj/item/alch/rosa = 4,
				/obj/item/natural/fibers = 2,
				/obj/item/paper/scroll = 1)
	craftdiff = 0
	verbage_simple = "arranged"
	verbage = "arranges"

/datum/crafting_recipe/roguetown/survival/bouquet_salvia
	name = "salvia bouquet"
	category = "Clothes"
	result = /obj/item/bouquet/salvia
	reqs = list(/obj/item/alch/salvia = 4,
				/obj/item/natural/fibers = 2,
				/obj/item/paper/scroll = 1)
	craftdiff = 0
	verbage_simple = "arranged"
	verbage = "arranges"

/datum/crafting_recipe/roguetown/survival/bouquet_matricaria
	name = "matricaria bouquet"
	category = "Clothes"
	result = /obj/item/bouquet/matricaria
	reqs = list(/obj/item/alch/matricaria = 4,
				/obj/item/natural/fibers = 2,
				/obj/item/paper/scroll = 1)
	craftdiff = 0
	verbage_simple = "arranged"
	verbage = "arranges"

/datum/crafting_recipe/roguetown/survival/bouquet_calendula
	name = "calendula bouquet"
	category = "Clothes"
	result = /obj/item/bouquet/calendula
	reqs = list(/obj/item/alch/calendula = 4,
				/obj/item/natural/fibers = 2,
				/obj/item/paper/scroll = 1)
	craftdiff = 0
	verbage_simple = "arranged"
	verbage = "arranges"

/datum/crafting_recipe/roguetown/survival/flowercrown_rosa
	name = "rosa crown"
	category = "Clothes"
	result = /obj/item/flowercrown/rosa
	reqs = list(/obj/item/alch/rosa = 4,
				/obj/item/natural/fibers = 2)
	craftdiff = 0
	verbage_simple = "tied"
	verbage = "ties"

/datum/crafting_recipe/roguetown/survival/flowercrown_salvia
	name = "salvia crown"
	category = "Clothes"
	result = /obj/item/flowercrown/salvia
	reqs = list(/obj/item/alch/salvia = 4,
				/obj/item/natural/fibers = 2)
	craftdiff = 0
	verbage_simple = "tied"
	verbage = "ties"

//crosses
/datum/crafting_recipe/roguetown/survival/woodcross
	name = "wooden amulet"
	category = "Clothes"
	result = /obj/item/clothing/neck/roguetown/psicross/wood
	reqs = list(/obj/item/natural/fibers = 2,
				/obj/item/grown/log/tree/stick = 2)
