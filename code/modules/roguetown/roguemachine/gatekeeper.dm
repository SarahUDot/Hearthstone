//The Gatekeeper accepts coins and automates tolls and other duties
/obj/structure/roguemachine/gatekeeper
	name = "KEEPER"
	desc = "A machine that controls traffic for the kingdom and its inhabitants."
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = "gatekeeper"
	density = FALSE
	blade_dulling = DULLING_BASH
	pixel_y = 32
	var/active = FALSE					//if the machine is active
	var/auto_close = TRUE				//if the toll closes its redstone target(s) automatically
	var/auto_open = TRUE				//if the toll opens its redstone target(s) automatically
	var/close_delay = 8 SECONDS			//how long until the target(s) close
	var/list/collected_items = list()	//list of collected items the device is storing for retrieval
	var/locked = TRUE					//wether the device's storage and configurations are locked away or not
	var/keycontrol = "manor"			//key to lock/unlock the device for items and configurations
	var/master = null					//master of the device
	var/noble_exempt = TRUE				//exempt nobles and allows the opening command
	var/redstone_id = null				//redstone target(s)
	var/taking_toll = TRUE				//if the machine takes currency whatsoever
	var/toll_fee = 6					//the amount of toll_item required, by default coins
	var/toll_item = /obj/item/roguecoin	//by default, /obj/item/roguecoin, but can be changed to give more leeway
	var/toll_extra = null				//extra field for toll key identifiers and other toll variables
	var/toll_method = "vault" 			//what the device should do with the toll. Types are "collect", "destroy", "return" and "vault"
	//var/list/exempt_list = list()		//individual list of exempted mobs for the toll

/obj/item/roguemachine/gatekeeper/update_icon()
	if(active)
		icon_state = "gatekeeper-a"
		set_light(2)
	else
		icon_state = "gatekeeper"
		set_light(0)

/obj/item/roguemachine/gatekeeper/Initialize()
	. = ..()
	update_icon()

/obj/structure/roguemachine/gatekeeper/examine(mob/user)
	. += ..()
	if(active)
		. += span_info(pick("Gears can be heard turning, deep within the device.", "The sounds and echoes of machinery can be heard deep within."))
		if(taking_toll)
			if(!user.is_literate())
				. += span_warning(pick("Uhhh... I think it wants <i>[toll_fee] [toll_item.name]</i>.", "Something about... <i>[toll_fee] [toll_item.name]</i>?"))
			else
				. += span_info("The device requires <i>[toll_fee] [toll_item.name]</i>.")
			switch(toll_method)
				if("return")
					. += span_small("The chute inside its maw is closed, I will be able to retrieve whatever I put inside.")
				else
					. += span_warning(pick("I don't think I will be able to retrieve anything in there, afterward.", "The chute is open, it will definitely keep whatever I put inside.")
		else
			. += span_info("The device doesn't take any toll at the moment.")
	else
		. += span_warning(pick("The device is silent.", "The device is inert.", "It is silent."))

/obj/structure/roguemachine/gatekeeper/attack_hand(mob/user)
	. = ..()
	return

/obj/structure/roguemachine/gatekeeper/attack_right(mob/user)
	. = ..()
	return

//the device can hear commands from its master, the crown, the ruler, and from nobility if they're exempt
/obj/structure/roguemachine/gatekeepeer/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode, original_message)
	if(speaker == src || speaker.loc != loc || !ishuman(speaker) || !active)
		return
	var/mob/living/carbon/human/H = speaker
	var/iscrowned
	if(istype(H.head, /obj/item/clothing/head/roguetown/crown/serpcrown))
		iscrowned = TRUE
	var/isruler
	if(SSticker.rulermob == H)
		isruler = TRUE
	var/message2recognize = sanitize_hear_message(original_message)
	if(findtext(message2recognize, "open for me") || findtext(message2recognize, "let me in") || findtext(message2recognize, "let me out"))
		if(master || iscrowned || isruler || (noble_exempt && H.job in GLOB.noble_positions))
			open_target()
		else
			deny_access()
	if(findtext(message2recognize, "close for me"))
		if(master || iscrowned || isruler || (noble_exempt && H.job in GLOB.noble_positions))
			close_target()
		else
			deny_access()
	if(findtext(message2recognize, "set toll fee") || findtext(message2recognize, "set fee"))
		if(master || iscrowned || isruler)
			set_toll_fee()
		else
			deny_access()
	if(findtext(message2recognize, "set toll"), findtext(message2recognize, "set toll item") || findtext(message2recognize, "set item"))
		if(master || iscrowned || isruler)
			set_toll_item()
		else
			deny_access()

