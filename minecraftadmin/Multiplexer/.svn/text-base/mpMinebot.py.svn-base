#!/usr/bin/python

import multiplexlib
import time

class MinecraftRemoteBot(multiplexlib.MinecraftRemote):
    def __init__(self, sockfam, address, port = None, password = None):
        self.blocks = dict({
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

        self.start_time = int(time())
        self.players = dict({})
        self.votebans = dict({})
        self.votekicks = dict({})

        multiplexlib.MinecraftRemote.__init__(self, sockfam, address, port, password)

    def on_chat(self, nick, message):
        # logmsg('<%s> %s' % (nick, text))
        parts = message.split(" ")
        cmd = parts[0].lower()

        if cmd == '!uptime':
            self.say('The server has been up for %s'
                % (datetime.timedelta(seconds = (int(time()) - self.start_time))))

        elif cmd == '!time':
            self.say('The current server time is: %s' % strftime('%H:%M:%S (%Z)'))

        elif cmd == '!help':
            self.say('The following commands are available:')
            self.say('  !who      - Show connected players')
            self.say('  !uptime   - Display server uptime')
            self.say('  !time     - Display server time')
            self.say('  !votekick - Start a votekick')
            self.say('  !voteban  - Start a voteban')

        elif cmd == '!who':
            self.say('Currently online [%s/%s]:' % (len(self.players),min(int(MAXPLAYER),20)))
            for player in self.players.keys():
                connected = datetime.timedelta(seconds = int(time()) - self.players[player.lower()]['connected'])

                if self.players[player.lower()]['op']:
                    self.say(' - %s (OP) [%s]' % (player, connected))
                else:
                    self.say(' - %s [%s]' % (player, connected))

        elif cmd == '!votekick':
            voter = nick.lower()

            try:
                target = parts[1].lower()

                try:
                    if self.players[target]['op']:
                       self.say('You can\'t votekick admins!')
                       return
                except KeyError:
                    self.say('There is no such player')
                    return

                try:
                    if voter in self.votekicks[target]:
                        self.say('You can\'t vote twice')
                        return
                    else:
                        self.votekicks[target].append(voter)
                except KeyError:
                    self.votekicks[target] = [voter]

                perc = float(len(self.votekicks[target])) * 100 / len(self.players)

                self.say('Voting to kick %s: %.2f%% / %.2f%%'
                    % (target, perc, VOTEKICK_THRESHOLD))

                if perc >= VOTEKICK_THRESHOLD:
                    self.say('Vote passed!')
                    self.kick(target)
                    self.votekicks.pop(target)

            except IndexError:
                self.say('Syntax: !votekick <player>')

        elif cmd == '!voteban':
            voter = nick.lower()

            try:
                target = parts[1].lower()

                try:
                    if self.players[target]['op']:
                       self.say('You can\'t voteban ops!')
                       return
                except KeyError:
                    self.say('There is no such player')
                    return

                try:
                    if voter in self.votebans[target]:
                       self.say('You can\'t vote twice')
                       return
                    else:
                       self.votebans[target].append(voter)

                except KeyError:
                    self.votebans[target] = [voter]

                perc = float(len(self.votebans[target])) * 100 / len(self.players)

                self.say('Voting to ban %s: %.2f%% / %.2f%%'
                    % (target, perc, VOTEBAN_THRESHOLD))

                if perc >= VOTEBAN_THRESHOLD:
                    self.say('Vote passed!')
                    self.ban(target)
                    self.votebans.pop(target)

            except IndexError:
                say('Syntax: !voteban <player>')

if __name__ == '__main__':
    import socket
    server = MinecraftRemoteBot(socket.AF_UNIX, 'minecraft.sock')
    try:
        server.connect()
        server.run()
    except KeyboardInterrupt:
        print 'Exiting...'
    except Exception, e:
        print 'Error: %s' % e
    server.disconnect()