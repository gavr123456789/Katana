import gintro/[gtk4, gobject, gio, adw]
import std/with

proc packToBoxRow(widget: Widget): Widget {.inline.} = 
  let
    a = newListBoxRow()
  a.setChild(widget)
  return a


proc createCarousel*(widget: Widget): Carousel =
  result = newCarousel()
  result.interactive = true
  result.allowMouseDrag = true
  # for i in 0 ..< N_PAGES:
  result.append (widget)