//deny a speaker trying to order the device
/obj/structure/roguemachine/gatekeepeer/proc/deny_access()
	say("I do not listen to you!")
	playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)

//toggles closing the redstone targets automatically after receiving the toll
/obj/structure/roguemachine/gatekeepeer/proc/toggle_auto_close()
	auto_close = !auto_close
	if(auto_close)
		say(pick("I will now close automatically after receiving the toll.", "I will wait and close the way again, once they give me the toll."))
		playsound(src, 'sound/misc/machinelong.ogg', 100, FALSE, -1)
	else
		say(pick("I will no longer close the way.", "You know better than I when to close it.", "I will remind them regardless."))
		playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)

//toggles opening the redstone targets automatically when receiving the toll
/obj/structure/roguemachine/gatekeepeer/proc/toggle_auto_open()
	auto_open = !auto_open
	if(auto_open)
		say(pick("I shall complete my purpose! The toll shall open the way!", "I will open the way for them, when presented the toll."))
		playsound(src, 'sound/misc/machinelong.ogg', 100, FALSE, -1)
	else
		say(pick("I bar the way even before the toll.", "The toll will no longer open me.", "The toll is forfeit, do not tell Charon."))
		playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)

//opens the redstone targets of the device
// TODO: Complete this.
/obj/structure/roguemachine/gatekeepeer/proc/open_target()
	say("I forgot how to do that...")
	playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)

//closes the redstone targets of the device
// TODO : Complete this.
/obj/structure/roguemachine/gatekeepeer/proc/close_target()
	say("I forgot how to do that...")
	playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)

//sets the automatic close delay
/obj/structure/roguemachine/gatekeepeer/proc/set_close_delay()
	if(!Adjacent(user))
		return
	var/newdelay = input(user, "Set the new delay (0-60)", src, close_delay) as null|num
	if(newdelay)
		if(!Adjacent(user))
			return
		if(findtext(num2text(newdelay), "."))
			return
		close_delay = CLAMP(newdelay, 0, 60)
		say("The new delay is [close_delay] seconds.")
		playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)

//sets or replace the master of the device
/obj/structure/roguemachine/gatekeepeer/proc/set_master(mob/living/carbon/human/user)
	if(!Adjacent(user))
		return
	var/newmaster = input(user, "Set a new master for the device", src) as null|string
	if(newmaster)
		if(!Adjacent(user))
			return
		var/found = FALSE
		for(var/mob/living/carbon/human/H in GLOB.player_list)
			if(H.real_name == newmaster)
				found = TRUE
		if(!found)
			say(pick("This name, I do not recognize.", "Are you sure that's how it is pronounced?", "I cannot make sense of that name."))
			playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
			return FALSE
		master = H
		say(pick("I shall obey.", "As you wish.", "They shall be permitted."))
		playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)

//toggles the noble toll exemption and (dis)allow them access to opening/closing the device freely
/obj/structure/roguemachine/gatekeepeer/proc/toggle_noble_exempt()
	noble_exempt = !noble_exempt
	if(noble_exempt)
		say(pick("I will not force the toll on nobles.", "The nobility must be spared.", "Their wealth is best spent elsewhere."))
	else
		say(pick("Nobody will be spared my toll.", "Noble or peasant, their wealth is yours."))
	playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)

//toggles the need for toll
/obj/structure/roguemachine/gatekeepeer/proc/toggle_toll()
	taking_toll = !taking_toll
	if(taking_toll)
		say(pick("I will now charge the toll.", "The chute is open, their payment awaits.", "Payment is mandatory."))
	else
		say(pick("I will no longer charge the toll.", "I will continue my vigil, freely.", "Chute closed, awaiting orders."))
	playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
	playsound(src, 'sound/misc/hiss.ogg', 100, FALSE, -1)

//sets a new amount of toll_item(s) required for the device to open/close
/obj/structure/roguemachine/gatekeepeer/proc/set_toll_fee(mob/living/carbon/human/user)
	if(!Adjacent(user))
		return
	var/newtoll = input(user, "Set the new toll (0-50)", src, toll_fee) as null|num
	if(newtoll && Adjacent(user))
		if(findtext(num2text(newtoll), "."))
			return
		toll_fee = CLAMP(newtoll, 0, 50)
		say("The new toll is now [toll_fee] [toll_item.name].")
		playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
	return

