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

import group_folder_by_types
proc ctrlGPressed(widget: ptr Widget00; args: ptr glib.Variant00;  dir: string): bool {.cdecl.} =
  debugEcho "ctrlGPressed with dir: ", dir
  groupFolderByTypes(dir, GroupFormat.byType)

proc ctrlTPressed(widget: ptr Widget00; args: ptr glib.Variant00;  dir: string): bool {.cdecl.} =
  debugEcho "ctrlDPressed with dir: ", dir
  groupFolderByTypes(dir, GroupFormat.byDate)

proc ctrlUPressed(widget: ptr Widget00; args: ptr glib.Variant00;  dir: string): bool {.cdecl.} =
  # TODO если нажали ctrl U при этом слева от текущей есть открытая папка, и она одна начинается с _ то нужно закрыть все до текущей
  debugEcho "ctrlUPressed with dir: ", dir
  unpackFilesFromFoldersByTypes dir

import os
proc ctrlQPressed(widget: ptr Widget00; args: ptr glib.Variant00;  dir: string): bool {.cdecl.} =
  discard os.execShellCmd("gnome-terminal --working-directory=" & dir)

proc ctrlCPressed(widget: ptr Widget00; args: ptr glib.Variant00;  dir: string): bool {.cdecl.} =
  discard os.execShellCmd("code " & dir)


# adding ctrl h and ctrl a
proc inToShortcutController*(lv: ListView, fm: MultiFilter, dir: string) = 
  echo "inToShortcutController"
  let shortcutController = newShortcutController()
  lv.addController(shortcutController) 

  let ctrlh = newCallbackAction(cast[ShortcutFunc](ctrlHPressed), cast[pointer](fm), nil )
  shortcutController.addShortcut(newShortcut(shortcutTriggerParseString("<Control>H"), ctrlh))

  let esc = newCallbackAction(cast[ShortcutFunc](escPressed), cast[pointer](lv), nil )
  shortcutController.addShortcut(newShortcut(shortcutTriggerParseString("Escape"), esc))

  let ctrlg = newCallbackAction(cast[ShortcutFunc](ctrlGPressed), cast[pointer](dir), nil )
  shortcutController.addShortcut(newShortcut(shortcutTriggerParseString("<Control>G"), ctrlg))

  let ctrlt = newCallbackAction(cast[ShortcutFunc](ctrlTPressed), cast[pointer](dir), nil )
  shortcutController.addShortcut(newShortcut(shortcutTriggerParseString("<Control>T"), ctrlt))

  let ctrlu = newCallbackAction(cast[ShortcutFunc](ctrlUPressed), cast[pointer](dir), nil )
  shortcutController.addShortcut(newShortcut(shortcutTriggerParseString("<Control>U"), ctrlu))

  # TODO turn off on ellipsization, change global var, in widget creation check this global bool var
  # let ctrle = newCallbackAction(cast[ShortcutFunc](ctrlUPressed), cast[pointer](dir), nil )
  # shortcutController.addShortcut(newShortcut(shortcutTriggerParseString("<Control>E"), ctrle))

  let ctrlq = newCallbackAction(cast[ShortcutFunc](ctrlQPressed), cast[pointer](dir), nil )
  shortcutController.addShortcut(newShortcut(shortcutTriggerParseString("<Alt>T"), ctrlq))

  let ctrlc = newCallbackAction(cast[ShortcutFunc](ctrlCPressed), cast[pointer](dir), nil )
  shortcutController.addShortcut(newShortcut(shortcutTriggerParseString("<Alt>C"), ctrlc))