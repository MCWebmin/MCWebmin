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

def ban(user):
   stdin.write('ban %s\n' % user)

def unban(user):
   stdin.write('pardon %s\n' % user)

def give(player, item, amount = 1):
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

   stdin.write('give %s %s %s\n' % (player, item, amount))

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
try:
   SERVER             = config.get('general', 'server')
   ADMINS             = config.get('general', 'admins').split(' ')
   if ADMINS[0] == '':
      del(ADMINS[0])

   map(lambda admin: admin.lower(), ADMINS)

   WHITELIST          = config.get('general', 'whitelist').split(' ')
   if WHITELIST[0] == '':
      del(WHITELIST[0])

   map(lambda white: white.lower(), WHITELIST)

   HEAPMEM_MAX        = config.get('java', 'heapmem_max')
   HEAPMEM_MIN        = config.get('java', 'heapmem_min')
   MAXPLAYER          = config.getint('general', 'max_players')
   VOTEBAN_THRESHOLD  = config.getint('general', 'voteban_threshold')
   VOTEKICK_THRESHOLD = config.getint('general', 'votekick_threshold')
   PASSWORD           = config.get('general', 'password')
   if PASSWORD == '':
      PASSWORD = None

   PASSTIME           = config.getint('general', 'password_timeout')
   MOTD               = config.get('general', 'motd').split('|')
   ATLOGIN            = config.get('general', 'atlogin').split(' ')
   if ATLOGIN[0] == '':
      del(ATLOGIN[0])
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
chatmessage = re.compile('^\d.+ \d.+ .INFO. <(.+?)> (.+)$')
srv_list_response = re.compile('Connected players: (.+)')
srv_playercount   = re.compile('^Player count: (\d+)')
srv_join          = re.compile('^\d.+ \d.+ .INFO. (.+?) \[.+?\] logged in')
srv_part          = re.compile('^\d.+ \d.+ .INFO. (.+?) lost connection')
srv_cmd           = re.compile('^\d.+ \d.+ .INFO. (.+?) issued server command: (.+)')
srv_opped         = re.compile('^\d.+ \d.+ .INFO. Opping (.+)$')
srv_deopped       = re.compile('^\d.+ \d.+ .INFO. De-opping (.+)$')

def chat(nick, text):
   # logmsg('<%s> %s' % (nick, text))
   parts = text.split(" ")
   cmd = parts[0].lower()

   if cmd == '!uptime':
      uptime = int(time()) - started
      say('The server has been up for %s' 
            % (datetime.timedelta(seconds = uptime)))

   elif cmd == '!time':
      t = strftime('%H:%M:%S (%Z)')
      say('The current server time is: %s' % t)
   
   elif cmd == '!help':
      say('The following commands are available:')
      say('  !uptime   - Display server uptime')
      say('  !time     - Display server time')
      say('  !votekick - Start a votekick')
      say('  !voteban  - Start a voteban')

   elif cmd == '!who':
      stdin.write('list\n')
   
   elif cmd == '!votekick':
      voter = nick.lower()
  
      try:
         target = parts[1].lower()
  
         try:
            if players[target]['op']:
               say('You can\'t votekick admins!')
               return
         except KeyError:
            say('There is no such player')
            return
  
         try:
            if voter in votekicks[target]:
               say('You can\'t vote twice')
               return
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

   elif cmd == '!voteban':
      voter = nick.lower()

      try:
         target = parts[1].lower()
         
         try:
            if players[target]['op']:
               say('You can\'t voteban ops!')
               return
         except KeyError:
            say('There is no such player')
            return

         try:
            if voter in votebans[target]:
               say('You can\'t vote twice')
               return
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



def command(nick, text):
   if players[nick.lower()]['op']:
      logmsg('Player "%s" issued: %s' % (nick, text))
      parts = text.split(" ")
      cmd = parts[0].lower()

      if cmd == 'white':
         try:
            global WHITELIST
            target = parts[1]
   
            if not target.lower() in WHITELIST:
               WHITELIST.append(target.lower())
   
               try:
                  config.set('general', 'WHITELIST', string.join(WHITELIST, ' '))
                  config_file = open('minebot.ini', 'w')
                  config.write(config_file)
                  say('Added \'%s\' to whitelist' % target)
               except: 
                  say('Could not save user on the whitelist!')
               
                  config_file.close()
            else:
               say('User already on whitelist!')

         except IndexError:
            pass # Ignore.

      elif cmd == 'unwhite':
         try:
            global WHITELIST
            target = parts[1]

            if target.lower() in WHITELIST:
               WHITELIST.remove(target.lower())

               try:
                  config.set('general', 'WHITELIST', string.join(WHITELIST, ' '))
                  config_file = open('minebot.ini', 'w')
                  config.write(config_file)
                  say('Removed \'%s\' from whitelist' % target)
               except:
                  say('Could not save the whitelist')
               
                  config_file.close()
            else:
               say('User not on whitelist')
         except Exception as e:
            print e

      elif cmd == 'giveall':
         try:
            items = string.join(parts[2:],'').replace(' ','').split(',')
            amount = parts[1]
            
            for item in items:
               try:
                  for target in players:
                     give(target, item, amount)
               except Mineception as me:
                  say(me.errmsg)
         except IndexError:
            pass
             



      elif cmd == 'atlogin':
         try:
            global ATLOGIN
            ATLOGIN = string.join(parts[1:],'').replace(' ','').split(',')
            
            try:
               config.set('general','atlogin',string.join(ATLOGIN,' '))
               config_file = open('minebot.ini', 'w')
               config.write(config_file)
               config_file.close()
            except:
               say('Failed to write config file on %s...' % parts[0], is_console)
         except Exception as e:
            print e

      elif cmd == 'motd':
         try:
            global MOTD
            MOTD = string.join(parts[1:], " ").split("|")

            try:
               config.set('general', 'motd', string.join(MOTD, '|'))
               config_file = open('minebot.ini', 'w')
               config.write(config_file)
               config_file.close()
            except:
               logmsg('Failed to write config file on %s...' % parts[0])

            say('MOTD changed')
         except Exception as e:
            print e

      elif cmd == 'tp':
         try:
            payloads = string.join(parts[1:-1],' ').replace(',',' ').split(' ')
            target = parts[len(parts)-1]
         except IndexError:
            pass
         else:
            for payload in payloads:
               stdin.write('tp %s %s\n' % (payload, target))
   else:
      say('Commands can only be executed by an OP.')

