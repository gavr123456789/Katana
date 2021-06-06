import gintro/[gtk4, gobject, gio, adw]
import std/with

var carouselGb*: Carousel


type
  CustomData* = object
    carousel*: Carousel
    path*: string

proc createCarousel*(widget: Widget): Carousel =
  result = newCarousel()
  result.interactive = true
  result.allowMouseDrag = true
  # for i in 0 ..< N_PAGES:
  result.append (widget)

proc openFileCb*(self: Button, path: string ) =
  
  echo path
  