import gintro/[gtk4, gobject, gio, adw]
import strformat
import ../widgets/box_with_progress_bar_reveal

type 
  CarouselWithPaths* = ref object of Carousel
    # directoryLists*: seq[DirectoryList] 
    currentPage: int

var carouselGb*: CarouselWithPaths

# TODO добавить функции получения listView с нной страницы, и функции получения файла пути с каждой страцниы, заменить все
# использования дириктори лист стор на эти функции
###
proc getCurrentPageWidget*(self: CarouselWithPaths): Widget = 
  assert self.nPages >= 0
  result = self.getNthPage(self.currentPage)

proc getNPageWidget*(self: CarouselWithPaths, n: int): Widget = 
  assert self.nPages >= 0
  result = self.getNthPage(n)
###
proc getCurrentPageBoxWithProgressBar*(self: CarouselWithPaths): BoxWithProgressBarReveal = 
  assert self.nPages >= 0
  let boxWithProgressBar = self.getNthPage(self.currentPage).BoxWithProgressBarReveal
  assert boxWithProgressBar != nil
  result = boxWithProgressBar

proc getNthPageBoxWithProgressBar*(self: CarouselWithPaths, n: int): BoxWithProgressBarReveal = 
  assert self.nPages >= 0
  let boxWithProgressBar = self.getNthPage(n).BoxWithProgressBarReveal
  assert boxWithProgressBar != nil
  result = boxWithProgressBar
###
proc getCurrentPageNumber*(self: CarouselWithPaths): int = 
  result = self.currentPage

proc createCarousel*(widget: Widget): CarouselWithPaths =
  result = newCarousel(CarouselWithPaths)
  result.interactive = true
  # result.allowMouseDrag = true
  result.allowLongSwipes = true
  result.append (widget)

proc setCurrentPage2*(self: CarouselWithPaths, index: int) = 
  self.getCurrentPageBoxWithProgressBar.showProgressBar = false
  self.getNthPageBoxWithProgressBar(index).showProgressBar = true


proc gotoPage*(self: CarouselWithPaths, index: int) = 
  setCurrentPage2(self, index)
  debugEcho "scrollToN: ", index
  self.currentPage = index
  self.scrollToFull self.getNthPage index, 500



# proc scrollToN*(self: CarouselWithPaths, n: int) = 
#   debugEcho "scrollToN: ", n
#   self.scrollToFull self.getNthPage n, 500
  
import ../stores/directory_lists_store
# import ../stores/open_files_store
import tables

proc deleteLastPage(self: CarouselWithPaths) = 
  assert(self.nPages >= 0)
  let nPages = self.nPages
  let lastPageIndex = nPages - 1
  debugEcho fmt"deleteLastPage: npages = {npages}"

  assert(lastPageIndex < nPages, fmt"last: {lastPageIndex} !< {nPages}")
  assert(lastPageIndex >= 0, fmt"last: {lastPageIndex} !>= 0")

  let lastWidget = self.getNthPage(lastPageIndex)
  assert lastWidget != nil

  #TODO delete lastPage listModel first
  self.remove(lastWidget)
  
  # directoryListsStoreGb[lastPageIndex] = nil
  directoryListsStoreGb.del lastPageIndex
  # directoryListsStoreGb.printDirectoryListsStore()

  # closeFilesOnPage(lastPageIndex)


  



# Принимает номер страницы после который нужно удалить все
# n - page index, after what all need to be deleted
proc removeNPagesAfter*(self: CarouselWithPaths, n: int) =
  # если мы и удаляем все после текущей страницы, то делать на нее готу не надо
  if self.currentPage != n:
    self.gotoPage(n)
    self.currentPage = n
  assert(n < self.nPages)
  assert(self.currentPage >= 0)
  debugEcho "Deleting pages from ", n,  " to ",  self.nPages - 1
 

  for index in n..<self.nPages - 1:
    debugEcho "now trying to delete page #", index
    deleteLastPage(self)
  
