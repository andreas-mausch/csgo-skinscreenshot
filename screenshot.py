import os
import sys
import time
from PIL import ImageGrab

img=ImageGrab.grab()
img.save('ScreenShot.jpg')
