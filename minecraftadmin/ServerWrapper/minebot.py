#!/usr/bin/python

from subprocess import Popen, PIPE
import tempfile
import sys
import re
import select
from time import strftime, time
import datetime
import math
import os
import string
import ConfigParser
from StringIO import StringIO

## default config ##
default_config = """
[general]
server = ./minecraft_server.jar
admins =
whitelist =
lite_admins =
motd = Welcome $nick!|Type "!help" to see the available commands.|Type "!who" to see who is playing right now.
max_players = 10
voteban_threshold = 90
votekick_threshold = 80
password =
password_timeout = 15
atlogin =
[java]
heapmem_max = 1024M
heapmem_min = 1024M
"""



class Mineception(Exception): #TODO: Come up with something better!
   def __init__(self, value):
      self.errmsg = value

   def __str__(self):
      print self.errmsg

def logmsg(msg):
   print "[SRVBOT] %s" % msg


def say(message, is_console = False):
   if is_console:
      logmsg(message)
   else:
      stdin.write('say %s\n' % message)

def kick(user):
   stdin.write('kick %s\n' % user)

def unban(user):
   if user.lower() in ban_list:
      ban_list.remove(user.lower())

      savebans()
   else:
      raise Mineception('User \'%s\' not banned' % user)

def ban(user, kick = False): # default to no kicking
   if not user.lower() in ban_list:
      ban_list.append(user.lower())
      
      if kick:
         kick(user)

      savebans()
   else:
      raise Mineception('User \'%s\' already banned' % user)

def savebans():
   try:
      bans = open('server.bans', 'w')
      for nick in ban_list:
         bans.write('%s\n' % nick)
   except:
      raise Mineception('File I/O Error writing server.bans')
   
   'bans' in locals() and bans.close()


def give(player, item, amount):
   if player.lower() not in players:
      raise Mineception('Unknown player: \'%s\'' % player)
   try:
      amount = int(amount)
   except ValueError:
      raise Mineception('Amount must be a number')

   if not item.isdigit():
      try: 
         item = blocks[item]
      except KeyError:
         raise Mineception('Unknown Item-ID: \'%s\'' % item)

   for i in range(amount):
      stdin.write('give %s %s\n' % (player, item))

def logsrv(msg):
   print "[SERVER] %s" %msg

     
logmsg('Starting...')
logmsg('Loading default config...')

try:
   config = ConfigParser.ConfigParser()
   config.readfp(StringIO(default_config))
except:
   logmsg('Failed to load default config, exiting...')
   exit()

## load custom config ##
logmsg('Checking custom config...')

if os.path.isfile('minebot.ini'):
   logmsg('Custom config found, loading...')
   try:
      config.read('minebot.ini')
   except:
      logmsg('Error loading custom config, exiting...')
      exit()
else:
   logmsg('Writing new config file...')
   try:
      config_file = open('minebot.ini', 'w')
      config.write(config_file)
      config_file.close()
   except:
      logmsg('Failed to write new config file, continuing...')

logmsg('Setting config...')
try: #TODO: Decide between THIS_SPELLING and this_spelling :P
   SERVER             = config.get('general', 'server')
   ADMINS             = config.get('general', 'admins').split(' ')
   if ADMINS[0] == '':
      del(ADMINS[0])

   map(lambda admin: admin.lower(), ADMINS)

   temp_admins        = config.get('general', 'lite_admins').split(' ')
   if temp_admins[0] == '':
      del(temp_admins[0])

   whitelist          = config.get('general', 'whitelist').split(' ')
   if whitelist[0] == '':
      del(whitelist[0])

   HEAPMEM_MAX        = config.get('java', 'heapmem_max')
   HEAPMEM_MIN        = config.get('java', 'heapmem_min')
   MAXPLAYER          = config.getint('general', 'max_players')
   VOTEBAN_THRESHOLD  = config.getint('general', 'voteban_threshold')
   VOTEKICK_THRESHOLD = config.getint('general', 'votekick_threshold')
   PASSWORD           = config.get('general', 'password')
   if PASSWORD == '':
      PASSWORD = None

   PASSTIME           = config.getint('general', 'password_timeout')
   motd               = config.get('general', 'motd').split('|')
   atlogin            = config.get('general', 'atlogin').split(' ')
   if atlogin[0] == '':
      del(atlogin[0])
