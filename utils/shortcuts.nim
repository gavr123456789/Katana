import gintro/[gtk4, gdk4, gobject, gio, glib]
import sorts_and_filters


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
  true


proc escPressed(widget: ptr Widget00; args: ptr glib.Variant00;  lv: ListView): bool {.cdecl.} =
  let 
    model = lv.model
  echo model.unselectAll
  true

# proc ctrlAPressed(widget: ptr Widget00; args: ptr glib.Variant00; lv: ListView): bool {.cdecl.} =
#   let 
#     lm = cast[ListModel](lv.model)
#     model = lv.model
#     selectedCount = model.getSelection().size
#     allItemsInList = lm.getNItems

#   echo "selectedCount ", selectedCount
#   echo "allItemsInList ", allItemsInList
#   # if selectedCount == allItemsInList:
#   #   echo model.unselectAll
#   # else:
#   #   echo model.selectAll
#   # echo model.selectAll
#   # let nItems = lm.getNItems

#   # if nItems > 0:
#   #   let 
#   #     item = lm.getItem(0)
#   #     listItem = cast[FileInfo](item)
#   #     # row = listitem.getChild().FileRow

#   #   echo "SASASASASA", listItem.name
#   #   listItem.name = "sas"
#   false


# adding ctrl h and ctrl a
proc inToShortcutController*(lv: ListView, fm: MultiFilter) = 
  echo "inToShortcutController"
  let shortcutController = newShortcutController()
  lv.addController(shortcutController) 

  let ctrlh = newCallbackAction(cast[ShortcutFunc](ctrlHPressed), cast[pointer](fm), nil )
  shortcutController.addShortcut(newShortcut(shortcutTriggerParseString("<Control>H"), ctrlh))

  let esc = newCallbackAction(cast[ShortcutFunc](escPressed), cast[pointer](lv), nil )
  shortcutController.addShortcut(newShortcut(shortcutTriggerParseString("Escape"), esc))

  # itemType.

  # let ctrla = newCallbackAction(cast[ShortcutFunc](ctrlAPressed), cast[pointer](lv), nil )
  # shortcutController.addShortcut(newShortcut(shortcutTriggerParseString("<Control>A"), ctrla))
