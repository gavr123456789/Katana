import gintro/[adw, gtk4, gdk4, gobject, gio]
import carousel_widget
import hashes
proc inToScroll*(widget: Widget): ScrolledWindow =
  result = newScrolledWindow()
  # result.minContentWidth = 200
  result.setPropagateNaturalWidth true
  result.vexpand = true
  # result.hexpand = true
  result.child = widget

type 
  BoxWithProgressBarReveal = ref object of Box
    revealer: Revealer

proc createBoxWithProgressBarReveal(revealOpened: bool): BoxWithProgressBarReveal = 
  result = newBox(BoxWithProgressBarReveal, Orientation.vertical, 0)
  let
    reveal = newRevealer() 
    progressBar = newProgressBar()
  progressBar.fraction = 1.0
  
  result.revealer = reveal
  reveal.transitionType = RevealerTransitionType.swingUp
  reveal.transitionDuration = 200
  reveal.revealChild = revealOpened
  reveal.setChild progressBar
  result.append reveal

  result.vexpand = true

func `revealChild=`*(self: BoxWithProgressBarReveal, revealChild: bool) = 
  self.revealer.revealChild = revealChild

proc inToBox*(widget: Widget, revealOpened: bool): BoxWithProgressBarReveal =
  result = createBoxWithProgressBarReveal(revealOpened)
  
  result.prepend widget
  
  
proc openFileInApp(fileUri: string, window: gtk4.Window ) =
  let file = gio.newGFileForPath(fileUri)
  gtk4.showUri(window, file.uri, gdk4.CURRENT_TIME)


proc hash*(b: gobject.Object): Hash = 
  # create hash from widget pointer
  result =  cast[Hash](cast[uint](b) shr 3)
  echo result

var currentPageGb*: int = 0
proc setCurrentPage*(self: CarouselWithPaths, index: int) = 
  echo index
  assert self.getNthPage(currentPageGb).BoxWithProgressBarReveal != nil
  assert self.getNthPage(index).BoxWithProgressBarReveal != nil

  self.getNthPage(currentPageGb).BoxWithProgressBarReveal.revealChild = false
  self.getNthPage(index).BoxWithProgressBarReveal.revealChild = true

  currentPageGb = index

