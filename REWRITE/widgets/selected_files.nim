import gintro/[gtk4, gobject, gio, pango, glib, adw]
import std/with #os, strutils, 
# import ../utils/pathUtils
import ../state
import ../types

type
  EntryAndRevealerAndBtn = ref object 
    entry: Entry
    revealer: Revealer
    toggleBtn: ToggleButton
  RevealerAndEntry = ref object 
    revealer: Revealer
    entry: Entry


proc deleteFilesCb(self: Button) = 
  deleteAllSelectedFiles()
  deleteAllSelectedFolders()
  resetSelectedFiles()


proc copyFilesCb(self: Button) = 
  copyAllSelectedFolders()
  copyAllSelectedFiles()
  resetSelectedFiles()


proc moveFilesCb(self: Button) = 
  moveAllSelectedFolders()
  moveAllSelectedFiles()
  resetSelectedFiles()
  
import os
proc renameFiles (data: EntryAndRevealerAndBtn) = 
  renameAllFiles(data.entry.text)
  data.revealer.revealChild = false
  data.toggleBtn.active = false
  data.entry.text = ""
  resetSelectedFiles()

proc renameFilesCb(self: Button, data: EntryAndRevealerAndBtn) = 
  renameFiles data

proc renameFilesCb(self: Entry, data: EntryAndRevealerAndBtn) = 
  renameFiles data



proc renameEntropenRenameRevealerCb(btn: ToggleButton, data: RevealerAndEntry) =
  if btn.active:
    let oneSelectedName = ifOnlyOneSelectedGetIt()
    if oneSelectedName != "" :
      data.entry.text = oneSelectedName.splitPath.tail.cstring
    echo "only one was selected"
    data.revealer.revealChild = true
    discard data.entry.grabFocusWithoutSelecting()
  else: 
    data.entry.text = ""
    data.revealer.revealChild = false


proc createSelectedFilesRevealer*(): RevealerWithCounter =
  result = newRevealer(RevealerWithCounter)
  let
    centerBox = newCenterBox()
    revealBox = newBox(Orientation.vertical, 0)
    # headerButtonsBox = newBox(Orientation.horizontal, 3)
    # File Control Btns
    moveBtn = newButtonFromIconName("insert-object-symbolic")
    copyBtn = newButtonFromIconName("edit-copy-symbolic")
    deleteBtn = newButtonFromIconName("user-trash-symbolic")

    revealBtnRename = newToggleButton()
    renameBtn = newButtonFromIconName("emblem-ok-symbolic")

    revealRenameBox = newBox(Orientation.horizontal, 0)
    renameEntry = newEntry()
    reveal = newRevealer()
  
  revealBtnRename.iconName = "document-edit-symbolic"


  with revealRenameBox:
    setCssClasses("linked")
    append renameEntry
    append renameBtn

  with reveal: 
    transitionType = RevealerTransitionType.slide_left
    transitionDuration = 200
    setChild revealRenameBox

  with revealBox:
    setCssClasses("linked")
    orientation = Orientation.horizontal
    append moveBtn
    append copyBtn
    append deleteBtn
    append revealBtnRename
    append reveal
  

  deleteBtn.connect("clicked", deleteFilesCb)
  copyBtn.connect("clicked", copyFilesCb)
  moveBtn.connect("clicked", moveFilesCb)

  let qwe = RevealerAndEntry(revealer: reveal, entry: renameEntry)

  revealBtnRename.connect("toggled", renameEntropenRenameRevealerCb, qwe)

  let dataForCb = EntryAndRevealerAndBtn(entry: renameEntry, revealer: reveal, toggleBtn: revealBtnRename)
  renameBtn.connect("clicked", renameFilesCb, dataForCb)
  renameEntry.connect("activate", renameFilesCb, dataForCb)


  centerBox.centerWidget = revealBox
  result.child = centerBox

