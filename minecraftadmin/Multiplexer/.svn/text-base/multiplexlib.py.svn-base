import socket
import select
import re

class MinecraftRemoteException(Exception):
    def __init__(self, error):
        self.error = error

    def __str__(self):
        return repr(self.error)

class MinecraftRemote:
    def __init__(self, sockfam, address, port = None, password = None):
        self.socket_family = sockfam
        self.sockaddr      = address
        self.connected     = False
        self.port          = port
        self.password      = password
        self.stop          = False

        if self.socket_family != socket.AF_UNIX and \
           self.port == None:
               raise MinecraftRemoteException('Port can not be empty for TCP')

    def __del__(self):
        self.client_socket.close()

    def connect(self):
        self.initialize_socket()

        try:
            if (self.socket_family == socket.AF_UNIX):
                self.client_socket.connect(self.sockaddr)
            else:
                self.client_socket.connect((self.sockaddr, self.port))
        except socket.error, se:
            raise MinecraftRemoteException(se)
         
        password_line = self.receive() # I love powers of 2.
        if password_line[0] == '-':
            self.send_command(self.password)
 
            reply = self.receive()
            if reply[0] == '-':
                raise MinecraftRemoteException('Bad password')
 
        self.connected = True

    def decide_event(self, line):
        ts_msg = re.compile(
               r'^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}) \[([A-Z]+)\] (.+)$'
               )

        playercount = re.compile('^Player count: (\d+)$')

        self.on_raw(line)

        ts_line = ts_msg.match(line)
        if ts_line:
            # Split it further, but dump results for debug!
            msg_join = re.compile(r'^(.+) \[/(.+):(\d+)] logged in')
            msg_part = re.compile(r'^(.+) lost connection: (.+)$')
            msg_chat = re.compile(r'^<(.+?)> (.+)$')
            msg_ocmd = re.compile(r'^(.+) issued server command: (.+?)( (.+))?$')
            msg_ncmd = re.compile(r'^(.+) tried command /(.+?)( (.+))?$')
            msg_op   = re.compile(r'^Opping (.+)$')
            msg_deop = re.compile(r'^De-opping (.+)$')
            msg_kick = re.compile(r'^Kicking (.+)$')
            msg_ban  = re.compile(r'^Banning (ip )?(.+?)$')
            msg_unban= re.compile(r'^Pardoning (ip )?(.+)$')
            msg_srv  = re.compile(r'^\[Server\] (.+)$')

            message = ts_line.group(3)

            join_msg = msg_join.match(message)
            if join_msg:
                (nick, ip, internal_port) = join_msg.groups()
                self.on_join(nick, ip, int(internal_port))
 
            part_msg = msg_part.match(message)
            if part_msg:
                (nick, reason) = part_msg.groups()
                self.on_part(nick, reason)
 
            chat_msg = msg_chat.match(message)
            if chat_msg:
                (nick, text) = chat_msg.groups()
                self.on_chat(nick, text)
 
            op_msg = msg_ocmd.match(message)
            if op_msg:
                (nick, command, _, args) = op_msg.groups()
                self.on_op_cmd(nick, command, args)
 
            nop_msg = msg_ncmd.match(message)
            if nop_msg:
                (nick, command, _, args) = nop_msg.groups()
                self.on_normal_cmd(nick, command, args)
 
            opped_msg = msg_op.match(message)
            if opped_msg:
                (nick) = opped_msg.groups()
                self.on_op(nick)

            deopped_msg = msg_deop.match(message)
            if deopped_msg:
                (nick) = deopped_msg.groups()
                self.on_deop(nick)
 
            kick_msg = msg_kick.match(message)
            if kick_msg:
                (nick) = kick_msg.groups()
                self.on_kick(nick)

            ban_msg = msg_ban.match(message)
            if ban_msg:
                (is_ip, target) = ban_msg.groups()
 
                if is_ip == None:
                    self.on_ban_nick(target)
                else:
                    self.on_ban_ip(target)

            unban_msg = msg_unban.match(message)
            if unban_msg:
                (is_ip, target) = unban_msg.groups()

                if is_ip == None:
                    self.on_unban_nick(target)
                else:
                    self.on_unban_ip(target)

            srv_msg = msg_srv.match(message)
            if srv_msg:
                (text) = srv_msg.groups()
                self.on_server_message(text)

            return

        pc_line = playercount.match(line)
        if pc_line:
            self.player_count = int(pc_line.group(1))

            return

        self.on_unknown(line)

    def run(self):
        while not self.stop and self.connected:
            try:
                (outset, inset, errset) = select.select([self.client_socket], 
                       [], 
                       [self.client_socket],
                       )
            except select.error, e:
                (errno, error_message) = e.value
                raise MinecraftRemoteException(error_message)

            if self.client_socket in errset:
                raise MinecraftRemoteException('Client socket error flag')

            if self.client_socket in outset:
                line = self.receive()
                self.decide_event(line)

    def stop(self):
        self.stop = True

    def disconnect(self):
        self.connected = False
        self.send_command('.close')

        while True:
            line = self.receive()
            if line[0] == '+':
                break

        self.client_socket.close()

    def send_command(self, cmd):
        cmd = cmd.encode('utf-8')
        self.client_socket.send(cmd + '\r\n')

    def receive(self):
        # TODO: I have a feeling that this is a really inefficient way! Keep it.
        buf = self.client_socket.makefile().readline()
        
        if buf == '':
            raise MinecraftRemoteException('Read error on socket')

        return buf.rstrip()

    def initialize_socket(self):
        if self.socket_family != socket.AF_INET and \
           self.socket_family != socket.AF_INET6 and \
           self.socket_family != socket.AF_UNIX:
               raise MinecraftRemoteException('Unsupported socket family')

        self.client_socket = socket.socket(self.socket_family,
                                           socket.SOCK_STREAM)
        self.client_fd = self.client_socket.makefile()

    def on_raw(self, raw):
        pass

    def on_join(self, nick, ip, port):
        pass

    def on_part(self, nick, reason):
        pass

    def on_chat(self, nick, message):
        pass

    def on_op_cmd(self, nick, cmd, args):
        pass

    def on_normal_cmd(self, nick, cmd, args):
        pass

    def on_op(self, nick):
        pass

    def on_deop(self, nick):
        pass

    def on_kick(self, nick):
        pass

    def on_ban_nick(self, user):
        pass

    def on_ban_ip(self, ip):
        pass

    def on_unban_nick(self, ip):
        pass

    def on_unban_ip(self, ip):
        pass

    def on_server_message(self, msg):
        pass

    def on_unknown(self, line):
        pass

    def say(self, line):
        self.send_command('say %s' % line)

    def kick(self, who):
        self.send_command('kick %s' % who)

    def ban(self, target):
        self.send_command('ban %s' % target)

    def unban(self, target):
        self.send_command('pardon %s' % target)

    def give(self, player, itemid, amount):
        self.send_command('give %s %s %s' % (player, itemid, amount))