def console(line):
   logmsg('[CONSOLE] %s' % line)
   stdin.write('%s\n' % line)

def debug():
   print players

def saveadmins():
   a = []

   for p in players:
      if players[p]['op']:
         a.append(p)

   try:
      config.set('general', 'admins', string.join(a, ' '))
      config_file = open('minebot.ini', 'w')
      config.write(config_file)
      config_file.close()
   except:
      logmsg('Failed to save admins to configuration file')

try:
   current_players = 0
   started         = int(time())

   votekicks       = dict({})
   votebans        = dict({})

   players         = dict({})

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
         # No activity since X seconds where X = ----------------------------^^
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
               # Console command, just process that
               is_console = True
               console(line)
            else:
               # Not a console command, decide what kind it is and take action
               is_console = False
               logsrv(line)

               # Chat
               pl_chat = chatmessage.match(line)
               if pl_chat:
                  nick = pl_chat.group(1)
                  text = pl_chat.group(2)
                  
                  if not players[nick.lower()]['allowed'] and PASSWORD != None:
                     if text == PASSWORD:
                        say('Access granted!')
                        players[nick.lower()]['allowed'] = True
                     else:
                        say('Access denied!')
 
                  chat(nick, text)

                  continue
               
               # Command executed
               pl_cmd = srv_cmd.match(line)
               if pl_cmd:
                  nick = pl_cmd.group(1)
                  text = pl_cmd.group(2)

                  command(nick, text)

                  continue
      
               # Server responded with the userlist, parse and spread the news
               who_resp = srv_list_response.search(line)
               if who_resp:
                  players_on = who_resp.group(1).split(", ")
                  try:
                     say('Currently online [%s/%s]:' % (len(players_on),min(int(MAXPLAYER),20)))
                  except ValueError:
                     say('Currently online [?/?]:')
   
                  for i in players_on:
                     try:
                        contime = int(time()) - players[i.lower()]['connected']
                        connected = datetime.timedelta(seconds = contime)
   
                        if players[i.lower()]['op']:
                           say(' - %s (OP) [%s]\n' % (i, connected))
                        else:
                           say(' - %s [%s]' % (i, connected))
   
                     except KeyError:
                        logmsg('Unlisted user: %s' % (i))
   
                  continue
   
               # Server told us the player count
               # NEEDS NO TOUCHING
               ply_rsp = srv_playercount.search(line)
               if ply_rsp:
                  current_players = int(ply_rsp.group(1))
   
                  if current_players > MAXPLAYER and not player[last_joined]['op']:
                     say('Maximum player limit has been reached')
                     kick(last_joined)
   
                  continue
 
               # Someone joined
               ply_join = srv_join.search(line)
               if ply_join:
                  nick = ply_join.group(1)
                  last_joined = nick.lower()
 
                  # Save connecion time and initialize player dictionary
                  players[last_joined] = dict(
                           { 'connected': int(time()) }
                        )
 
                  # White list?
                  if last_joined in WHITELIST or last_joined in ADMINS:
                     players[last_joined]['allowed'] = True
                  else:
                     players[last_joined]['allowed'] = False
 
                  # Decide if the player is an admin
                  if last_joined in ADMINS:
                     stdin.write("op %s\n" % last_joined)
                     players[last_joined]['op'] = True
                     logmsg('Admin %s has logged in' % last_joined)
                  else:
                     players[last_joined]['op'] = False
   
                  for line in MOTD:
                     say('%s' % line.replace('$nick', nick))
  
                  for item in ATLOGIN:
                     try:
                        give(last_joined, item)
                     except Mineception as me:
                        say(me.errmsg)
                            
                  if PASSWORD != None and not players[last_joined]['allowed']:
                     say('Please enter the password within %d seconds'
                          % PASSTIME)
  
                  debug()
 
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

                  debug()

                  continue

               # Someone got opped
               ply_op = srv_opped.search(line)
               if ply_op:
                  nick = ply_op.group(1).lower()
                  players[nick]['op'] = True
               
                  saveadmins() 
                  debug()

                  continue

               # And someone got deopped
               ply_deop = srv_deopped.search(line)
               if ply_deop:
                  nick = ply_deop.group(1).lower()
                  players[nick]['op'] = False
                  
                  saveadmins()
                  debug()
 
                  continue

   logmsg('Server shut down')


except KeyboardInterrupt:
   logmsg('Caught Ctrl-C, sending stop command')
   stdin.write("stop\n")

   logmsg('Waiting for server to die')

   if (os.name != 'nt'):
      server.wait() # wait for it to die
