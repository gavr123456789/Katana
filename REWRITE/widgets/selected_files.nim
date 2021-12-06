import gintro/[gtk4, gobject, gio, pango, glib, adw]
import os, strutils, std/with
import ../utils/pathUtils
import ../state
import ../types


proc deleteFiles(self: Button) = 
  deleteAllSelectedFiles()
  deleteAllSelectedFolders()
  resetSelectedFiles()


proc copyFiles(self: Button) = 
  copyAllSelectedFolders()
  copyAllSelectedFiles()
  resetSelectedFiles()


proc moveFiles(self: Button) = 
  # Запустить чтото что оставит среди выделенных файлов только те что
  moveAllSelectedFolders()
  moveAllSelectedFiles()
  resetSelectedFiles()
  

proc renameFiles(self: Button, entry: Entry) = 
  renameAllFiles(entry.text)
  resetSelectedFiles()

proc openRenameRevealer(btn: ToggleButton, reveal: Revealer) =
  if btn.active:
    reveal.revealChild = true
  else: 
    reveal.revealChild = false


proc createSelectedFilesRevealer*(): RevealerWithCounter =
  result = newRevealer(RevealerWithCounter)
  let
    centerBox = newCenterBox()
    revealBox = newBox(Orientation.vertical, 0)
    # headerButtonsBox = newBox(Orientation.horizontal, 3)
    # File Control Btns
    revealBtnMove = newButtonFromIconName("insert-object-symbolic")
    revealBtnCopy = newButtonFromIconName("edit-copy-symbolic")
    revealBtnDel = newButtonFromIconName("user-trash-symbolic")

    revealBtnRename = newToggleButton()
    renameBtn = newButtonFromIconName("emblem-ok-symbolic")

    revealRenameBox = newBox(Orientation.horizontal, 0)
    revealRenameEntry = newEntry()
    reveal = newRevealer()
  
  revealBtnRename.iconName = "document-edit-symbolic"


  with revealRenameBox:
    setCssClasses("linked")
    append revealRenameEntry
    append renameBtn

  reveal.transitionType = RevealerTransitionType.slide_left
  reveal.transitionDuration = 200
  # reveal.revealChild = false
  reveal.setChild revealRenameBox

  with revealBox:
    setCssClasses("linked")
    orientation = Orientation.horizontal
    append revealBtnMove
    append revealBtnCopy
    append revealBtnDel
    append revealBtnRename
    append reveal
  

  revealBtnDel.connect("clicked", deleteFiles)
  revealBtnCopy.connect("clicked", copyFiles)
  revealBtnMove.connect("clicked", moveFiles)

  
  revealBtnRename.connect("toggled", openRenameRevealer, reveal)
  renameBtn.connect("clicked", renameFiles, revealRenameEntry)


  centerBox.centerWidget = revealBox
  result.child = centerBox

