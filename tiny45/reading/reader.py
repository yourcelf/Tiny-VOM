#!/usr/bin/env python
#
# rx.py
#
# rx.py serial_port port_speed
#
# Neil Gershenfeld
# CBA MIT 7/27/07
#
# (c) Massachusetts Institute of Technology 2007
# Permission granted for experimental and personal use;
# license for commercial sale available from MIT.
#

import serial, sys

if (len(sys.argv) != 3):
   print "command line: rx.py serial_port port_speed"
   sys.exit()
port = sys.argv[1]
speed = int(sys.argv[2])

ser = serial.Serial(port,speed)
ser.setDTR()
ser.flushInput()
count = 0
while 1:
   count += 1
   high = ser.read()
   low = ser.read()
   vout = (ord(high) * 256 + ord(low)) / 1024. * 2.56
   ohms = 10000 * vout / (3.3 - vout) #here the 10k is the known resistor and the 3.3 is the ref voltage.

   print '%d: %x %x => RESISTANCE = %f'  %(count, ord(high), ord(low), ohms)
   # print '%d:'%count,x,' (dec %d'%ord(x),' hex %x)'%ord(x)

