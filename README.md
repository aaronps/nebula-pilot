# Nebula Pilot

**Note:** README unfinished, game playable.

![Nebula Pilot Feature pic](spics/nebula-pilot-feature.png)

# License

Currently undecided, so for the moment [no license](http://choosealicense.com/no-license/).



## Background Stars

In the beginning the background was just some dots simulating starts, different dots would move at different speeds as to simulate more distance from the viewer, dots going out of the bottom of the screen would come in from the top at a new randomized loction and speed, this came directly from the java version of the game but didn't look so nice.

One day my son asked me if I changed the stars, it looked so real now, then he realized it was some dust on the phone, at that moment decided to change the backgrounds.

It tooke me a couple of days looking for nice pictures of space, I wanted something tileable and if possible something big so it wouldn't look so repetitive. After much searching, I found something interesting on [webtreats](http://webtreats.mysitemyway.com/tileable-classic-nebula-space-patterns/) and the license was interesting too...

Once I had some assets, I made a scene to encapsulate the logic:

* There are 8 different backgrounds which will be selected randomly and each will appear twice in each cycle of randomness, in worst case scenario the same background will be selected 4 times in a row (2 times at the end of cycle and 2 times at the beginning of next cycle).
* The background does scroll when the ship engines are on and, because it is tileable, it loops seamlessly.
* The background position is randomized at the start, so it is very difficult to see two times the same background.
* Background textures are loaded in a thread, this is because they are somewhat big and on a mobile phone it adds a noticeable pause/delay.

## Menu Buttons

Because I wanted to add several languages to the game and wanted to save on translations, I began looking for some generic buttons and UI elements that I could use on the menu without text.

I found [game-ui-simple-outline-circles](http://opengameart.org/content/game-ui-simple-outline-circles) which is in public domain and had all I needed but looked too simple, so I modified like this:

* Open with Gimp
* Duplicate layer
* Select top layer, Colors -> Colorify
* Select bottom layer, Colors -> Colorify
* Move bottom layer 2 pixels right and down
* Export as png

It took me several days to get the menu buttons right, the positions, the desired effects, I changed many times until the current one seemed nice enought.

## Highscore and Credits scenes

This two scenes needs special attention because are the only scenes which are localized in 3 languages: English, Spanish and Chinese.

Regarding the Chinese localization, because it is just a couple of places, I decided to just make pngs, and avoid the whole [font import](http://docs.godotengine.org/en/stable/tutorials/asset_pipeline/importing_fonts.html#internationalization).

In the process of doing the localization found a weird bug where the localized "tscn" files would be renamed to "_converted.scn" or similar and this would fail, because Godot was looking for the "name.scn" only. To fix this problem the simple way for me was to use "scn" files for the localized ones and tscn for the main one.

I didn't report the problem at that time because it would have taken a lot of precious time, so I added it to my LINO (Last-In Never-Out) list for the future.

## SoundPlayer

At the beginning, each scene had its own sounds, but there were not much control, so if many debrils hit the shield the sound could get loud. To be able to control the sounds better, for example, limiting the number of simultaneous voices and easy configuration on the editor. The sound player is autoloaded and is a global singleton.

Regarding the sounds, I expent long time searching for nice sounds, and nothing seemed good, at the end:

* shield-hit: I made this with Audacity.
* thrust sound: I cut a loopable second from [engine-sound](http://opengameart.org/content/engine-sound)
* ship explosion: [muffled-distant-explosion](http://opengameart.org/content/muffled-distant-explosion) maybe I processed a little.
* debril explosion: I cut a little bit of the beginning of [DeathFlash](http://opengameart.org/content/big-explosion)

## Music

A game would be incomplete if it didn't have music. Once I decide to add it I expend long time trying to find some music to add to the game.

After two or three days I got tired of searching and decided to make it myself, it wouldn't be as nice but I would get it done. So I powered up the iMac, updated the system, started GarageBand 10... It took me around a week to make the 3 songs.

The Music system has:

* Loopable songs
* Randomized song sequence
* Each song will play twice each cycle, this is the same system as the Background Stars randomization.
* Songs are started in a thread because it caused a noticeable pause on mobile phones.

