import gintro/[gtk4, gobject, gio, pango, glib, adw]
import std/with

# BOX WITH REVEAL
type 
  BoxWithProgressBarReveal* = ref object of Box
    revealer*: Revealer

proc createBoxWithProgressBarReveal*(revealOpened: bool): BoxWithProgressBarReveal = 
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

func `showProgressBar=`*(self: BoxWithProgressBarReveal, revealChild: bool) = 
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