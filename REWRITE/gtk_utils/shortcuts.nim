import gintro/[gtk4, gdk4, gobject, gio, glib]
import ../utils/sorts_and_filters
import ../utils/group_folder_by_types


let HidefilterGb = newBoolFilter()
HidefilterGb.expression = newCClosureExpression(g_boolean_get_type(), nil, 0, nil, cast[Callback](filterHidden22), nil, nil)

proc ctrlHPressed(widget: ptr Widget00; args: ptr glib.Variant00; fm: MultiFilter): bool {.cdecl.} =

  let mfAsList = fm.listModel()
  let filtersCount = mfAsList.getNItems()
  echo "Filters count = ", filtersCount

  # вручную удаляем все выставленные фильтры
  if filtersCount > 0:
    echo filtersCount, ">= 1"
    fm.remove(0)
    fm.remove(1)
    fm.remove(2)
  else: 
    fm.append HidefilterGb

  true

# Callbacks
proc escPressed(widget: ptr Widget00; args: ptr glib.Variant00;  lv: ListView): bool {.cdecl.} =
  let 
    model = lv.model
  discard model.unselectAll
  true

proc ctrlGPressed(widget: ptr Widget00; args: ptr glib.Variant00;  directoryList: gtk4.DirectoryList): bool {.cdecl.} =
  let path = directoryList.file.path
  debugEcho "ctrlGPressed with dir: ", path
  groupFolderByTypes(path, GroupFormat.byType)

proc ctrlTPressed(widget: ptr Widget00; args: ptr glib.Variant00;  directoryList: gtk4.DirectoryList): bool {.cdecl.} =
  let path = directoryList.file.path
  debugEcho "ctrlDPressed with dir: ", path
  groupFolderByTypes(path, GroupFormat.byDate)

proc ctrlUPressed(widget: ptr Widget00; args: ptr glib.Variant00;  directoryList: gtk4.DirectoryList): bool {.cdecl.} =
  # TODO если нажали ctrl U при этом слева от текущей есть открытая папка, и она одна начинается с _ то нужно закрыть все до текущей
  let path = directoryList.file.path
  debugEcho "ctrlUPressed with dir: ", path
  unpackFilesFromFoldersByTypes path

import os
# TODO take terminal run command to global var on program start and use it here
proc altTPressed(widget: ptr Widget00; args: ptr glib.Variant00;  directoryList: gtk4.DirectoryList): bool {.cdecl.} =
  let path = directoryList.file.path
  echo "try to open dir: ", path
  discard os.execShellCmd("gnome-terminal --working-directory=" & path)

proc altCPressed(widget: ptr Widget00; args: ptr glib.Variant00;  directoryList: gtk4.DirectoryList): bool {.cdecl.} =
  let path = directoryList.file.path
  echo "try to open code in dir: ", path
  discard os.execShellCmd("code " & path)


# Shortcut Settings
proc addShortcutHelper(shortcutController: ShortcutController, shortcutKey: string, callbackFunc: auto, customData: auto) = 
  let ctrlh = newCallbackAction(cast[ShortcutFunc](callbackFunc), cast[pointer](customData), nil )
  shortcutController.addShortcut(newShortcut(shortcutTriggerParseString(shortcutKey), ctrlh))

# adding ctrl h and ctrl a
proc inToShortcutController*(lv: ListView, fm: MultiFilter, directoryList: gtk4.DirectoryList) = 

  let shortcutController = newShortcutController()
  lv.addController(shortcutController) 

  shortcutController.addShortcutHelper("<Control>H", ctrlHPressed, fm)
  shortcutController.addShortcutHelper("Escape", escPressed, lv)

  shortcutController.addShortcutHelper("<Control>G", ctrlGPressed, directoryList)
  shortcutController.addShortcutHelper("<Control>T", ctrlTPressed, directoryList)
  shortcutController.addShortcutHelper("<Control>U", ctrlUPressed, directoryList)

  shortcutController.addShortcutHelper("<Alt>T", altTPressed, directoryList)
  shortcutController.addShortcutHelper("<Alt>C", altCPressed, directoryList)

  # TODO turn off on ellipsization, change global var, in widget creation check this global bool var
  # let ctrle = newCallbackAction(cast[ShortcutFunc](ctrlUPressed), cast[pointer](dir), nil )
  # shortcutController.addShortcut(newShortcut(shortcutTriggerParseString("<Control>E"), ctrle))
