#!/usr/bin/env python

from subprocess import Popen, PIPE
import ConfigParser
import os
import socket
import select
import sys
import time
import string
from StringIO import StringIO

default_config = """
[remote]
port = 9001
password = bobblefish
socktype = unix
listenaddr = listen_me

[java]
server   = ./minecraft_server.jar
heap_max = 1024M
heap_min = 1024M
gui = false
"""

class Mineremote:
    def __init__(self):
        self.log('Hello, world!')
        self.start_time = int(time.time())

        if not self.load_config():
            self.log('Failed loading the configuration file, this is fatal.')
            exit()
        else:
            self.log('Loaded configuration!')
            self.start_listening()

        try:
            self.start_minecraft_server()
            self.mainloop()
        except Exception, e:
            self.log_exception("__init__() -> mainloop()", e)
        except socket.error, se:
            self.log_exception("__init__()", se)
        except KeyboardInterrupt:
            self.log('Ctrl-C? Really! Maaaaaan...')
            self.server_stdin.write('stop\n')
            self.server.wait()

        self.do_exit()
        self.log('Exit!')

    def log(self, msg):
        print '[REMOTE] %s' % msg

    def log_server(self, msg):
        print '[SERVER] %s' % msg

    def log_exception(self, function, exception):
        self.log('-----------------------')
        self.log('Caught exception!')
        self.log('Function: %s' % function)
        self.log('Exception: %s' % exception)
        self.log('-----------------------')

    def start_listening(self):
        if self.socktype == 'tcp6':
            self.socket_family = socket.AF_INET6
            self.log(' > Socket family: AF_INET6')
        elif self.socktype == 'unix':
            self.socket_family = socket.AF_UNIX
            self.log(' > Socket family: AF_UNIX')
        else:
            self.socket_family = socket.AF_INET
            self.log(' > Socket family: AF_INET')

        if self.socket_family != socket.AF_UNIX:
            self.log(' > Port: %s' % self.port)

        self.server_socket = socket.socket(self.socket_family, socket.SOCK_STREAM)
        self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

        if self.socket_family == socket.AF_UNIX:
            self.server_socket.bind(self.listenaddr)
        else:
            self.server_socket.bind((self.listenaddr, self.port))

        self.server_socket.listen(10)

    def clear_peer(self, peer):
        try:
            if peer in self.clients:
                self.clients.pop(peer)

            if peer in self.outputs:
                self.outputs.remove(peer)

            peer.close()

            self.log('Connection count: %d' % len(self.clients))
        except Exception, e:
            self.log_exception('clear_peer()', e)

    def mainloop(self):
        self.clients = dict({})

        while True:
            try:
                readready, writeready, exceptready = select.select(
                  self.outputs, 
                  self.inputs, 
                  [],
                  1.0)
            except Exception, e:
                self.log_exception("mainloop() > select()", e)
                continue

            if readready == []:
                for i in self.clients:
                    if (time.time() - self.clients[i]['connected']) > 15 and \
                       not self.clients[i]['auth']:
                           self.client_log(i, 'No password within 15 seconds')
                           self.clear_peer(i)
                           break
            else:
                for s in readready:
                    if s == sys.stdin:
                        line = s.readline()
                        self.server_stdin.write('%s' % line)

                    elif s == self.server_socket:
                        (client, address) = self.server_socket.accept()
                        self.outputs.append(client)

                        if self.password:
                            auth = False
                            self.send_peer(client, '- Please enter the password')
                        else:
                            auth = True
                            self.send_peer(client, '+ No password, welcome!')

                        self.clients[client] = {
                              'socket': client,
                              'auth': auth,
                              'connected': int(time.time())
                        }
                        
                        self.client_log(client, 'Connected')
                        self.log('Connection count: %d' % len(self.clients))
  
                    elif s in self.clients:
                        # Data from a client
                        try:
                            buf = s.recv(256)
   
                            if buf == '':
                                # buffer is empty, client died!
                                self.client_log(s, 'Client died')
                                self.clear_peer(s)
                            else:
                                if not self.clients[s]['auth']:
                                    if buf.rstrip() != self.password:
                                        self.send_peer(s,
                                            '- Bad password, sorry >:O')
                                        self.client_log(s, 'Bad password')
                                        self.clear_peer(s)

                                    else:
                                        self.clients[s]['auth'] = True
                                        self.send_peer(s,
                                            '+ Access granted, welcome')
         
                                    continue
      
                                # Valid data!
                                self.client_log(s, 'Data: %s' % buf.rstrip())
      
                                if buf.rstrip() == '.close':
                                    self.client_log(s, 'Disconnected')
                                    self.send_peer(s, '+ Bye')
                                    self.clear_peer(s)
                                elif buf.rstrip() == '.time':
                                    self.client_log(s, 'Uptime requested')
                                    self.send_peer(s, '+ uptime %i'
                                            % self.start_time)
                                else:
                                    self.server_stdin.write('%s\n'
                                        % buf.rstrip())

                        except Exception, e:
                            self.clear_peer(s)
                            self.log_exception('mainloop() > clientdata', e)

                    elif s == self.server.stderr or s == self.server.stdout:
                        line = s.readline().rstrip()
                        if line == '':
                            return True
  
                        self.log_server(line)
  
                        for i in self.clients:
                            if self.clients[i]['auth']:
                                if self.send_peer(i, line) == 0:
                                    self.client_log(i, 'Looks dead, removing')
                                    self.clear_peer(i)

    def do_exit(self):
        for i in self.clients:
            try:
                i.close()
            except:
                pass

        self.server_socket.close()

        if self.socket_family == socket.AF_UNIX:
            os.remove(self.listenaddr)
         
    def client_log(self, client, line):
        if self.socket_family != socket.AF_UNIX:
            (host, port) = socket.getnameinfo(client.getpeername(), 0)
            self.log('[%s:%s] %s' % (host, port, line))
        else:
            self.log('[local #%d] %s' % (client.fileno(), line))

    def send_peer(self, peer, what):
        try:
            return peer.send('%s\r\n' % what)
        except Exception, e:
            self.log_exception('send_peer()', e)
   
    def start_minecraft_server(self):
        self.log('Starting Minecraft server...')
        server_startcmd = [
               "java", 
               "-Xmx%s" % self.java_heapmax, 
               "-Xms%s" % self.java_heapmin,
               "-jar",
               self.server_jar,
               self.java_gui
            ]

        self.log(' > %s' % string.join(server_startcmd, " "))

        self.server = Popen(
              server_startcmd,
              stdout = PIPE,
              stderr = PIPE,
              stdin  = PIPE
            )

        self.outputs = [
              self.server_socket,
              self.server.stderr,
              self.server.stdout,
              sys.stdin
            ]
        self.inputs  = []
        self.server_stdin = self.server.stdin
        self.start_time = int(time.time())

    def load_config(self):
        try:
            config = ConfigParser.ConfigParser()
            config.readfp(StringIO(default_config))
        except ConfigParser.Error, cpe:
            self.log_exception('load_config()', cpe)
            return False

        if os.path.isfile('mineremote.ini'):
            self.log('Found configuration, loading...')

            try:
                config.read('mineremote.ini')
            except ConfigParser.Error, cpe:
                self.log_exception('load_config()', cpe)
                return False
        else:
            self.log('Could not find an existing configuration, creating it...')

            try:
                config_file = open('mineremote.ini', 'w')
                config.write(config_file)
            except Exception, e:
                self.log_exception('load_config()', e)
                return False
            finally:
                config_file.close()

        try:
            self.port     = config.getint('remote', 'port')
            self.password = config.get('remote', 'password')

            if self.password == '':
                self.password = None

            self.socktype   = config.get('remote', 'socktype')
            self.listenaddr = config.get('remote', 'listenaddr')

            self.server_jar = config.get('java', 'server')

            self.java_heapmax = config.get('java', 'heap_max')
            self.java_heapmin = config.get('java', 'heap_min')

            self.java_gui = config.get('java', 'gui').lower()
            if self.java_gui == 'true' or \
               self.java_gui == 'yes' or \
               self.java_gui == '1':
                   self.java_gui = ''
            else:
                self.java_gui = 'nogui'

        except Exception, e:
            self.log_exception('load_config()', e)
            return False

        return True


srv = Mineremote()
