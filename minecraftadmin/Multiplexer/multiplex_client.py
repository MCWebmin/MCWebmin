#!/usr/bin/env python

import socket
import multiplexlib
import time
import sys
import string
import select

ml = multiplexlib.MinecraftRemote(socket.AF_INET,
                                  'localhost',
                                  9001,
                                  'banana')
ml.connect()

if len(sys.argv) > 1:
    ml.send_command('%s' % string.join(sys.argv[1:], " ").decode('utf-8'))
    (sout, _, _) = select.select([ml.client_socket], [], [], 1)

    if sout == []:
        exit()
    else:
        print ml.receive()
        ml.disconnect()
else:
    try:
        while True:
            (sout, sin, sexc) = select.select([sys.stdin, ml.client_socket],
                                              [],
                                              [])
   
            if sout != []:
                for i in sout:
                    if i == sys.stdin:
                        line = sys.stdin.readline()
   
                        if line == '':
                            ml.disconnect()
                            exit()
                        else:
                            ml.send_command(line.rstrip().decode('utf-8'))
                    else:
                        line = ml.receive()
   
                        if line == '':
                            ml.disconnect()
                            exit()
                        else:
                            print line
    except KeyboardInterrupt:
        print 'Exiting.'
    except Exception, e:
        print 'Got exception: ' + e.__str__()

