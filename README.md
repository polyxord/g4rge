# Godot 4 Rhythm Game Example (g4rge)

This is an open source example rhythm game made in Godot 4.3.

This game and its systems are largely based on
[Quaver](https://github.com/Quaver), another open source rhythm game.

## Note

This game uses the physics process function in order to achieve higher keyboard
polling rate when V-Sync is turned off in the settings. Turning off V-Sync may
introduce screen tearing however, so it is not ideal. Screen tearing can be
negated by changing the max fps setting to 0 (unlimited fps), but at the expense
of drastically increasing GPU usage and power consumption.

Related proposal: https://github.com/godotengine/godot-proposals/issues/1288.

## Licensing

Godot itself is distributed under the MIT license.
See the [Godot Engine license](https://godotengine.org/license/) for more info.

The source code of the game is available under MIT license.
See the LICENSE file for more info.

The [rat photo](https://pixabay.com/photos/animal-brown-creature-critter-fur-1239127/)
by [Robert Owen-Wahl](https://pixabay.com/users/shutterbug75-2077322/) is free for use under the
[Pixabay Content License](https://pixabay.com/service/license-summary/).

The sound effects, demo music, and other assets are available under the
[CC0 - public domain](https://creativecommons.org/publicdomain/zero/1.0/)
license.
