import gintro/[gtk4, gdk4, gobject, gio, glib]
import hashes, std/with
import widgets/box_with_progress_bar_reveal
import utils/sorts_and_filters

proc inToScroll*(widget: Widget): ScrolledWindow =
  result = newScrolledWindow()
  result.minContentWidth = 240
  result.setPropagateNaturalWidth true
  result.setPropagateNaturalHeight true
  result.vexpand = true
  # result.hexpand = true
  result.child = widget

type
  MultiFilterAndSearchBar = tuple
    fm: MultiFilter
    searchBar: SearchBar

import strutils
proc entryChanged(entry: SearchEntry, mlAndSb: MultiFilterAndSearchBar) = 
  
  mlAndSb.fm.remove(1)

  let ff = newFileFilter()
  let text = entry.text
  if text != "":
    if not("*" in text):
      ff.addPattern("*" & entry.text & "*")
    else:
      ff.addPattern(entry.text)
    mlAndSb.fm.append(ff)
  else:
    ff.addPattern("*")
    mlAndSb.searchBar.searchMode = false
  echo entry.text

# TODO disconnect 
proc inToSearch*(lv: Widget, fm: MultiFilter, revealerOpened: bool) : BoxWithProgressBarReveal =
  result = createBoxWithProgressBarReveal(revealerOpened)
  
  let
    searchBar = newSearchBar()
    entry = newSearchEntry()
  
  echo entry.grabFocus()

  with searchBar:
    connectEntry entry
    # showCloseButton = true
    child = entry
    keyCaptureWidget = result

  entry.connect("search-changed", entryChanged, (fm: fm, searchBar: searchBar))

  entry.halign = Align.center

  result.marginTop = 30 # for scroll
  result.prepend lv
  result.prepend searchBar



  
  
proc openFileInApp*(filePath: string) =
  let file = gio.newGFileForPath(filePath)
  gtk4.showUri(nil, file.uri, gdk4.CURRENT_TIME)


proc hash*(b: gobject.Object): Hash = 
  # create hash from widget pointer
  result =  cast[Hash](cast[uint](b) shr 3)
  echo result