except:
   logmsg('Failed setting configuration, exiting...')
   exit()

logmsg('Running the server executable...')
server_args = ["java", "-Xmx%s" % (HEAPMEM_MAX), "-Xms%s" % (HEAPMEM_MIN), 
               "-jar", SERVER, "nogui"]

if os.name == 'nt':
   import win32pipe
   (stdin, stdout) = win32pipe.popen4(" ".join(server_args))

else:
   server = Popen(server_args,
         stdout = PIPE,
         stdin = PIPE,
         stderr = PIPE)
   outputs = [server.stderr, server.stdout, sys.stdin]
   stdin = server.stdin

# Proudly scraped off http://copy.bplaced.net/mc/ids.php
blocks = dict({
   "stone": 1, "rock": 1, "grass": 2, "dirt": 3, "cobblestone": 4, "wood": 5,
   "sapling": 6, "bedrock": 7, "water": 8, "stillwater": 9, "lava": 10,
   "stilllava": 11, "sand": 12, "gravel": 13, "goldore": 14, "ironore": 15,
   "coalore": 16, "tree": 17, "leaves": 18, "sponge": 19, "glass": 20,
   "cloth": 35, "flower": 37, "rose": 38, "brownmushroom": 39, "redmushroom": 40, "goldblock": 41,
   "ironblock": 42, "double": 43, "stair": 44, "brickblock": 45, "tnt": 46, 
   "bookshelf": 47, "mossy": 48, "obsidian": 49, "torch": 50, "fire": 51,
   "mob": 52, "woodstairs": 53, "chest": 54, "redstone": 55, "diamondore": 56,
   "diamondblock": 57, "workbench": 58, "crop": 59, "soil": 60, "furnace": 61,
   "litfurnace": 62, "signpost": 63, "wooddoorblock": 64, "ladder": 65, "rails": 66, 
   "stonestairs": 67, "signtop": 68, "lever": 69, "rockplate": 70, "irondoor": 71, 
   "woodplate": 72, "redstoneore1": 73, "redstoneore2": 74, "redstonetorch1": 75,
   "redstonetorch2": 76, "button": 77, "snow": 78, "ice": 79, "snowblock": 80,
   "cactus": 81, "clayblock": 82, "reedblock": 83, "jukebox": 84, 

   "ironshovel": 256, "ironpick": 257, "ironaxe": 258, "flintsteel": 259,
   "apple": 260, "bow": 261, "arrow": 262, "coal": 263, "diamond": 264,
   "iron": 265, "gold": 266, "ironsword": 267, "woodsword": 268, 
   "woodshovel": 269, "woodpick": 270, "woodaxe": 271, "stonesword": 272,
   "stoneshovel": 273, "stonepick": 274, "stoneaxe": 275, "diamondsword": 276,
   "diamondshovel": 277, "diamondpick": 278, "diamondaxe": 279, "stick": 280,
   "bowl": 281, "soup": 282, "goldsword": 283, "goldshovel": 284, 
   "goldpick": 285, "goldaxe": 286, "string": 287, "feather": 288, 
   "gunpowder": 289, "woodhoe": 290, "stonehoe": 291, "ironhoe": 292,
   "diamondhoe": 293,"goldhoe": 294, "seeds": 295, "wheat": 296, "bread": 297,
   "leatherhelmet": 298, "leatherchest": 299, "leatherpants": 300,
   "leatherboots": 301, "chainmailhelmet": 302, "chainmailchest": 303,
   "chainmailpants": 304, "chainmailboots": 305, "ironhelmet": 306,
   "ironchest": 307, "ironpants": 308, "ironboots": 309, "diamondhelmet": 310,
   "diamondchest": 311, "diamondpants": 312, "diamondboots": 313,
   "goldhelmet": 314, "goldchest": 315, "goldpants": 316, "goldboots": 317,
   "flint": 318, "meat": 319, "cookedmeat": 320, "painting": 321, 
   "goldenapple": 322, "sign": 323, "wooddoor": 324, "bucket": 325,
   "waterbucket": 326, "lavabucket": 327, "minecart": 328, "saddle": 329,
   "irondoor": 330, "redstonedust": 331, "snowball": 332, "boat": 333,
   "leather": 334, "milkbucket": 335, "brick": 336, "clay": 337, "reed": 338,
   "paper": 339, "book": 340, "slimeorb": 341, "storagecart": 342, 
   "poweredcart": 343, "egg": 344
   })




