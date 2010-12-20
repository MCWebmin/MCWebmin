# Minecraft Alpha SMP Server startup script
# Version 1.0.2, released October 27th, 2010
# (c) 2010 Dagmar d'Surreal
# Released under the terms of the GNU GPL 2.0.
# Run the script with the argument 'licence' to read the licence.

# Props to Relliktsohg for being the reason this uses screen instead of tee
# and nohup--I am not used to daemons which have a console you'd care to see.

First things first... This is a SysV init script which just _happens_ to have
added functionality so that it can be invoked directly by a plain user account
to spawn a singular instance of the server.  It will never be given extra
features to back up your files, download new versions, do your laundry, or
anything else that is far better handled by any other script written by an 
administrator for that purpose.

The script uses GNU screen to wrapper the server, and *requires* a non-root
account in order to work.  Don't complain about it not letting you run the
thing as root, either.  Doing so is _incredibly_ bad practice.  If you're the
actual administrator, role user accounts cost you nothing and keep the game
(or whatever lucky hacker found a vulnerability in it) from eating your server
alive.  The default username for this is 'miner', but never fear, it can
easily be configured to use some other username.  If you run it as a "regular"
user, it will simply assume that this is the user it's _supposed_ to use.
If you think this was done so that it could be started using crond instead of
init, you'd be completely right.

As with most init scripts, there is very little configuration to be done, but
some intelligence has been coded in to make it relatively painless.  When
invoked by root, the script first looks in /etc/init and then in /etc for the
configuration file (minecraft.conf).  You do *not* need to edit the init
script to make changes to the configuration, nor do you _want_ to--scripts
and configuration data are supposed to stay separated.  If you run it as a
regular user, it looks in ~/.minecraft.conf for it's configuration.

If there's any confusion about what values it's picking (which will likely
be correct anyway) for it's settings, you can run it (as root or as a normal
user) with the "dumpconfig" argument and it will show you what it's using
(after reading your configuration files!).  These settings are as follows:

MC_USER - The username of the role account that runs the minecraft server.
  As mentioned earlier, the default is 'miner'.  DON'T try to use 'minecraft'
  on your shiny new install because usernames longer than eight characters
  cause a lot of things to go wrong.  Obviously you can't use root, either.

MC_DIR - The directory where all your minecraft stuff is, including jar files.
  The default is the role account's home directory, but you might not want
  all those files cluttering the place up if you use that account for other
  things, and that's why this option exists.

MEM_USE - This is the amount of memory (in megabytes) java will be instructed
  to use for the server.  The default is 1024M, just like Notch has suggested.
  You may not set this lower than 2MB (java won't run!) but you may wish to
  set this higher or lower depending on your system's resources.  It is
  strongly suggested you leave a little RAM for _the system_, so if you only
  have 1GB of RAM, try 768MB.  If you only have 512MB of RAM, try 384MB.  If
  you have less than that, let's be honest--you probably need to buy more RAM.

HEY0_MOD - If you have Hey0's server mod, put it in MC_DIR with the rest of
  the Minecraft files.  The default behaviour is to use it to launch Minecraft
  if you have it installed instead of starting the server directly.  This is a
  slightly fancy boolean that can be 0, 1, yes, no, y, or n.

GRACE_TIME - This was a last-minute mercy feature.  It controls the number of
  seconds your players will be sent a broadcast message telling them the
  server is going down *before* it actually shuts down.  It defaults to a mere
  sixty (60) seconds, but you can change it to something higher or lower
  depending on your mood.

Those are really all the configurable items, and you probably don't even need
to set them.  Run the script with the argument "licence" to look at the GNU
GPL 2.0 and make sure you're fine with those conditions (most people are),
then run the script with the argument "dumpconfig" and see if you disagree
with any of those settings.  Make any changes you feel are necessary (by
creating the configuration file) and then run it with "dumpconfig" again.
Once things are coming out the way you like, try manually starting and
stopping the server using the script (using the "stop" and "start" args).
Once you're sure things are configured and working properly, put this script
in your /etc/init.d (or /etc/rc3.d ...) directory and do the usual things you
need to get it running during runlevel 3 (adding symlinks, running the
service command, whatver) if you want it to start with the system or set up
your cron job so that crond will start it and you're good to go.  As with all
changes of this nature, if you expect this to come back up properly after a
reboot, I STRONGLY RECOMMEND going ahead and testing that now by rebooting the
machine so that you can see that it does indeed come back up with the rest of
the system.

If that last paragraph didn't make much sense to you, you need to read some
documentation on system administration specific to your Linux distribution.
I run Slackware.  I *have* an Ubuntu install or two around, and I've used
Fedora, CentOS, and a few other distributions, but questions about how to
install init scripts are best directed at people who normally admin _your_
distribution, not me.  Linux systems being used as servers are *not* toys and
an improperly run system will fall into the hands of script kiddies sooner
rather than later and can do a *lot* of harm.

CHANGELOG/BUGS
--------------
Version 1.0.4 - Fixed cases where the user's homedir wasn't being found
  properly because bash is picky about when it thinks ~ is special.  Also
  spotted a glaring lack of a $ in get_configuration.  Raised the delay on
  startup to two seconds (for slow machines).
Version 1.0.3 - Caught a case where USER might not be populated during init.
  Added a 1s delay and an explcit server up check after trying to start the
  server because we're basically taking it on faith that screen did anything
  at all.  Fixed a typo that was causing joe accounts to be told they couldn't
  use their own uid.
Version 1.0.2 - Corrected an issue where MC_DIR could be ignored.  Renamed
  script from mc.sh to rc.minecraft.  Fixed an edge case where java not being
  in the $PATH could cause a failed start
Version 1.0 - Initial release.


NOT BUGS
--------

 * The script will always send an empty newline _before_ sending any commands
   to the server, just in case there's some leftover text in the console that
   would keep it from seeing the say or stop commands properly.  This causes
   a superfluous error message at the console which can be ignored.

 * The script waits 30 seconds for the server to _gracefully_ save it's files
   and exit.  If you tell it to restart the server and the server fails to
   stop within that time limit, something has gone horribly awry and the
   script will simply issue a warning and exit *without* trying to restart it.
   If you want to do something externally to send it a kill -9, that's all you
   but I'm not interested in getting emails accusing me of map corruption.

 * Again, that the script will stubbornly refuse to let you run the server
   process as root (even when you tell it explicitly MC_USER=root) is not a
   bug of any kind.

 * Lack of support for MCAdmin is also, not a bug.  I didn't write this for
   Windows and I don't support software with undisclosed backdoors in it.


CONTACTING THE AUTHOR
---------------------

Honestly, you shouldn't need to reach me.  I've tested almost all of the
possible uses outlined here and put a bit of thought into what common
setups people are going to have.  For the most part, this should "just work".

If you *do* need to reach me, and since people like to put bloody everything
up on the web where spiders (and the spammers who run them) can find it,
there's a (small) intelligence check involved:  You must know what rot13 is.

Signed,

Dagmar d'Surreal
rivyqntzne@tznvy.pbz
