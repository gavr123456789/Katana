import gintro/[gtk4, gobject, gio, adw]
import strformat
import box_with_progress_bar_reveal

type 
  CarouselWithPaths* = ref object of Carousel
    directoryLists*: seq[DirectoryList] 
    currentPage: int

var carouselGb*: CarouselWithPaths

proc getCurrentPageWidget*(self: CarouselWithPaths): Widget = 
  result = self.getNthPage(self.currentPage)

proc getCurrentPageNumber*(self: CarouselWithPaths): int = 
  result = self.currentPage

proc createCarousel*(widget: Widget): CarouselWithPaths =
  result = newCarousel(CarouselWithPaths)
  result.interactive = true
  # result.allowMouseDrag = true
  result.allowLongSwipes = true
  result.append (widget)

proc gotoPage*(self: CarouselWithPaths, index: int) = 
  echo index
  
  assert self.getCurrentPageWidget().BoxWithProgressBarReveal != nil
  assert self.getNthPage(index).BoxWithProgressBarReveal != nil

  self.getCurrentPageWidget().BoxWithProgressBarReveal.showProgressBar = false
  self.getNthPage(index).BoxWithProgressBarReveal.showProgressBar = true

  self.currentPage = index



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

  #TODO delete last listModel first
  self.remove(lastWidget)
  directoryListsStoreGb[last] = nil
  directoryListsStoreGb.del last
  directoryListsStoreGb.printDirectoryListsStore()

# Принимает номер страницы после который нужно удалить все
proc removeNPagesFrom*(self: CarouselWithPaths, n: int) =
  self.currentPage -= n
  setCurrentPage
  assert(n < self.nPages)
  for index in n..<self.nPages - 1:
    deleteLastPage(self)
  
