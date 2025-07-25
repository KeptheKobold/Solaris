/obj/structure/vertical_gearbox
	name = "vertical gearbox"
	icon = 'icons/obj/rotation_machines.dmi'
	icon_state = "gearbox"

	rotation_structure = TRUE
	stress_use = 12
	initialize_dirs = CONN_DIR_FORWARD | CONN_DIR_FLIP | CONN_DIR_Z_UP | CONN_DIR_Z_DOWN

/obj/structure/vertical_gearbox/Initialize(mapload, ...)
	. = ..()
	AddComponent(/datum/component/simple_rotation, ROTATION_REQUIRE_WRENCH|ROTATION_IGNORE_ANCHORED)
