import gintro/[gtk4, gdk4, gobject, gio]
import hashes
import box_with_progress_bar_reveal

proc inToScroll*(widget: Widget): ScrolledWindow =
  result = newScrolledWindow()
  # result.minContentWidth = 200
  result.setPropagateNaturalWidth true
  result.vexpand = true
  # result.hexpand = true
  result.child = widget
  


proc inToBox*(widget: Widget, revealOpened: bool): BoxWithProgressBarReveal =
  result = createBoxWithProgressBarReveal(revealOpened)
  result.marginTop = 30 # for scroll
  result.prepend widget
  
  
proc openFileInApp*(filePath: string) =
  let file = gio.newGFileForPath(filePath)
  gtk4.showUri(nil, file.uri, gdk4.CURRENT_TIME)


proc hash*(b: gobject.Object): Hash = 
  # create hash from widget pointer
  result =  cast[Hash](cast[uint](b) shr 3)
  echo result

proc gintro_hack*(f: auto, p: auto) =
  f.impl = p
  f.ignoreFinalizer = true # fast hack, we would use a {.global.} var in the macro. Or maybe do in a other way?



proc createBoxWithPlayer*(path: string): Box =
  result = newBox(Orientation.horizontal, 0)
  # result.homogeneous = true
  let
    mediaFile = newMediaFileForFilename(path)
    mediaControls = newMediaControls(mediaFile)
  result.append mediaControls
  mediaControls.hexpand = true