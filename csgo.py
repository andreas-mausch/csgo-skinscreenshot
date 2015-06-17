import time
import win32api, win32con, win32gui

MAPVK_VK_TO_VSC = 0

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

def keyDown(vk):
	scancode = win32api.MapVirtualKey(vk, MAPVK_VK_TO_VSC)
	win32api.keybd_event(vk, scancode, 0, 0)

def keyUp(vk):
	scancode = win32api.MapVirtualKey(vk, MAPVK_VK_TO_VSC)
	win32api.keybd_event(vk, scancode, win32con.KEYEVENTF_KEYUP, 0)

def sendKey(vk):
	keyDown(vk)
	time.sleep(0.01)
	keyUp(vk)

def sendString(string):
	for c in string:
		cup = c.upper()
		if cup >= 'A' and cup <= 'Z':
			sendKey(ord(cup))
		if cup >= '0' and cup <= '9':
			sendKey(ord(cup))
		if cup == '.':
			sendKey(0xBE) # VK_OEM_PERIOD
		if cup == ' ':
			sendKey(win32con.VK_SPACE)
		if cup == '-':
			sendKey(0xBD) # VK_OEM_MINUS
		if cup == '_':
			keyDown(win32con.VK_SHIFT)
			keyDown(0xBD)
			time.sleep(0.01)
			keyUp(0xBD)
			keyUp(win32con.VK_SHIFT)
			time.sleep(0.01)

def toggleConsole():
	sendKey(win32con.VK_F9)
	time.sleep(0.1)

def executeConsoleCommand(command):
	toggleConsole()
	sendString(command)
	sendKey(win32con.VK_RETURN)
	time.sleep(0.1)
	toggleConsole()
