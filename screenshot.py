import os
import sys
import time
import win32gui, win32api, win32con
from PIL import ImageGrab

def focusWindow(title):
	pwin = win32gui.FindWindow(None, title)
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

def toggle_console():
	sendkey(win32con.VK_F9)
	time.sleep(0.1)

def execute_console_command(command):
	toggle_console()
	sendstring(command)
	sendkey(win32con.VK_RETURN)
	time.sleep(0.1)
	toggle_console()

focusWindow("Counter-Strike: Global Offensive")
execute_console_command("status")

img=ImageGrab.grab()
img.save('Screenshot.jpg')
