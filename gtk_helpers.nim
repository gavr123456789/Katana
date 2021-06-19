import gintro/[adw, gtk4, gobject, gio]
import carousel_widget

proc inToScroll*(widget: Widget): ScrolledWindow =
  result = newScrolledWindow()
  # result.minContentWidth = 200
  result.setPropagateNaturalWidth true
  result.vexpand = true
  # result.hexpand = true
  result.child = widget

var currentPageGb*: int = 0
proc setCurrentPage*(self: CarouselWithPaths, index: int) = 
  currentPageGb = index