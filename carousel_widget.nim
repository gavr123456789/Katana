import gintro/[gtk4, gobject, gio, adw]
import strformat


type 
  CarouselWithPaths* = ref object of Carousel
    directoriLists*: seq[DirectoryList]

var carouselGb*: CarouselWithPaths


proc createCarousel*(widget: Widget): CarouselWithPaths =
  result = newCarousel(CarouselWithPaths)
  result.interactive = true
  # result.allowMouseDrag = true
  result.allowLongSwipes = true
  result.append (widget)



proc scrollToN*(self: CarouselWithPaths, n: int) = 
  debugEcho "scrollToN: ", n
  self.scrollToFull self.getNthPage n, 500
  
import stores/directory_lists_store
import tables
proc deleteLastPage(self: CarouselWithPaths) = 
  let nPages = self.nPages
  let last = nPages - 1
  debugEcho fmt"deleteLastPage: npages = {npages}"

  assert(last < nPages, fmt"last: {last} !< {nPages}")
  assert(last >= 0, fmt"last: {last} !>= 0")

  let lastWidget = self.getNthPage(last)
  assert lastWidget != nil

  self.remove(lastWidget)
  directoryListsStoreGb.del last
  directoryListsStoreGb.printDirectoryListsStore()


# Принимает номер страницы после который нужно удалить все
proc removeNPagesFrom*(self: CarouselWithPaths, n: int) =
  assert(n < self.nPages)

  for index in n..<self.nPages - 1:
    deleteLastPage(self)
  
