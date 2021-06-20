import gintro/[adw, gtk4, gobject, gio]
import carousel_widget
import hashes
proc inToScroll*(widget: Widget): ScrolledWindow =
  result = newScrolledWindow()
  # result.minContentWidth = 200
  result.setPropagateNaturalWidth true
  result.vexpand = true
  # result.hexpand = true
  result.child = widget

proc hash*(b: gobject.Object): Hash = 
  # create hash from widget pointer
  result =  cast[Hash](cast[uint](b) shr 3)
  echo result

var currentPageGb*: int = 0
proc setCurrentPage*(self: CarouselWithPaths, index: int) = 
  currentPageGb = index

