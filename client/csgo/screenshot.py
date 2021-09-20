from PIL import Image, ImageGrab

def saveScreenshot(name, thumbnailName):
  image = ImageGrab.grab()
  image.save(name, 'JPEG', subsampling=0, quality=90)

  thumbnailSize = 192, 192
  image.thumbnail(thumbnailSize, Image.ANTIALIAS)
  image.save(thumbnailName, 'JPEG', subsampling=0, quality=75)
