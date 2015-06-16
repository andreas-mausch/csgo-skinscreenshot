import os
import sys
import time
import win32gui, win32api
from PIL import ImageGrab
from pykeyboard import PyKeyboard
import win32com.client

pwin = win32gui.FindWindow(None, 'Counter-Strike: Global Offensive')
win32gui.BringWindowToTop(pwin)
win32gui.SetForegroundWindow(pwin)

# Works
win32api.keybd_event(0x78, 0x43, 0, 0);
time.sleep(.05)
win32api.keybd_event(0x78, 0x43, win32con.KEYEVENTF_KEYUP, 0);

# Doesn't work
#shell = win32com.client.Dispatch("WScript.Shell")
#shell.SendKeys('{F9}')
#shell.SendKeys('ashasjdo')

# Doesn't work
#keyboard = PyKeyboard()
#keyboard.tap_key(keyboard.function_keys[9])
#keyboard.type_string('Hello, World!')
#keyboard.press_key('W')
#time.sleep(2)
#keyboard.release_key('W')

time.sleep(0.2)

img=ImageGrab.grab()
img.save('Screenshot.jpg')
