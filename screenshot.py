from PIL import ImageGrab

def saveScreenshot(name):
	img=ImageGrab.grab()
	img.save(name)
