import gintro/[adw, gtk4, gobject, gio]


proc inToScroll*(widget: Widget): ScrolledWindow =
  result = newScrolledWindow()
  # result.minContentWidth = 200
  result.setPropagateNaturalWidth true
  result.vexpand = true
  # result.hexpand = true
  result.child = widget

var currentPage*: int = 0
proc setCurrentPage*(self: Carousel, index: int) = 
  currentPage = index