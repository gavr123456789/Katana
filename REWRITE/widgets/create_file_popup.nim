import gintro/[gtk4, gobject, gio, pango, adw, glib, gdk4]
import std/with
import std/os
import ../types

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
    
proc createFolder(btn: Button, data: EntryAndPopoverAndPage) = 
  let
    entryText = data.entry.text
    currentPathToDir = data.page.directoryList.file.path 
    pathToNewFile = currentPathToDir / entryText

  data.popover.popdown()

  if not dirExists(pathToNewFile) and not fileExists(pathToNewFile):
    createDir(pathToNewFile)
    data.entry.text = ""

proc createPopup*(page: Page): FilePopup =
  let
    menuButton = newMenuButton()
    popover = newPopover()
    runNowBtn = newButtonFromIconName("play-symbolic")
    runInTermBtn = newButtonFromIconName("terminal-symbolic")

    terminalButton = newMenuButton()
    popover2 = newPopover()
    termEntry = newEntry()
    termBox = newBox(Orientation.horizontal, 0)

    fileNameEntry = newEntry()
    createFolderBtn = newButtonFromIconName("folder-new-symbolic")
    createFileBtn = newButtonFromIconName("document-new-symbolic")
    entryWithBtnBox = newBox(Orientation.horizontal, 0)

  # Configure terminal popover
  termBox.addCssClass("lingked")
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

  
  # Configure file creating popover
  with createFileBtn: 
    connect("clicked", createFile, EntryAndPopoverAndPage(entry: fileNameEntry, page: page, popover: popover))
  with createFolderBtn: 
    connect("clicked", createFolder, EntryAndPopoverAndPage(entry: fileNameEntry, page: page, popover: popover))

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