import gintro/[gtk4, gobject, gio, pango, adw, glib, gdk4]
import std/with
import std/os
import ../types
import ../utils/exec_service
import ../state

type EntryAndPopoverAndPage* = object
  entry*: Entry
  popover*: Popover
  page: Page

type FilePopup* = object 
  menuButton*: MenuButton
  terminalButton*: MenuButton
  createFolderBtn*: Button
  createFileBtn*: Button

proc createFile(btn: Button, data: EntryAndPopoverAndPage) = 
  let
    entryText = data.entry.text
    currentPathToDir = data.page.directoryList.file.path 
    pathToNewFile = currentPathToDir / entryText

  data.popover.popdown()

  if not dirExists(pathToNewFile) and isValidFilename(pathToNewFile):
    writeFile(pathToNewFile, "")
    data.entry.text = ""
    

proc createFolder(data: EntryAndPopoverAndPage) = 
  let
    entryText = data.entry.text
    currentPathToDir = data.page.directoryList.file.path 
    pathToNewFile = currentPathToDir / entryText

  data.popover.popdown()
  discard data.entry.grabFocusWithoutSelecting()
  if not dirExists(pathToNewFile) and not fileExists(pathToNewFile):
    createDir(pathToNewFile)
    data.entry.text = ""

proc createFolderCb(btn: Button, data: EntryAndPopoverAndPage) = 
  createFolder data

proc createFolderCb(entry: Entry, data: EntryAndPopoverAndPage) = 
  echo "press from enty"
  createFolder data

proc execInTerminalCb(btn: Button, pathAndEntry: PathAndEntry) =
  echo pathAndEntry.entry.text
  exec_service.runCommandInTerminal(pathAndEntry.entry.text, getCurrentPath())

proc execInDirCb(btn: Button, pathAndEntry: PathAndEntry) =
  echo pathAndEntry.entry.text
  exec_service.runCommandInDir(pathAndEntry.entry.text, getCurrentPath())


proc createPopup*(page: Page): FilePopup =
  let
    menuButton = newMenuButton()
    popover = newPopover()
    runNowBtn = newButtonFromIconName("application-x-executable-symbolic")
    runInTermBtn = newButtonFromIconName("terminal-symbolic")

    terminalButton = newMenuButton()
    popover2 = newPopover()
    termEntry = newEntry()
    termBox = newBox(Orientation.horizontal, 0)

    fileNameEntry = newEntry()
    createFolderBtn = newButtonFromIconName("folder-new-symbolic")
    createFileBtn = newButtonFromIconName("document-new-symbolic")
    entryWithBtnBox = newBox(Orientation.horizontal, 0)
    entryAndPopoverAndPage = EntryAndPopoverAndPage(entry: fileNameEntry, page: page, popover: popover)

  # Configure terminal popover
  termBox.addCssClass("linked")
  popover2.child = termBox
  termEntry.hexpand = true
  popover2.hexpand = true

  with terminalButton: 
    iconName = "terminal-symbolic"
    popover = popover2
  
  with termBox:
    append termEntry
    append runNowBtn
    append runInTermBtn
  let pathAndEntry = PathAndEntry(entry: termEntry, path: getCurrentPath())
  runInTermBtn.connect("clicked", execInTerminalCb, pathAndEntry)
  runNowBtn.connect("clicked", execInDirCb, pathAndEntry)
  
  
  # Configure file creating popover
  createFileBtn.connect("clicked", createFile, entryAndPopoverAndPage)
  createFolderBtn.connect("clicked", createFolderCb, entryAndPopoverAndPage)
  fileNameEntry.connect("activate", createFolderCb, entryAndPopoverAndPage )

  with entryWithBtnBox:
    append fileNameEntry
    append createFolderBtn
    append createFileBtn
    setCssClasses("linked")
  with popover: 
    child = entryWithBtnBox
  with menuButton: 
    iconName = "folder-new-symbolic"
    popover = popover

  with result:
    menuButton = menuButton
    terminalButton = terminalButton
    createFolderBtn = createFolderBtn
    createFileBtn = createFileBtn