# Prepare some regexps
# To add multiple admins, you can separate them with a pipe:
# admin = re.compile('Flippeh|Somedude|Anotherdude')

admin = re.compile("^(%s)$" % string.join(ADMINS, "|"), re.IGNORECASE)

chatmessage = re.compile('^\d.+ \d.+ .INFO. <(.+?)> (.+)$')

srv_list_response = re.compile('Connected players: (.+)')
srv_playercount   = re.compile('^Player count: (\d+)')
srv_join          = re.compile('^\d.+ \d.+ .INFO. (.+?) \[.+?\] logged in')
srv_part          = re.compile('^\d.+ \d.+ .INFO. (.+?) lost connection')

try:
   current_players = 0
   started         = int(time())
   votekicks       = dict({})
   votebans        = dict({})
   players         = dict({})

   if os.path.exists("server.bans"):
      try:
         bans = open('server.bans', 'r')
         ban_list = map(lambda x: x.rstrip(), bans.readlines()) # more magic!

      except:
         logmsg('Error while loading bans! Gotta continue with them')
         ban_list = []
      
      'bans' in locals() and bans.close()

   else:
      try:
         logmsg("No ban file, creating it...")
         bans = open('server.bans', 'w')

      except:
         logmsg('Error creating \'server.bans\'')
      
      'bans' in locals() and bans.close()

      ban_list = []
   
   # main loop
   while True:
      try:
         if os.name == 'nt':
            outready = [stdout]
         else:
            outready, inready, exceptready = select.select(outputs, [], [], 1.0)
      except:
         break

      if outready == []:
         for p in players:
            if (time() - players[p]['connected'] > PASSTIME) and not players[p]['allowed']:
               kick(p)
               del players[p]
               break

      else:
         for s in outready:
            line = s.readline().rstrip()
            text = None

            if line == '':
               break
            
            if s == sys.stdin:
               logsrv('[CONSOLE] %s' % line)
               nick = "<console>"
               text = line
               is_console = True
            else:
               logsrv(line)
               chat = chatmessage.match(line)
            
            if chat:
               nick = chat.group(1)
               text = chat.group(2)
 
               is_console = False

            if text is not None:   
               parts = text.split(" ")

               if not is_console and PASSWORD != None and not players[nick.lower()]['allowed']:
                  if players[nick.lower()]['allowed'] != True and text != PASSWORD :
                     say('Wrong password!\n')
                  else:
                     players[nick.lower()]['allowed'] = True
                     say('Access granted - have fun!')

               if parts[0] == '!give':
                  if (is_console or admin.match(nick) or nick.lower() in temp_admins):
                     try:
                        items = string.join(parts[3:],'').replace(' ','').split(',')
                        amount = parts[2]
                        targets= parts[1].split(',')

                        for item in items:
                           try:
                              for target in targets:
                                 give(target, item, amount)
                           except Mineception, me:
                              say(me.errmsg, is_console)

                           
                     except IndexError:
                        say('Syntax: !give <player> <amount> <what>', is_console)
                  else:
                     say('You\'re no admin, %s!\n' % nick)

               elif parts[0] == '!stop':
                  if is_console or admin.match(nick):
                     stdin.write("stop\n")
                  else:
                     say('You\'re no admin, %s!\n' % nick)

               elif parts[0] == '!giveall':
                  if (is_console or admin.match(nick) or nick.lower() in temp_admins):
                     try:
                        items = string.join(parts[2:],'').replace(' ','').split(',')
                        amount = parts[1]
                        for item in items:
                           try:
                              for target in players:
                                give(target, item, amount)
                           except Mineception, me:
                              say(me.errmsg, is_console)

                     except IndexError:
                       say('Syntax: !giveall <amount> <what>', is_console)
                  else:
                     say('You\'re no admin, %s!' % nick)

               elif parts[0] == '!lite':
                  if (is_console or admin.match(nick)):
                     try:
                        target = parts[1]
   
                        if not target.lower() in temp_admins:
                           temp_admins.append(target.lower())
                           try:
                              config.set('general', 'lite_admins', string.join(temp_admins, ' '))
                              config_file = open('minebot.ini', 'w')
                              config.write(config_file)
                              config_file.close()
                           except:
                              logmsg('Failed to write config file on %s...' % parts[0])

                           say('Made %s lite admin' % target)
                        else:
                           say('Player already is an admin', is_console)
                     except IndexError:
                        say('Syntax: !lite <player>', is_console)
                  else:
                     say('You\'re no admin, %s!' % (nick))
   
               elif parts[0] == '!unlite':
                  if (is_console or admin.match(nick)):
                     try:
                        target = parts[1]
   
                        if target.lower() in temp_admins:
                           temp_admins.remove(target.lower())
                           try:
                              config.set('general', 'lite_admins', string.join(temp_admins, ' '))
                              config_file = open('minebot.ini', 'w')
                              config.write(config_file)
                              config_file.close()
                           except:
                              logmsg('Failed to write config file on %s...' % parts[0])
                              
                           say('Removed %s\'s admin' % target)
                        else:
                           say('No such admin', is_console)
                     except IndexError:
                        say('Syntax: !unlite <player>', is_console)
                  else:
                     say('You\'re no admin, %s!' % nick)
   
               elif parts[0] == '!kick':
                  if (is_console or admin.match(nick) or nick in temp_admins):
                     try:
                        target = parts[1]
                        kick(target)

                     except IndexError:
                        say('Syntax: !kick <player>', is_console)
                  else:
                     say('You\'re no admin, %s!' % nick)

               elif parts[0] == '!white':
                  if (is_console or admin.match(nick) or nick.lower() in temp_admins):
                     try:
                        target = parts[1]

                        if not target.lower() in whitelist:
                           whitelist.append(target.lower())

                           try:
                              config.set('general', 'whitelist', string.join(whitelist, ' '))
                              config_file = open('minebot.ini', 'w')
                              config.write(config_file)
                              say('Added \'%s\' to whitelist' % target)
                           except: 
                              say('Could not save user on the whitelist!', is_console)
                           
                              config_file.close()
                        else:
                           say('User already on whitelist!', is_console)

                     except IndexError:
                        say('Syntax: !white <nick>', is_console)

               elif parts[0] == "!unwhite":
                  if (is_console or admin.match(nick) or nick.lower() in temp_admins):
                     try:
                        target = parts[1]

                        if target.lower() in whitelist:
                           whitelist.remove(target.lower())

                           try:
                              config.set('general', 'whitelist', string.join(whitelist, ' '))
                              config_file = open('minebot.ini', 'w')
                              config.write(config_file)
                              say('Removed \'%s\' from whitelist' % target)
                           except:
                              say('Could not save the whitelist', is_console)
                           
                              config_file.close()
                        else:
                           say('User not on whitelist', is_console)
                     except IndexError:
                        say('Syntax: !unwhite <nick>', is_console)

               elif parts[0] == "!ban":
                  if (is_console or admin.match(nick) or nick.lower() in temp_admins):
                     try:
                        target = parts[1]
   
                        try:
                           ban(target)   
                           say('Banned player \'%s\'' % target)
                        except Mineception, me:
                           say('Unable to add ban: %s' % me.errmsg, is_console)

                     except IndexError:
                        say('Syntax: !ban <player>', is_console)

                  else:
                     say('You\'re no admin, %s!' % nick)

               elif parts[0] == '!unban':
                  if (is_console or admin.match(nick) or nick.lower() in temp_admins):
   
                     try:
                        target = parts[1]
   
                        try:
                           unban(target)
                           say('Unbanned player \'%s\'' % target)
                        except Mineception, me:
                           say('Unable to unban: %s' % me.errmsg, is_console)
   
                     except IndexError:
                        say('Syntax: !unban <player>', is_console)
   
                  else:
                     say('You\'re no admin, %s!' % nick)
   
               elif parts[0] == '!who':
                  stdin.write('list\n')
   
               elif parts[0] == '!time':
                  t = strftime('%H:%M:%S (%Z)')
                  say('The current server time is: %s' % t, is_console)
   
               elif parts[0] == '!votekick' and not is_console:
                  voter = nick
   
                  try:
                     target = parts[1].lower()
   
                     if admin.match(target) or nick in temp_admins:
                        say('You can\'t votekick admins!')
                        continue
   
                     try:
                        if voter in votekicks[target]:
                           say('You can\'t vote twice')
                           continue
                        else:
                           votekicks[target].append(voter)
                     except KeyError:
                        votekicks[target] = [voter]

                     perc = float(len(votekicks[target])) * 100 / current_players
   
                     say('Voting to kick %s: %.2f%% / %.2f%%' 
                           % (target, perc, VOTEKICK_THRESHOLD))
   
                     if perc >= VOTEKICK_THRESHOLD:
                        say('Vote passed!')
                        kick(target)
   
                        votekicks.pop(target)
                  except IndexError:
                     say('Syntax: !votekick <player>')

               elif parts[0] == '!voteban' and not is_console:
                  voter = nick

                  try:
                     target = parts[1].lower()

                     if admin.match(target) or nick in temp_admins:
                        say('You can\'t voteban admins!')
                        continue

                     try:
                        if voter in votebans[target]:
                           say('You can\'t vote twice')
                           continue
                        else:
                           votebans[target].append(voter)

                     except KeyError:
                        votebans[target] = [voter]

                     perc = float(len(votebans[target])) * 100 / current_players

                     say('Voting to ban %s: %.2f%% / %.2f%%' 
                           % (target, perc, VOTEBAN_THRESHOLD))

                     if perc >= VOTEBAN_THRESHOLD:
                        say('Vote passed!')
   
                        try:
                           ban(target, True)
                        except Mineception, me:
                           say('Banning has failed: %s' % me.errmsg)

                        votebans.pop(target)

                  except IndexError:
                     say('Syntax: !voteban <player>')

               elif parts[0] == '!motd':
                  if (len(parts) == 1):
                     for line in motd:
                        say('MOTD: %s' % line.replace("$nick", nick), is_console)

                  elif (is_console or admin.match(nick)):
                     try:
                        motd = string.join(parts[1:], " ").split("|")
                        try:
                           config.set('general', 'motd', string.join(motd, '|'))
                           config_file = open('minebot.ini', 'w')
                           config.write(config_file)
                           config_file.close()
                        except:
                           logmsg('Failed to write config file on %s...' % parts[0])

                        for line in motd:
                           say('MOTD: %s' % line)

                     except IndexError:
                        say('Syntax: !motd <message>')
                  else:
                     say('You\'re no admin, %s!' % nick)

               elif parts[0] == '!atlogin':
                  if (is_console or admin.match(nick)):
                     try:
                        atlogin = string.join(parts[1:],'').replace(' ','').split(',')
                        try:
                           config.set('general','atlogin',string.join(atlogin,' '))
                           config_file = open('minebot.ini', 'w')
                           config.write(config_file)
                           config_file.close()
                        except:
                           say('Failed to write config file on %s...' % parts[0], is_console)
                     except IndexError:
                        logmsg('Syntax: !atlogin item1,item2,item3')
                  else:
                     say('You\'re no admin, %s!' %nick)

               elif parts[0] == '!help':
                  say('!time - Get current server time', is_console)
                  say('!who  - Show who\'s playing and how long', is_console)
                  say('!votekick <nick> Vote to kick someone', is_console)
                  say('!voteban <nick> Vote to ban someone', is_console)
                  say('!uptime - Show server uptime', is_console)
                  say('!motd - display the MOTD', is_console)

                  if is_console or admin.match(nick) or nick.lower() in temp_admins:
                     say('!give <nick> <amount> <Item ID | Name> - Give someone an item', is_console)
                     say('!kick <nick> - Kick someone', is_console)
                     say('!ban <nick> - Ban someone', is_console)
                     say('!unban <nick> - Unban someone', is_console)
                     say('!white <nick> - Add someone to the whitelist', is_console)
                     say('!unwhite <nick> - Remove someone from the whitelist', is_console)

                     if is_console or admin.match(nick):
                        say('!lite <nick> - Make someone a lite admin', is_console)
                        say('!unlite <nick> - Remove lite admin status', is_console)
                        say('!motd <message> - set the MOTD', is_console)
                        say('!atlogin <item>[,item[,item]] - give players items at login', is_console)
                        say('!stop - Stop the server', is_console)
   
               elif parts[0] == '!uptime':
                  uptime = int(time()) - started
   
                  say('The server has been up for %s' % (datetime.timedelta(seconds = uptime)), is_console)

               elif parts[0] == '!!' and is_console:
                  stdin.write("%s\n" % string.join(parts[1:], " "))

            else: #NO chat
               # Server responded with the userlist, parse and spread the news
               who_resp = srv_list_response.search(line)
               if who_resp:
                  players_on = who_resp.group(1).split(", ")
                  try:
                     say('Currently online [%s/%s]:' % (len(players_on),min(int(MAXPLAYER),20)), is_console)
                  except ValueError:
                     say('Currently online [?/?]:', is_console)
   
                  for i in players_on:
                     try:
                        contime = int(time()) - players[i.lower()]['connected']
                        connected = datetime.timedelta(seconds = contime)
   
                        if admin.match(i):
                           say(' - %s (Admin) [%s]\n' % (i, connected), is_console)
                        elif i.lower() in temp_admins:
                           say(' - %s (Lite Admin) [%s]' % (i, connected), is_console)
                        else:
                           say(' - %s [%s]' % (i, connected), is_console)
   
                     except KeyError:
                        logmsg('Unlisted user: %s' % (i))
   
                  continue
   
               # Server told us the player count
               ply_rsp = srv_playercount.search(line)
               if ply_rsp:
                  current_players = int(ply_rsp.group(1))
   
                  if current_players > MAXPLAYER and not admin.match(last_joined):
                     say('Maximum player limit has been reached')
                     kick(last_joined)
   
                  continue
   
               # Someone joined
               ply_join = srv_join.search(line)
               if ply_join:
                  nick = ply_join.group(1)
                  last_joined = nick.lower()

                  if last_joined in ban_list:
                     kick(last_joined)
                  else:
                     players[last_joined] = dict({"connected": int(time())})
   
                     for line in motd:
                        say('MOTD: %s' % line.replace('$nick', nick))
                     for item in atlogin:
                        try:
                           give(last_joined,item,1)
                        except Mineception, me:
                           say(me.errmsg)
                           
                     if PASSWORD != None \
                      and not admin.match(last_joined) \
                      and not last_joined in whitelist \
                      and not last_joined in temp_admins:
                        players[last_joined]['allowed'] = False
                        say('Please enter the password within %d seconds' % PASSTIME)
                     else:
                        players[last_joined]['allowed'] = True


                  continue
   
               # Someone left
               ply_quit = srv_part.search(line)
               if ply_quit:
                  nick = ply_quit.group(1).lower()
                  if nick in players:
                     players.pop(nick)
   
                  if nick in votekicks:
                     votekicks.pop(nick)

                  if nick in votebans:
                     votebans.pop(nick)

   logmsg('Server shut down')


except KeyboardInterrupt:
   logmsg('Caught Ctrl-C, sending stop command')
   stdin.write("stop\n")

   logmsg('Waiting for server to die')

   if (os.name != 'nt'):
      server.wait() # wait for it to die
