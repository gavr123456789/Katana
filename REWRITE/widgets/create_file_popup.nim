import gintro/[gtk4, gobject, gio, pango, adw, glib, gdk4]
import std/with

type EntryAndWindow* = object
  entry*: Entry
  popover*: Popover

type FilePopup* = object 
  menuButton*: MenuButton
  createFolderBtn*: Button
  createFileBtn*: Button

proc createPopup*(): FilePopup =
  let
    menuButton = newMenuButton()
    popover = newPopover()

    entry = newEntry()
    createFolderBtn = newButtonFromIconName("folder-new-symbolic")
    createFileBtn = newButtonFromIconName("document-new-symbolic")
    entryWithBtnBox = newBox(Orientation.horizontal, 0)

  with entryWithBtnBox:
    append entry
    append createFolderBtn
    append createFileBtn
    setCssClasses("linked")

  menuButton.iconName = "folder-new-symbolic"
  
  popover.child = entryWithBtnBox
  menuButton.popover = popover

  with result:
    menuButton = menuButton
    createFolderBtn = createFolderBtn
    createFileBtn = createFileBtn