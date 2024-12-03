/obj/item/rogue/instrument
	name = ""
	desc = ""
	icon = 'icons/roguetown/items/music.dmi'
	icon_state = ""
	slot_flags = ITEM_SLOT_HIP|ITEM_SLOT_BACK_R|ITEM_SLOT_BACK_L
	can_parry = TRUE
	force = 23
	throwforce = 7
	throw_range = 4
	var/datum/looping_sound/dmusloop/soundloop
	var/list/song_list = list()
	var/playing = FALSE

/obj/item/rogue/instrument/equipped(mob/living/user, slot)
	. = ..()
	if(playing && user.get_active_held_item() != src)
		playing = FALSE
		soundloop.stop()
		user.remove_status_effect(/datum/status_effect/buff/playing_music)

/obj/item/rogue/instrument/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.4,"sx" = 0,"sy" = 2,"nx" = 4,"ny" = -4,"wx" = -1,"wy" = 2,"ex" = 7,"ey" = 1,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 8,"sflip" = 8,"wflip" = 8,"eflip" = 0)
			if("onbelt")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)

/obj/item/rogue/instrument/Initialize()
	soundloop = new(list(src), FALSE)
	. = ..()

/obj/item/rogue/instrument/dropped(mob/living/user, silent)
	..()
	if(soundloop)
		soundloop.stop()
		user.remove_status_effect(/datum/status_effect/buff/playing_music)

/obj/item/rogue/instrument/attack_self(mob/living/user)
	if(!user.mind)
		to_chat(user, "<span class='warning'>You have no mind to learn musical skills with!</span>")
		return TRUE

	if(user.mind.get_skill_level(/datum/skill/misc/music) < 1)
		to_chat(user, "<span class='warning'>You lack the musical expertise to play any instrument!</span>")
		return TRUE

	var/stressevent = /datum/stressevent/music
	. = ..()
	if(.)
		return

	user.changeNext_move(CLICK_CD_MELEE)
	if(!playing)
		var/note_color = "#7f7f7f"
		var/list/available_songs = list()
		var/music_skill = user.mind.get_skill_level(/datum/skill/misc/music)
		// Only show songs they have the skill to play
		for(var/song_name in song_list)
			if(music_skill >= song_list[song_name]["skill"])
				available_songs[song_name] = song_list[song_name]

		if(!length(available_songs))
			to_chat(user, "<span class='warning'>You don't know any songs for this instrument!</span>")
			return TRUE

		var/curfile = input(user, "Which song?", "Roguetown", name) as null|anything in available_songs
		if(!user)
			return

		if(user.mind)
			soundloop.stress2give = null
			switch(user.mind.get_skill_level(/datum/skill/misc/music))
				if(1)
					stressevent = /datum/stressevent/music
				if(2)
					note_color = "#ffffff"
					stressevent = /datum/stressevent/music/two
				if(3)
					note_color = "#1eff00"
					stressevent = /datum/stressevent/music/three
				if(4)
					note_color = "#0070dd"
					stressevent = /datum/stressevent/music/four
				if(5)
					note_color = "#a335ee"
					stressevent = /datum/stressevent/music/five
				if(6)
					note_color = "#ff8000"
					stressevent = /datum/stressevent/music/six

		if(playing)
			playing = FALSE
			soundloop.stop()
			user.remove_status_effect(/datum/status_effect/buff/playing_music)
			return

		if(!(src in user.held_items))
			return

		if(user.get_inactive_held_item())
			playing = FALSE
			soundloop.stop()
			user.remove_status_effect(/datum/status_effect/buff/playing_music)
			return

		if(curfile)
			var/required_skill = available_songs[curfile]["skill"]
			if(user.mind.get_skill_level(/datum/skill/misc/music) < required_skill)
				to_chat(user, "<span class='warning'>This song is too difficult for your current musical expertise!</span>")
				return TRUE

			var/sound_file = available_songs[curfile]["file"]
			playing = TRUE
			soundloop.mid_sounds = list(sound_file)
			soundloop.cursound = null
			soundloop.start()
			user.apply_status_effect(/datum/status_effect/buff/playing_music, stressevent, note_color)
	else
		playing = FALSE
		soundloop.stop()
		user.remove_status_effect(/datum/status_effect/buff/playing_music)


/obj/item/rogue/instrument/lute
	name = "lute"
	desc = "Its graceful curves were designed to weave joyful melodies."
	icon_state = "lute"
	song_list = list(
		"A Knight's Return" = list("file" = 'sound/music/instruments/lute (1).ogg', "skill" = 1),
		"Amongst Fare Friends" = list("file" = 'sound/music/instruments/lute (2).ogg', "skill" = 2),
		"The Road Traveled by Few" = list("file" = 'sound/music/instruments/lute (3).ogg', "skill" = 3),
		"Tip Thine Tankard" = list("file" = 'sound/music/instruments/lute (4).ogg', "skill" = 4),
		"A Reed On the Wind" = list("file" = 'sound/music/instruments/lute (5).ogg', "skill" = 5),
		"Jests On Steel Ears" = list("file" = 'sound/music/instruments/lute (6).ogg', "skill" = 5),
		"Merchant in the Mire" = list("file" = 'sound/music/instruments/lute (7).ogg', "skill" = 6))

/obj/item/rogue/instrument/accord
	name = "accordion"
	desc = "A harmonious vessel of nostalgia and celebration."
	icon_state = "accordion"
	song_list = list(
		"Her Healing Tears" = list("file" = 'sound/music/instruments/accord (1).ogg', "skill" = 1),
		"Peddler's Tale" = list("file" = 'sound/music/instruments/accord (2).ogg', "skill" = 2),
		"We Toil Together" = list("file" = 'sound/music/instruments/accord (3).ogg', "skill" = 3),
		"Just One More, Tavern Wench" = list("file" = 'sound/music/instruments/accord (4).ogg', "skill" = 4),
		"Moonlight Carnival" = list("file" = 'sound/music/instruments/accord (5).ogg', "skill" = 5),
		"'Ye Best Be Goin'" = list("file" = 'sound/music/instruments/accord (6).ogg', "skill" = 6))

