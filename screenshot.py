import os
import sys
import time
import win32gui, win32api, win32con
from PIL import ImageGrab
from pykeyboard import PyKeyboard
import win32com.client

pwin = win32gui.FindWindow(None, 'Counter-Strike: Global Offensive')
win32gui.BringWindowToTop(pwin)
win32gui.SetForegroundWindow(pwin)

def sendkey(vk):
	MAPVK_VK_TO_VSC = 0
	scancode = win32api.MapVirtualKey(vk, MAPVK_VK_TO_VSC);
	win32api.keybd_event(vk, scancode, 0, 0);
	time.sleep(0.01)
	win32api.keybd_event(vk, scancode, win32con.KEYEVENTF_KEYUP, 0);

def sendstring(string):
	for c in string:
		sendkey(ord(c.upper()))

sendkey(win32con.VK_F9)
time.sleep(0.1)
sendkey(ord('H'))
sendstring("Test")
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
