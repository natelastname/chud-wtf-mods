#Showbones

###A mod for [Minetest](http://www.minetest.net)

This mod saves the locations of player bones in a text file
"database" in the world directory. Player can use new chat command "/showbones" to
show waypoints that are visible anywhere in world showing the 
direction and distance to all recorded bones up to the server
limit (3 by default). Waypoints are removed and updated as player, or other
players dig them. If player is online when another player digs
thier bones, a chat message will appear letting him/her know of
the crime. :)

If a player has left more than the server limit (default 3) of bones lying
around the world, the oldest ones are removed from the world as
the new one is created. Waypoints are numbered 1 - server limit.
The newest/latest bones would be 1. Bones waypoints may be hidden
by using the /showbones chat command again.
 
This mod was created in hopes relieving the frusteration of players and
admins trying to locate lost bones. There is also the added bonus that 
server admins will no longer need to clean up messy, discarded bones from
all around the server. This mod will only track bones lost from the time
of install. It also will not track bones placed from inventory.

* License: Source code LGPL 2.1

* Credits: PilzAdam - The creator of the bones mod.
Some code copied (on_punch function) for a needed override.

* Adds chat command: /showbones

* Adds privilege: None at this time

* Dependencies: bones

* Forum link: [WIP forum post](https://forum.minetest.net/viewtopic.php?f=9&t=15453)

* Known bugs: To be announced when discovered.

* Code quality: I don't want to talk about it. I'm completely new at lua.

![screenshot_20160919_212218](https://cloud.githubusercontent.com/assets/9083807/18654745/85df0a5a-7eb1-11e6-8071-3d736b13b435.png)



License of source code
----------------------
Copyright (C) 2016 ExeterDad

This program is free software; you can redistribute it and/or modify it under the terms
of the GNU Lesser General Public License as published by the Free Software Foundation;
either version 2.1 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details:
https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
