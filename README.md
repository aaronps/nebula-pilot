# Nebula Pilot

## Background Stars

In the beginning the background was just some dots simulating starts, different dots would move at different speeds as to simulate more distance from the viewer, dots going out of the bottom of the screen would come in from the top at a new randomized loction and speed, this came directly from the java version of the game but didn't look so nice.

One day my son asked me if I changed the stars, it looked so real now, then he realized it was some dust on the phone, at that moment decided to change the backgrounds.

It tooke me a couple of days looking for nice pictures of space, I wanted something tileable and if possible something big so it wouldn't look so repetitive. After much searching, I found something interesting on [webtreats](http://webtreats.mysitemyway.com/tileable-classic-nebula-space-patterns/) and the license was interesting too...

Once I had some assets, I made a scene to encapsulate the logic:

* There are 8 different backgrounds which will be selected randomly and each will appear twice before a new cycle of randomness.
* The background does scroll when the ship engines are on and, because it is tileable, it loops seamlessly.
* The background position is randomized at the start, so it is very difficult to see two times the same background.
* Background textures are loaded in a thread, this is because they are somewhat big and on a mobile phone it adds a noticeable pause/delay.