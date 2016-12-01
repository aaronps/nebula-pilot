# Nebula Pilot

**Note:** Currently adding/reviewing the code wait until this notice dissapears.

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

## Music

A game would be incomplete if it didn't have music. Once I decide to add it I expend long time trying to find some music to add to the game.

After two or three days I got tired of searching and decided to make it myself, it wouldn't be as nice but I would get it done. So I powered up the iMac, updated the system, started GarageBand 10... It took me around a week to make the 3 songs.

The Music system has:

* Loopable songs
* Randomized song sequence
* Each song will play twice each cycle, this is the same system as the Background Stars randomization.
* Songs are started in a thread because it caused a noticeable pause on mobile phones.

