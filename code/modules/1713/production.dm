/obj/structure/loom
	name = "loom"
	desc = "A loom, used to transform cotton into cloth."
	icon = 'icons/obj/structures.dmi'
	icon_state = "loom"

/obj/structure/loom/attackby(var/obj/item/stack/W as obj, var/mob/living/carbon/human/H as mob)
	if (istype(W, /obj/item/stack/material/cotton))
		H.visible_message("You start to produce the cloth.")
		icon_state = "loom1"
		if (do_after(H, min(W.amount*20, 200), H.loc))
			H.visible_message("You finish producing the cloth.")
			icon_state = "loom"
			var/obj/item/stack/material/cloth/clothes = new/obj/item/stack/material/cloth(H.loc)
			clothes.amount = W.amount
			qdel(W)
		else
			icon_state = "loom"
/obj/structure/mill
	name = "mill"
	desc = "A small mill, used to grind cereals into flour."
	icon = 'icons/obj/structures.dmi'
	icon_state = "flour_mill"

/obj/structure/mill/attackby(var/obj/item/stack/W as obj, var/mob/living/carbon/human/H as mob)
	if (istype(W, /obj/item/weapon/reagent_containers/food/snacks/grown/wheat))
		H.visible_message("You start to mill the [W.name].")
		icon_state = "flour_mill1"
		if (do_after(H, 20, H.loc))
			H.visible_message("You finish milling the [W.name].")
			var/obj/item/weapon/reagent_containers/food/condiment/flour/flour = new/obj/item/weapon/reagent_containers/food/condiment/flour(H.loc)
			flour.reagents.remove_reagent("flour", 20)
			icon_state = "flour_mill"
			qdel(W)
		else
			icon_state = "flour_mill"

/obj/structure/dehydrator
	name = "dehydrator"
	desc = "A wood structure used to dry meat, fish, tobacco, and so on."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "wood_drier0"
	var/filled = 0
	var/stage = 0
	var/obj_type = /obj/item/weapon/reagent_containers/food/snacks/rawcutlet

/obj/structure/dehydrator/attackby(var/obj/item/stack/W as obj, var/mob/living/carbon/human/H as mob)
	if (filled >= 4)
		H << "<span class='notice'>\The [src] is full!</span>"
		return
	else if (istype(W, /obj/item/weapon/reagent_containers/food/snacks/rawcutlet) && filled < 4)
		var/obj/item/weapon/reagent_containers/food/snacks/rawcutlet/RC = W
		if (RC.rotten == TRUE)
			H << "This is rotten."
			return
		else
			H << "You hang the [W.name] to dry."
			filled += 1
			obj_type = W.type
			icon_state = "wood_drier[filled]"
			qdel(W)
			obj_type = /obj/item/weapon/reagent_containers/food/snacks/rawcutlet
			dry_obj(obj_type)
			return
	else if (istype(W, /obj/item/weapon/reagent_containers/food/snacks/fishfillet) && filled < 4)
		var/obj/item/weapon/reagent_containers/food/snacks/fishfillet/FF = W
		if (FF.rotten == TRUE)
			H << "This is rotten."
			return
		else
			H << "You hang the [W.name] to dry."
			filled += 1
			obj_type = W.type
			icon_state = "wood_drier[filled]"
			qdel(W)
			obj_type = /obj/item/weapon/reagent_containers/food/snacks/fishfillet
			dry_obj(obj_type)
			return
/obj/structure/dehydrator/proc/dry_obj(var/obj_type = null)
	spawn(1200) //2 minutes
		if (obj_type == /obj/item/weapon/reagent_containers/food/snacks/rawcutlet)
			new/obj/item/weapon/reagent_containers/food/snacks/driedmeat(src.loc)
			visible_message("The meat finishes drying.")
			filled -= 1
			icon_state = "wood_drier[filled]"
			return
		else if (obj_type == /obj/item/weapon/reagent_containers/food/snacks/fishfillet)
			new/obj/item/weapon/reagent_containers/food/snacks/driedfish(src.loc)
			visible_message("The fish finishes drying.")
			filled -= 1
			icon_state = "wood_drier[filled]"
			return

/obj/item/weapon/starterjar
	name = "fermentation starter jar"
	icon = 'icons/obj/drinks.dmi'
	desc = "A glass jar, used to mulitply yeast."
	icon_state = "jar0"
	item_state = "beaker"
	var/fermenting = 0
	var/fermenting_timer = 0
	var/fermenting_contents = 0
/obj/item/weapon/starterjar/New()
	..()

/obj/item/weapon/starterjar/attackby(obj/O as obj, mob/living/carbon/human/user as mob)
	if (fermenting != 0)
		user << "This jar already has a starter culture inside!"
		return
	if (istype(O, /obj/item/weapon/reagent_containers/food/condiment/flour))
		user << "You add flour to the jar."
		fermenting = 1
		icon_state = "jar1"
		fermenting_timer = world.time + 1800
		qdel(O)
		fermenting_process()
		return

	else if (istype(O, /obj/item/weapon/reagent_containers/food/condiment/enzyme))
		user << "You add some yeast to the jar."
		fermenting = 2
		fermenting_contents++
		icon_state = "jar2"
		qdel(O)
		yeast_growth()
		return
	else
		..()

/obj/item/weapon/starterjar/proc/fermenting_process()
	if (world.time >= fermenting_timer)
		visible_message("The flour in the jar ferments.")
		fermenting = 2
		fermenting_contents = 1
		icon_state = "jar2"
		yeast_growth()
	else
		spawn(100)
			fermenting_process()

/obj/item/weapon/starterjar/proc/yeast_growth()
	if (fermenting_contents > 0)
		spawn(1800)
			if (fermenting_contents > 0 && fermenting_contents < 5)
				fermenting_contents++
			yeast_growth()

/obj/item/weapon/starterjar/attack_self(var/mob/living/carbon/human/user as mob)
	if (fermenting == 2 && fermenting_contents > 0)
		user << "You take some yeast out of the jar."
		new/obj/item/weapon/reagent_containers/food/condiment/enzyme(user.loc)
		fermenting_contents--
		if (fermenting_contents == 0)
			fermenting = 0
			icon_state = "jar0"
	else
		..()