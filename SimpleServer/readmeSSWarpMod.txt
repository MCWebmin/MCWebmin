SimpleServer WarpMod
Version 2
A simple warp mod for use with the SMP API and SimpleServer.

Installation of SimpleServer WarpMod:
1) Download version 0.9.4 of the SMP API from
	http://www.minecraftforum.net/viewtopic.php?f=1012&t=44394
2) Unzip its contents into your minecraft server folder
3) Add SSWarpMod.jar to the addons folder
4) Edit addon.cfg so the line reads:
addons=SSWarpMod.SSWarpMod
5) Set simplserver.properties
useSMPAPI=true
alternateJarFile=API.jar
6) Start the server
7) Change the mods-warp-command-list.txt file to match your designed group permissions
8) Login to the server as an admin and type !reload
	NOTE: Currently, due to limitations in the SMP API 0.8 typing !reload into the console will not work.
9) You're done! You and your players can now take advantage of warps, while using SimpleServer!

Commands:
!createwarp <name> -- Creates a personal warp point for the player's use only.
!publicwarp <name> -- Creates a public warp point that can be used by any players with !warp permissions.
!removewarp <name> -- Removes a personal warp point owned by the player.
!removepublicwarp <name> -- Removes a public warp point.
!warp <name> -- Warps player to a warp point.
!listwarps -- Lists all warps the player has permission to warp to.
!reload -- Reloads the TXT files
!save -- Saves the TXT files
!mods -- Shows version information