import gintro/[gtk4, gdk4, gobject, gio, glib]
import hashes, std/with
import widgets/box_with_progress_bar_reveal
import main_widgets/carousel_widget

const H_KEY = 43

proc carouselKeyPressedCb(self: EventControllerKey, keyval: int, keycode: int, state: gdk4.ModifierType): bool =
  # echo "keycode = ", keycode
  # echo "keyval = ", keyval
  # echo "gdk4.KEY_h = ", gdk4.KEY_h
  if (state.contains ModifierFlag.control) and (keycode == H_KEY):
    echo "ctrl h pressed"
  return true

# TODO disconnect 
proc inToKeyboardController*(lv: ListView) = 
  let keyPressController = newEventControllerKey()
  lv.addController(keyPressController) 
  keyPressController.connect("key-pressed", carouselKeyPressedCb)


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


type
  MultiFilterAndSearchBar = tuple
    fm: MultiFilter
    searchBar: SearchBar

proc entryChanged(entry: SearchEntry, mlAndSb: MultiFilterAndSearchBar) = 
  
  mlAndSb.fm.remove(1)

  let ff = newFileFilter()
  if entry.text != "":
    ff.addPattern("*" & entry.text & "*")
    mlAndSb.fm.append(ff)
  else:
    ff.addPattern("*")
    mlAndSb.searchBar.searchMode = false
  echo entry.text

# TODO disconnect 
proc inToSearch*(lv: ListView, fm: MultiFilter) : Box =
  result = newBox(Orientation.vertical, 0)

  let
    searchBar = newSearchBar()
    entry = newSearchEntry()

  with searchBar:
    connectEntry entry
    # showCloseButton = true
    child = entry
    keyCaptureWidget = result

  entry.connect("search-changed", entryChanged, (fm: fm, searchBar: searchBar))

  entry.halign = Align.center
  lv.hexpand = true
  # result.hexpand = true
  result.append searchBar
  result.append lv

  
  
proc openFileInApp*(filePath: string) =
  let file = gio.newGFileForPath(filePath)
  gtk4.showUri(nil, file.uri, gdk4.CURRENT_TIME)


proc hash*(b: gobject.Object): Hash = 
  # create hash from widget pointer
  result =  cast[Hash](cast[uint](b) shr 3)
  echo result