/obj/item/rogue/instrument/guitar
	name = "guitar"
	desc = "This is a guitar, chosen instrument of wanderers and the heartbroken." // YIPPEE I LOVE GUITAR
	icon_state = "guitar"
	song_list = list(
		"Fire-Cast Shadows" = list("file" = 'sound/music/instruments/guitar (1).ogg', "skill" = 1),
		"The Forced Hand" = list("file" = 'sound/music/instruments/guitar (2).ogg', "skill" = 1),
		"Regrets Unpaid" = list("file" = 'sound/music/instruments/guitar (3).ogg', "skill" = 2),
		"'Took the Mammon and Ran'" = list("file" = 'sound/music/instruments/guitar (4).ogg', "skill" = 2),
		"Poor Man's Tithe" = list("file" = 'sound/music/instruments/guitar (5).ogg', "skill" = 3),
		"In His Arms Ye'll Find Me" = list("file" = 'sound/music/instruments/guitar (6).ogg', "skill" = 3),
		"El Odio" = list("file" = 'sound/music/instruments/guitar (7).ogg', "skill" = 4),
		"Danza De Las Lanzas" = list("file" = 'sound/music/instruments/guitar (8).ogg', "skill" = 4),
		"The Feline, Forever Returning" = list("file" = 'sound/music/instruments/guitar (9).ogg', "skill" = 5),
		"El Beso Carmesí" = list("file" = 'sound/music/instruments/guitar (10).ogg', "skill" = 5),
		"If I Could Be a Constellation" = list("file" = 'sound/music/instruments/guitar (11).ogg', "skill" = 6))

/obj/item/rogue/instrument/harp
	name = "harp"
	desc = "A harp of elven craftsmanship."
	icon_state = "harp"
	song_list = list(
		"Through Thine Window, He Glanced" = list("file" = 'sound/music/instruments/harb (1).ogg', "skill" = 2),
		"The Lady of Red Silks" = list("file" = 'sound/music/instruments/harb (2).ogg', "skill" = 4),
		"Eora Doth Watches" = list("file" = 'sound/music/instruments/harb (3).ogg', "skill" = 6))

/obj/item/rogue/instrument/flute
	name = "flute"
	desc = "A slender flute carefully carved from a smooth wood piece."
	icon_state = "flute"
	song_list = list(
		"Half-Dragon's Ten Mammon" = list("file" = 'sound/music/instruments/flute (1).ogg', "skill" = 1),
		"'The Local Favorite'" = list("file" = 'sound/music/instruments/flute (2).ogg', "skill" = 2),
		"Rous in the Cellar" = list("file" = 'sound/music/instruments/flute (3).ogg', "skill" = 3),
		"Her Boots, So Incandescent" = list("file" = 'sound/music/instruments/flute (4).ogg', "skill" = 4),
		"Moondust Minx" = list("file" = 'sound/music/instruments/flute (5).ogg', "skill" = 5),
		"Quest to the Ends" = list("file" = 'sound/music/instruments/flute (6).ogg', "skill" = 5),
		"Spit Shine" = list("file" = 'sound/music/instruments/flute (7).ogg', "skill" = 6))

/obj/item/rogue/instrument/drum
	name = "drum"
	desc = "Fashioned from taut skins across a sturdy frame, pulses like a giant heartbeat."
	icon_state = "drum"
	song_list = list(
		"Barbarian's Moot" = list("file" = 'sound/music/instruments/drum (1).ogg', "skill" = 2),
		"Muster the Wardens" = list("file" = 'sound/music/instruments/drum (2).ogg', "skill" = 4),
		"The Earth That Quakes" = list("file" = 'sound/music/instruments/drum (3).ogg', "skill" = 6))

/obj/item/rogue/instrument/hurdygurdy
	name = "hurdy-gurdy"
	desc = "A knob-driven, wooden string instrument that reminds you of the oceans far."
	icon_state = "hurdygurdy"
	song_list = list(
		"Ruler's One Ring" = list("file" = 'sound/music/instruments/hurdy (1).ogg', "skill" = 2),
		"Tangled Trod" = list("file" = 'sound/music/instruments/hurdy (2).ogg', "skill" = 3),
		"Motus" = list("file" = 'sound/music/instruments/hurdy (3).ogg', "skill" = 4),
		"Becalmed" = list("file" = 'sound/music/instruments/hurdy (4).ogg', "skill" = 5),
		"The Bloody Throne" = list("file" = 'sound/music/instruments/hurdy (5).ogg', "skill" = 6))

/obj/item/rogue/instrument/viola
	name = "viola"
	desc = "The prim and proper Viola, every prince's first instrument taught."
	icon_state = "viola"
	song_list = list(
		"Far Flung Tale" = list("file" = 'sound/music/instruments/viola (1).ogg', "skill" = 2),
		"G Major Cello Suite No. 1" = list("file" = 'sound/music/instruments/viola (2).ogg', "skill" = 3),
		"Ursine's Home" = list("file" = 'sound/music/instruments/viola (3).ogg', "skill" = 4),
		"Mead, Gold and Blood" = list("file" = 'sound/music/instruments/viola (4).ogg', "skill" = 5),
		"Gasgow's Reel" = list("file" = 'sound/music/instruments/viola (5).ogg', "skill" = 6))
