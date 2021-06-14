import gintro/[gtk4, gobject, gio, adw]


var carouselGb*: Carousel




proc createCarousel*(widget: Widget): Carousel =
  result = newCarousel()
  result.interactive = true
  result.allowMouseDrag = true
  # for i in 0 ..< N_PAGES:
  result.append (widget)
  # После этой вызывать move

proc removeLastNPages*(self: Carousel, n: int) =
  assert(n < self.getNPages())

  let howMany = self.getNPages() - n
  for index in 0..howMany:
    let last = self.getNPages() - 1
    let lastWidget = self.getNthPage(last)
    self.remove(lastWidget)
    
    
  