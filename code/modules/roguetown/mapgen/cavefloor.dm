
/obj/effect/landmark/mapGenerator/rogue/cave
	mapGeneratorType = /datum/mapGenerator/cave
	endTurfX = 128
	endTurfY = 128
	startTurfX = 1
	startTurfY = 1

/datum/mapGenerator/cave
	modules = list(/datum/mapGeneratorModule/cave,/datum/mapGeneratorModule/cavedirt,/datum/mapGeneratorModule/cavebeach)

/datum/mapGeneratorModule/cave
	clusterCheckFlags = CLUSTER_CHECK_DIFFERENT_ATOMS
	allowed_turfs = list(/turf/open/floor/rogue/dirt/road,/turf/open/water,/turf/open/floor/rogue/volcanic)
	spawnableAtoms = list(/obj/item/natural/stone = 19,/obj/structure/roguerock=5,/obj/item/natural/rock = 3, /obj/structure/glowshroom = 4)
	allowed_areas = list(/area/provincial/underground/spider_cave,/area/provincial/underground,/area/provincial/underground/underdark/undersea,/area/provincial/underground,/area/provincial/underground/mountains/underkings_maw)

/datum/mapGeneratorModule/cavedirt
	clusterCheckFlags = CLUSTER_CHECK_DIFFERENT_ATOMS
	allowed_turfs = list(/turf/open/floor/rogue/dirt)
	spawnableAtoms = list(/obj/structure/flora/rogueshroom=20,/obj/structure/roguerock=20,/obj/structure/flora/roguegrass = 14,/obj/structure/closet/dirthole/closed/loot=6,/obj/item/natural/stone = 24,/obj/item/natural/rock = 8, /obj/structure/glowshroom = 3)
	allowed_areas = list(/area/provincial/underground/spider_cave,/area/provincial/underground,/area/provincial/underground/underdark/undersea,/area/provincial/underground,/area/provincial/underground/mountains/underkings_maw)

/datum/mapGeneratorModule/cavebeach
	clusterCheckFlags = CLUSTER_CHECK_DIFFERENT_ATOMS
	allowed_turfs = list(/turf/open/water/ocean)
	spawnableAtoms = list(/obj/structure/roguerock=20, /obj/structure/glowshroom = 3)
	allowed_areas = list(/area/provincial/outdoors/beach)

/obj/effect/landmark/mapGenerator/rogue/cave/lava
	mapGeneratorType = /datum/mapGenerator/cave/lava

/datum/mapGenerator/cave/lava
	modules = list(/datum/mapGeneratorModule/cave,/datum/mapGeneratorModule/cavedirt/lava)

/datum/mapGeneratorModule/cavedirt/lava
	spawnableTurfs = list(/turf/open/lava=2,/turf/open/floor/rogue/dirt/road=30)
	allowed_areas = list(/area/provincial/underground/mountains/underkings_maw) // SOLARIS NEWMAP TODO: Old Sunmarch should have this as well


/obj/effect/landmark/mapGenerator/rogue/cave/spider
	mapGeneratorType = /datum/mapGenerator/cave/spider
	endTurfX = 64
	endTurfY = 64
	startTurfX = 1
	startTurfY = 1

/datum/mapGenerator/cave/spider
	modules = list(/datum/mapGeneratorModule/cavespider,/datum/mapGeneratorModule/cave,/datum/mapGeneratorModule/cavedirt)

/datum/mapGeneratorModule/cavespider
	clusterCheckFlags = CLUSTER_CHECK_DIFFERENT_ATOMS
	allowed_turfs = list(/turf/open/floor/rogue/dirt)
	spawnableAtoms = list(/obj/structure/spider/stickyweb=10)
	allowed_areas = list(/area/provincial/underground/spider_cave)
