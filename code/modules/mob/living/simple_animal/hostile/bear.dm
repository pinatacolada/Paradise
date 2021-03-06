//Space bears!
/mob/living/simple_animal/hostile/bear
	name = "space bear"
	desc = "You don't need to be faster than a space bear, you just need to outrun your crewmates."
	icon_state = "bear"
	icon_living = "bear"
	icon_dead = "bear_dead"
	icon_gib = "bear_gib"
	speak = list("RAWR!","Rawr!","GRR!","Growl!")
	speak_emote = list("growls", "roars")
	emote_hear = list("rawrs","grumbles","grawls")
	emote_see = list("stares ferociously", "stomps")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/bearmeat = 5, /obj/item/clothing/head/bearpelt = 1)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	stop_automated_movement_when_pulled = 0
	maxHealth = 60
	health = 60
	melee_damage_lower = 20
	melee_damage_upper = 30
	attacktext = "mauls"
	attack_sound = 'sound/weapons/genhit3.ogg'

	//Space bears aren't affected by atmos.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	var/stance_step = 0

	faction = list("russian")
	gold_core_spawnable = CHEM_MOB_SPAWN_HOSTILE

//SPACE BEARS! SQUEEEEEEEE~     OW! FUCK! IT BIT MY HAND OFF!!
/mob/living/simple_animal/hostile/bear/Hudson
	name = "Hudson"
	desc = ""
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"

/mob/living/simple_animal/hostile/bear/Move()
	..()
	if(stat != DEAD)
		if(loc && istype(loc,/turf/space))
			icon_state = "bear"
		else
			icon_state = "bearfloor"

/mob/living/simple_animal/hostile/bear/process_ai()
	. = ..()
	if(!.)
		return

	switch(stance)

		if(HOSTILE_STANCE_TIRED)
			stop_automated_movement = 1
			stance_step++
			if(stance_step >= 10) //rests for 10 ticks
				if(target && target in ListTargets())
					stance = HOSTILE_STANCE_ATTACK //If the mob he was chasing is still nearby, resume the attack, otherwise go idle.
				else
					stance = HOSTILE_STANCE_IDLE

		if(HOSTILE_STANCE_ALERT)
			stop_automated_movement = 1
			var/found_mob = 0
			if(target && target in ListTargets())
				if(CanAttack(target))
					stance_step = max(0, stance_step) //If we have not seen a mob in a while, the stance_step will be negative, we need to reset it to 0 as soon as we see a mob again.
					stance_step++
					found_mob = 1
					src.dir = get_dir(src,target)	//Keep staring at the mob

					if(stance_step in list(1,4,7)) //every 3 ticks
						var/action = pick( list( "growls at [target]", "stares angrily at [target]", "prepares to attack [target]", "closely watches [target]" ) )
						if(action)
							custom_emote(1, action)
			if(!found_mob)
				stance_step--

			if(stance_step <= -20) //If we have not found a mob for 20-ish ticks, revert to idle mode
				stance = HOSTILE_STANCE_IDLE
			if(stance_step >= 7)   //If we have been staring at a mob for 7 ticks,
				stance = HOSTILE_STANCE_ATTACK

		if(HOSTILE_STANCE_ATTACKING)
			if(stance_step >= 20)	//attacks for 20 ticks, then it gets tired and needs to rest
				custom_emote(1, "is worn out and needs to rest" )
				stance = HOSTILE_STANCE_TIRED
				stance_step = 0
				walk(src, 0) //This stops the bear's walking
				return



/mob/living/simple_animal/hostile/bear/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(stance != HOSTILE_STANCE_ATTACK && stance != HOSTILE_STANCE_ATTACKING)
		stance = HOSTILE_STANCE_ALERT
		stance_step = 6
		target = user
	..()

/mob/living/simple_animal/hostile/bear/attack_hand(mob/living/carbon/human/M as mob)
	if(stance != HOSTILE_STANCE_ATTACK && stance != HOSTILE_STANCE_ATTACKING)
		stance = HOSTILE_STANCE_ALERT
		stance_step = 6
		target = M
	..()

/mob/living/simple_animal/hostile/bear/Process_Spacemove(var/movement_dir = 0)
	return 1	//No drifting in space for space bears!

/mob/living/simple_animal/hostile/bear/FindTarget()
	. = ..()
	if(.)
		custom_emote(1, "stares alertly at [.]")
		stance = HOSTILE_STANCE_ALERT

/mob/living/simple_animal/hostile/bear/LoseTarget()
	..(5)

/mob/living/simple_animal/hostile/bear/AttackingTarget()
	custom_emote(1, pick( list("slashes at [target]", "bites [target]") ) )

	var/damage = rand(20,30)

	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/dam_zone = pick("head", "chest", "groin", "l_arm", "l_hand", "r_arm", "r_hand", "l_leg", "l_foot", "r_leg", "r_foot")
		var/obj/item/organ/external/affecting = H.get_organ(ran_zone(dam_zone))
		H.apply_damage(damage, BRUTE, affecting, H.run_armor_check(affecting, "melee"), sharp=1, edge=1)
		return H
	else if(isliving(target))
		var/mob/living/L = target
		L.adjustBruteLoss(damage)
		return L
	else if(istype(target,/obj/mecha))
		var/obj/mecha/M = target
		M.attack_animal(src)
		return M

























