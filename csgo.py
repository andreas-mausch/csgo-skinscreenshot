import time
import win32api, win32con, win32gui

def focusWindow(title):
	window = win32gui.FindWindow(None, title)
	if window is 0:
		return False
	win32gui.BringWindowToTop(window)
	win32gui.SetForegroundWindow(window)
	return True

def focusCounterStrikeWindow():
	if not focusWindow("Counter-Strike: Global Offensive"):
		print("Couldn't find Counter-Strike GO")
		quit()

def sendKey(vk):
	MAPVK_VK_TO_VSC = 0
	scancode = win32api.MapVirtualKey(vk, MAPVK_VK_TO_VSC)
	win32api.keybd_event(vk, scancode, 0, 0)
	time.sleep(0.01)
	win32api.keybd_event(vk, scancode, win32con.KEYEVENTF_KEYUP, 0)

def sendString(string):
	for c in string:
		sendKey(ord(c.upper()))

def toggleConsole():
	sendKey(win32con.VK_F9)
	time.sleep(0.1)

def executeConsoleCommand(command):
	toggleConsole()
	sendString(command)
	sendKey(win32con.VK_RETURN)
	time.sleep(0.1)
	toggleConsole()
