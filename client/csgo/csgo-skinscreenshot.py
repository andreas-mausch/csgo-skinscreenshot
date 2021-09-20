import csgowin32
import os.path
import pika
import screenshot
import time
from .. import config
from .. import csgo
from .. import messagequeue

def saveScreenshot(skin, view):
  screenshot.saveScreenshot(csgo.screenshotFilename(skin, view), csgo.thumbnailFilename(skin, view))

def takeScreenshot(skin):
  csgowin32.focusCounterStrikeWindow()
#  dust2
#  csgowin32.executeConsoleCommand("sm_teleport -1548 -339 195 0 104 0")
#  screenshotmap_crashz_v2
#  csgowin32.executeConsoleCommand("sm_teleport -103 -1161 -200 0 -74 0")
  csgowin32.openConsole()
  csgowin32.executeConsoleCommand("sm_teleport -103 -1161 -200 -86 -114 0")
  csgowin32.executeConsoleCommand("sm_changeskin " + skin)
  csgowin32.executeConsoleCommand("clear")
  csgowin32.executeConsoleCommand("say " + skin)
  csgowin32.closeConsole()
  time.sleep(3)
  saveScreenshot(skin, "playside")
  csgowin32.sendKey(ord('F'))
  time.sleep(2)
  saveScreenshot(skin, "inspect")

def screenshotsExists(skin):
  return os.path.isfile(csgo.screenshotFilename(skin, "playside")) and os.path.isfile(csgo.screenshotFilename(skin, "inspect"))

def callback(ch, method, properties, body):
  skin = body.decode("utf-8")
  print ("Received ", skin)
  if not screenshotsExists(skin):
    takeScreenshot(skin)
  ch.basic_ack(delivery_tag = method.delivery_tag)

messagequeue.start_consuming(callback)
