import gintro/[gtk4, gobject, gio, adw]
import std/with

var carouselGb*: Carousel


type
  CustomData* = object
    carousel*: Carousel
    path*: string

  PathAndNum* = tuple
    num: int
    path: string

proc createCarousel*(widget: Widget): Carousel =
  result = newCarousel()
  result.interactive = true
  result.allowMouseDrag = true
  # for i in 0 ..< N_PAGES:
  result.append (widget)
  # После этой вызывать move

proc openFileCb*(self: Button, pathAndNum: PathAndNum ) =
  
  echo pathAndNum.path
  # Создать page с сурсом path
  # создать карусель с этим
  