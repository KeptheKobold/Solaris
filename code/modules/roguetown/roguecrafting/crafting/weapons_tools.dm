/datum/crafting_recipe/roguetown/survival/peasantry
	abstract_type = /datum/crafting_recipe/roguetown/survival/peasantry
	tools = list(/obj/item/rogueweapon/hammer)
	req_table = TRUE
	skillcraft = /datum/skill/craft/carpentry
	category = "Tools"

/datum/crafting_recipe/roguetown/survival/peasantry/thresher
	name = "thresher (+1 Iron Ingot)"
	reqs = list(
		/obj/item/grown/log/tree/stick = 1,
		/obj/item/ingot/iron = 1,
		)
	result = /obj/item/rogueweapon/thresher
	craftdiff = 0

/datum/crafting_recipe/roguetown/survival/peasantry/shovel
	name = "shovel (+1 Iron Ingot, +2 Sticks)"
	reqs = list(
		/obj/item/grown/log/tree/stick = 2,
		/obj/item/ingot/iron = 1,
		)
	result = /obj/item/rogueweapon/shovel
	craftdiff = 0

/datum/crafting_recipe/roguetown/survival/peasantry/hoe
	name = "hoe (+1 Iron Ingot, +2 Sticks)"
	reqs = list(
		/obj/item/grown/log/tree/stick = 2,
		/obj/item/ingot/iron = 1,
		)
	result = /obj/item/rogueweapon/hoe
	craftdiff = 0

/datum/crafting_recipe/roguetown/survival/peasantry/pitchfork
	name = "pitchfork (+1 Iron Ingot, +2 Sticks)"
	reqs = list(
		/obj/item/grown/log/tree/stick = 2,
		/obj/item/ingot/iron = 1,
		)
	result = /obj/item/rogueweapon/pitchfork
	craftdiff = 0

/datum/crafting_recipe/roguetown/survival/peasantry/peasantwarflail
	name = "peasant war flail (thresher)"
	result = /obj/item/rogueweapon/flail/peasantwarflail
	reqs = list(
		/obj/item/grown/log/tree/small = 2,
		/obj/item/rope = 1,
		/obj/item/rogueweapon/thresher = 1,
		)
	craftdiff = 2

/datum/crafting_recipe/roguetown/survival/stoneaxe
	name = "stone axe"
	category = "Tools"
	result = /obj/item/rogueweapon/stoneaxe
	reqs = list(
		/obj/item/grown/log/tree/small = 1,
		/obj/item/natural/stone = 1,
		)

/datum/crafting_recipe/roguetown/survival/stonehammer
	name = "stone hammer"
	category = "Tools"
	result = /obj/item/rogueweapon/hammer/stone
	reqs = list(
		/obj/item/grown/log/tree/small = 1,
		/obj/item/natural/stone = 1,
		)

/datum/crafting_recipe/roguetown/survival/stonehoe
	name = "stone hoe"
	category = "Tools"
	result = /obj/item/rogueweapon/hoe/stone
	reqs = list(
		/obj/item/grown/log/tree/small = 2,
		/obj/item/natural/fibers = 1,
		/obj/item/natural/stone = 1,
		)

/datum/crafting_recipe/roguetown/survival/stonetongs
	name = "stone tongs"
	category = "Tools"
	result = /obj/item/rogueweapon/tongs/stone
	reqs = list(
		/obj/item/grown/log/tree/stick = 2,
		/obj/item/natural/stone = 1,
		)

/datum/crafting_recipe/roguetown/survival/stonepick
	name = "stone pick"
	category = "Tools"
	result = /obj/item/rogueweapon/pick/stone
	reqs = list(
		/obj/item/grown/log/tree/small = 1,
		/obj/item/natural/stone = 2,
		)

/datum/crafting_recipe/roguetown/survival/stoneknife
	name = "stone knife"
	category = "Tools"
	result = /obj/item/rogueweapon/huntingknife/stoneknife
	reqs = list(
		/obj/item/grown/log/tree/stick = 1,
		/obj/item/natural/stone = 1,
		)
	craftdiff = 0

/datum/crafting_recipe/roguetown/survival/stonespear
	name = "stone spear"
	category = "Tools"
	result = /obj/item/rogueweapon/spear/stone
	reqs = list(
		/obj/item/rogueweapon/woodstaff = 1,
		/obj/item/natural/stone = 1,
		)
	craftdiff = 3

/datum/crafting_recipe/roguetown/survival/stonesword
	name = "stone sword"
	category = "Tools"
	result = /obj/item/rogueweapon/sword/stone
	reqs = list(
		/obj/item/grown/log/tree/small = 1,
		/obj/item/natural/fibers = 1,
		/obj/item/natural/stone = 3,
		)
	craftdiff = 1

