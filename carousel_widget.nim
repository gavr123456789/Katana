import gintro/[gtk4, gobject, gio, adw]
import strformat

var carouselGb*: Carousel


proc createCarousel*(widget: Widget): Carousel =
  result = newCarousel()
  result.interactive = true
  # result.allowMouseDrag = true
  result.allowLongSwipes = true
  result.append (widget)



proc scrollToN*(self: Carousel, n: int) = 
  debugEcho "scrollToN: ", n
  self.scrollToFull self.getNthPage n, 500
  

proc deleteLastPage(self: Carousel) = 
  let nPages = self.nPages
  let last = nPages - 1
  debugEcho fmt"deleteLastPage: npages = {npages}"

  assert(last < nPages, fmt"last: {last} !< {nPages}")
  assert(last >= 0, fmt"last: {last} !>= 0")

  let lastWidget = self.getNthPage(last)
  assert lastWidget != nil

  self.remove(lastWidget)

# Принимает номер страницы после который нужно удалить все
proc removeNPagesFrom*(self: Carousel, n: int) =
  assert(n < self.nPages)

  for index in n..<self.nPages - 1:
    deleteLastPage(self)
  
