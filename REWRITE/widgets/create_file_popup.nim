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
  createFolderBtn*: Button
  createFileBtn*: Button

proc createFile(btn: Button, data: EntryAndPopoverAndPage) = 
  let
    entryText = data.entry.text
    currentPathToDir = data.page.directoryList.file.path 
    pathToNewFile = currentPathToDir / entryText

  data.popover.popdown()

  if not dirExists(pathToNewFile):
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

    entry = newEntry()
    createFolderBtn = newButtonFromIconName("folder-new-symbolic")
    createFileBtn = newButtonFromIconName("document-new-symbolic")
    entryWithBtnBox = newBox(Orientation.horizontal, 0)

  with createFileBtn: 
    connect("clicked", createFile, EntryAndPopoverAndPage(entry: entry, page: page, popover: popover))
  with createFolderBtn: 
    connect("clicked", createFolder, EntryAndPopoverAndPage(entry: entry, page: page, popover: popover))

  with entryWithBtnBox:
    append entry
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
    createFolderBtn = createFolderBtn
    createFileBtn = createFileBtn