//sets a new item to be required for the device to open/close
/obj/structure/roguemachine/gatekeepeer/proc/set_toll_item(mob/living/carbon/human/user)
	if(!Adjacent(user))
		return
	var/list/itemoptions = list()
	itemoptions += "Require Coins for toll"
	itemoptions += "Require Item(s) for toll"
	itemoptions += "Require a Key"
	var/newitemchoice = input(user, "Please select an option.", "", null) as null|anything in itemoptions
	if(newitemchoice && Adjacent(user))
		playsound(src, 'sound/misc/beep.ogg', 100, FALSE, -1)
		switch(newitemchoice)
			if("Require Coins for toll")
				toll_item = /obj/item/roguecoin
				say("The toll now takes Coins.")
				playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
				return TRUE
			if("Require Item(s) for toll")
				var/list/helditemsoptions = user.held_items
				helditemsoptions += "Cancel"
				var/newitem = input(user, "Please select an option.", "", null) as null|anything in helditemsoptions
				if(newitem && Adjacent(user))
					playsound(src, 'sound/misc/beep.ogg', 100, FALSE, -1)
					if(newitem == "Cancel")
						say("Toll item will remain [toll_item.name].")
						playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
						return TRUE
					else
						toll_item = newitem
						say("The toll now takes [toll_item.name].")
						playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
						set_toll_fee()
						return TRUE
			if("Require a Key")
				var/keyname = input(user, "Please enter the key's identifier.", "", null) as null|string
				if(Adjacent(user) && keyname)
					toll_item = /obj/item/roguekey
					toll_extra = keyname
					say("The toll now takes a special key to work!")
					playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
					return TRUE
	return

/*
//toggles the inbuilt alarm in the device (anti-burglary!)
/obj/structure/roguemachine/gatekeepeer/proc/toggle_alarm(silent = FALSE)
	has_alarm = !taking_toll
		if(taking_toll)
			say("I will now sound the alarm.")
		else
			say("I will no longer sound the alarm.")
		playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
	playsound(src, 'sound/misc/beep.ogg', 100, FALSE, -1)

//toggles the inbuilt defensive mechanisms of the device (anti-burglary!)
/obj/structure/roguemachine/gatekeepeer/proc/toggle_defense(silent = FALSE)
	has_defense = !has_defense
	if(!silent)
		if(has_defense)
			say("I will now fight against intruders.")
		else
			say("I will no longer ward off intruders.")
		playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
	playsound(src, 'sound/misc/beep.ogg', 100, FALSE, -1)
*/

/*
/obj/structure/roguemachine/atm/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H in SStreasury.bank_accounts)
		var/amt = SStreasury.bank_accounts[H]
		if(!amt)
			say("Your balance is nothing.")
			return
		if(amt < 0)
			say("Your balance is NEGATIVE.")
			return
		var/list/choicez = list()
		if(amt > 10)
			choicez += "GOLD"
		if(amt > 5)
			choicez += "SILVER"
		choicez += "BRONZE"
		var/selection = input(user, "Make a Selection", src) as null|anything in choicez
		if(!selection)
			return
		amt = SStreasury.bank_accounts[H]
		var/mod = 1
		if(selection == "GOLD")
			mod = 10
		if(selection == "SILVER")
			mod = 5
		var/coin_amt = input(user, "There is [SStreasury.treasury_value] mammon in the treasury. You may withdraw [amt/mod] [selection] COINS from your account.", src) as null|num
		coin_amt = round(coin_amt)
		if(coin_amt < 1)
			return
		amt = SStreasury.bank_accounts[H]
		if(!Adjacent(user))
			return
		if((coin_amt*mod) > amt)
			playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
			return
		if(!SStreasury.withdraw_money_account(coin_amt*mod, H))
			playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
			return
		budget2change(coin_amt*mod, user, selection)
	else
		to_chat(user, span_warning("The machine bites my finger."))
		icon_state = "atm-b"
		H.flash_fullscreen("redflash3")
		playsound(H, 'sound/combat/hits/bladed/genstab (1).ogg', 100, FALSE, -1)
		SStreasury.create_bank_account(H)
		spawn(5)
			say("New account created.")
			playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)

/obj/structure/roguemachine/atm/attackby(obj/item/P, mob/user, params)
	if(ishuman(user))
		if(istype(P, /obj/item/roguecoin))
			var/mob/living/carbon/human/H = user
			if(H in SStreasury.bank_accounts)
				SStreasury.generate_money_account(P.get_real_price(), H)
				if(!(H.job in GLOB.noble_positions))
					var/T = round(P.get_real_price() * SStreasury.tax_value)
					if(T != 0)
						say("Your deposit was taxed [T] mammon.")
				qdel(P)
				playsound(src, 'sound/misc/coininsert.ogg', 100, FALSE, -1)
				return
			else
				say("No account found. Submit your fingers for inspection.")
	return ..()
*/