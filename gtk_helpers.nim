import gintro/[gtk4, gdk4, gobject, gio, glib]
import hashes, std/with
import widgets/box_with_progress_bar_reveal
import utils/sorts_and_filters

# const H_KEY = 43

# proc carouselKeyPressedCb(self: EventControllerKey, keyval: int, keycode: int, state: gdk4.ModifierType): bool =
#   # echo "keycode = ", keycode
#   # echo "keyval = ", keyval
#   # echo "gdk4.KEY_h = ", gdk4.KEY_h
#   if (state.contains ModifierFlag.control) and (keycode == H_KEY):
#     echo "ctrl h pressed"
#   return true

# TODO disconnect 
# proc inToKeyboardController*(lv: ListView) = 
#   let keyPressController = newEventControllerKey()
#   lv.addController(keyPressController) 
#   keyPressController.connect("key-pressed", carouselKeyPressedCb)

let HidefilterGb = newBoolFilter()
HidefilterGb.expression = newCClosureExpression(g_boolean_get_type(), nil, 0, nil, cast[Callback](filterHidden22), nil, nil)

proc ctrlHPressed(widget: ptr Widget00; args: ptr glib.Variant00; fm: MultiFilter): bool {.cdecl.} =

  let mfAsList = fm.listModel()
  let filtersCount = mfAsList.getNItems()
  echo "Filters count = ", filtersCount

  if filtersCount >= 1:
    fm.remove(0)
    fm.remove(1)
  else: 
    fm.append HidefilterGb

  echo "ctrl h pressed"
  false

import main_widgets/row_widget
proc ctrlAPressed(widget: ptr Widget00; args: ptr glib.Variant00; lv: ListView): bool {.cdecl.} =
  let lm = cast[ListModel](lv.model)
  let nItems = lm.getNItems

  if nItems > 0:
    let 
      item = lm.getItem(0)
      listItem = cast[FileInfo](item)
      # row = listitem.getChild().FileRow

    echo "SASASASASA", listItem.name
    listItem.name = "sas"

  false


# adding ctrl h and ctrl a
proc inToShortcutController*(lv: ListView, fm: MultiFilter) = 
  echo "inToShortcutController"
  let shortcutController = newShortcutController()
  lv.addController(shortcutController) 
  let ctrlh = newCallbackAction(cast[ShortcutFunc](ctrlHPressed), cast[pointer](fm), nil )
  shortcutController.addShortcut(newShortcut(shortcutTriggerParseString("<Control>H"), ctrlh))

  # itemType.

  let ctrla = newCallbackAction(cast[ShortcutFunc](ctrlAPressed), cast[pointer](lv), nil )
  shortcutController.addShortcut(newShortcut(shortcutTriggerParseString("<Control>A"), ctrla))


proc inToScroll*(widget: Widget): ScrolledWindow =
  result = newScrolledWindow()
  result.minContentWidth = 240
  result.setPropagateNaturalWidth true
  result.setPropagateNaturalHeight true
  result.vexpand = true
  # result.hexpand = true
  result.child = widget
  

proc inToBox*(widget: Widget, revealOpened: bool): BoxWithProgressBarReveal =
  result = createBoxWithProgressBarReveal(revealOpened)

  let
    searchBar = newSearchBar()
    entry = newSearchEntry()
  
  with searchBar:
    connectEntry entry
    # showCloseButton = true
    child = entry
    keyCaptureWidget = result

  result.marginTop = 30 # for scroll
  result.prepend widget
  result.prepend searchBar


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

