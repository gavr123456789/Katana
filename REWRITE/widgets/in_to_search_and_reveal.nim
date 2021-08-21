import gintro/[gtk4, gobject, gio, pango, glib, adw]
import std/with
import ../types
# BOX WITH REVEAL


proc createPage*(revealOpened: bool, directoryList: DirectoryList): Page = 
  result = newBox(Page, Orientation.vertical, 0)
  result.directoryList = directoryList

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

func `showProgressBar=`*(self: Page, revealChild: bool) = 
  self.revealer.revealChild = revealChild


# CB
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

proc inToSearch*(lv: Widget, page: Page, fm: MultiFilter, revealerOpened: bool) : Page =
  # result = createPage(revealerOpened)
  result = page
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