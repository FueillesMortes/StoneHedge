/obj/item/computer_hardware/battery
	name = "power cell controller"
	desc = ""
	icon_state = "cell_con"
	critical = 1
	malfunction_probability = 1
	var/obj/item/stock_parts/cell/battery = null
	device_type = MC_CELL

/obj/item/computer_hardware/battery/New(loc, battery_type = null)
	if(battery_type)
		battery = new battery_type(src)
	..()

/obj/item/computer_hardware/battery/Destroy()
	. = ..()
	QDEL_NULL(battery)

/obj/item/computer_hardware/battery/handle_atom_del(atom/A)
	if(A == battery)
		try_eject(0, null, TRUE)
	. = ..()

/obj/item/computer_hardware/battery/try_insert(obj/item/I, mob/living/user = null)
	if(!holder)
		return FALSE

	if(!istype(I, /obj/item/stock_parts/cell))
		return FALSE

	if(battery)
		to_chat(user, span_warning("I try to connect \the [I] to \the [src], but its connectors are occupied."))
		return FALSE

	if(I.w_class > holder.max_hardware_size)
		to_chat(user, span_warning("This power cell is too large for \the [holder]!"))
		return FALSE

	if(user && !user.transferItemToLoc(I, src))
		return FALSE

	battery = I
	to_chat(user, span_notice("I connect \the [I] to \the [src]."))

	return TRUE


/obj/item/computer_hardware/battery/try_eject(slot=0, mob/living/user = null, forced = 0)
	if(!battery)
		to_chat(user, span_warning("There is no power cell connected to \the [src]."))
		return FALSE
	if(user)
		user.put_in_hands(battery)
	else
		battery.forceMove(drop_location())
	to_chat(user, span_notice("I detach \the [battery] from \the [src]."))
	battery = null

	if(holder)
		if(holder.enabled && !holder.use_power())
			holder.shutdown_computer()

	return TRUE







/obj/item/stock_parts/cell/computer
	name = "standard battery"
	desc = ""
	icon = 'icons/obj/module.dmi'
	icon_state = "cell_mini"
	w_class = WEIGHT_CLASS_TINY
	maxcharge = 750


/obj/item/stock_parts/cell/computer/advanced
	name = "advanced battery"
	desc = ""
	icon_state = "cell"
	w_class = WEIGHT_CLASS_SMALL
	maxcharge = 1500

/obj/item/stock_parts/cell/computer/super
	name = "super battery"
	desc = ""
	icon_state = "cell"
	w_class = WEIGHT_CLASS_SMALL
	maxcharge = 2000

/obj/item/stock_parts/cell/computer/micro
	name = "micro battery"
	desc = ""
	icon_state = "cell_micro"
	maxcharge = 500

/obj/item/stock_parts/cell/computer/nano
	name = "nano battery"
	desc = ""
	icon_state = "cell_micro"
	maxcharge = 300