/datum/crafting_recipe/roguetown/survival/woodclub
	name = "wood club"
	category = "Tools"
	result = /obj/item/rogueweapon/mace/woodclub/crafted
	reqs = list(/obj/item/grown/log/tree/small = 1)

/datum/crafting_recipe/roguetown/survival/billhook
	name = "improvised billhook"
	category = "Tools"
	result = /obj/item/rogueweapon/spear/improvisedbillhook
	reqs = list(
		/obj/item/rogueweapon/sickle = 1,
		/obj/item/rope = 1,
		/obj/item/grown/log/tree/small = 1,
		)
	tools = list(/obj/item/rogueweapon/hammer)
	craftdiff = 3

/datum/crafting_recipe/roguetown/survival/goedendag
	name = "goedendag"
	category = "Tools"
	result = /obj/item/rogueweapon/mace/goden
	reqs = list(
		/obj/item/grown/log/tree/small = 1,
		/obj/item/rope = 1,
		/obj/item/rogueweapon/hoe = 1,
		)
	tools = list(/obj/item/rogueweapon/hammer)
	craftdiff = 3


/obj/item/rogueweapon/mace/woodclub/crafted
	sellprice = 8

/datum/crafting_recipe/roguetown/survival/woodstaff
	name = "wood staff"
	category = "Tools"
	result = list(
		/obj/item/rogueweapon/woodstaff,
		/obj/item/rogueweapon/woodstaff,
		/obj/item/rogueweapon/woodstaff,
		)
	reqs = list(/obj/item/grown/log/tree = 1)
	skillcraft = /datum/skill/craft/carpentry
	craftdiff = 0

/datum/crafting_recipe/roguetown/survival/woodsword
	name = "wood sword"
	category = "Tools"
	result = list(
		/obj/item/rogueweapon/mace/wsword,
		/obj/item/rogueweapon/mace/wsword,
		)
	reqs = list(
		/obj/item/grown/log/tree/small = 1,
		/obj/item/natural/fibers = 1,
		)
	skillcraft = /datum/skill/craft/carpentry
	craftdiff = 0

/datum/crafting_recipe/roguetown/survival/woodshield
	name = "wooden shield"
	category = "Tools"
	result = /obj/item/rogueweapon/shield/wood/crafted
	reqs = list(
		/obj/item/grown/log/tree/small = 1,
		/obj/item/natural/hide = 1,
		)
	skillcraft = /datum/skill/craft/carpentry
	craftdiff = 1

/obj/item/rogueweapon/shield/wood/crafted
	sellprice = 6

/datum/crafting_recipe/roguetown/survival/heatershield
	name = "heater shield"
	category = "Tools"
	result = /obj/item/rogueweapon/shield/heater/crafted
	reqs = list(
		/obj/item/grown/log/tree/small = 2,
		/obj/item/natural/hide/cured = 1,
		)
	skillcraft = /datum/skill/craft/carpentry

/obj/item/rogueweapon/shield/heater/crafted
	sellprice = 6

/datum/crafting_recipe/roguetown/survival/bonespear
	name = "bone spear"
	category = "Tools"
	result = /obj/item/rogueweapon/spear/bonespear
	reqs = list(
		/obj/item/rogueweapon/woodstaff = 1,
		/obj/item/natural/bone = 2,
		/obj/item/natural/fibers = 1,
		)
	craftdiff = 3

/datum/crafting_recipe/roguetown/survival/boneaxe
	name = "bone axe"
	category = "Tools"
	result = /obj/item/rogueweapon/stoneaxe/boneaxe
	reqs = list(
		/obj/item/grown/log/tree/small = 1,
		/obj/item/natural/bone = 2,
		/obj/item/natural/fibers = 1,
		)
	craftdiff = 2

/datum/crafting_recipe/roguetown/survival/woodspade
	name = "wood spade"
	category = "Tools"
	result = /obj/item/rogueweapon/shovel/small
	reqs = list(
		/obj/item/grown/log/tree/small = 1,
		/obj/item/grown/log/tree/stick = 1,
		)
/obj/item/rogueweapon/shovel/small/crafted
	sellprice = 5

/datum/crafting_recipe/roguetown/survival/rod
	name = "fishing rod"
	category = "Tools"
	result = /obj/item/fishingrod/crafted
	reqs = list(
		/obj/item/grown/log/tree/small = 1,
		/obj/item/natural/fibers = 2,
		)

/obj/item/fishingrod/crafted
	sellprice = 8
