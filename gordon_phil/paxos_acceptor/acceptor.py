#!/usr/bin/python

from messenger import Messenger
from os        import getpid

messenger = Messenger('http://paxos.leedscodedojo.org.uk/live/a/gp-' + str(getpid()).zfill(5))

def sendMessage(msg):
  print "Sending: " + str(msg)
  messenger.postMessage(msg)

name = "brian"
lastAcceptedTimePeriod = 0
lastAcceptedValue = None
sentAccepted = False

lastPromisedTimePeriod = 0

while True:
  currMessage = messenger.getNextMessage()
  print "Received: " + str(currMessage)

  timePeriod = currMessage['timePeriod']

  if currMessage['type'] == 'prepare':
    msg = {'type':'promised', 'timePeriod':timePeriod, 'by':name}

    if not sentAccepted:
      if timePeriod > lastPromisedTimePeriod:
        lastPromisedTimePeriod = timePeriod
    
      msg['haveAccepted'] = False

      sendMessage(msg)
 
    elif lastAcceptedTimePeriod < timePeriod:
      if timePeriod > lastPromisedTimePeriod:
        lastPromisedTimePeriod = timePeriod

      msg['lastAcceptedTimePeriod'] = lastAcceptedTimePeriod
      msg['lastAcceptedValue'] = lastAcceptedValue

      sendMessage(msg)

  elif currMessage['type'] == 'proposed':
    
    if lastPromisedTimePeriod <= timePeriod and \
      lastAcceptedTimePeriod < timePeriod:
      
      lastAcceptedValue = currMessage['value']
      lastAcceptedTimePeriod = timePeriod

      msg = {'type':'accepted','timePeriod':timePeriod, 'by':name, 'value':lastAcceptedValue}
      sendMessage(msg)
      sentAccepted = True

  else:
    print "ERROR: Unknown message"

  ''' process currMessage as described, possibly sending back some other messages, e.g.:

  messenger.postMessage({'type':'messageType','timePeriod':timePeriod})
  '''
