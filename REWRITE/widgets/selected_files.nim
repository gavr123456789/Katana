import gintro/[gtk4, gobject, gio, pango, glib, adw]
import os, strutils, std/with
import ../utils/pathUtils
import ../state
import ../types


proc deleteFiles(self: Button) = 
  # for x in sequence:
  deleteAllSelectedFiles()
  deleteAllSelectedFolders()
  selectedFilesRevealer.revealChild = getCountOfSelectedFilesAndFolders() > 0


proc copyFiles(self: Button) = 
  copyAllSelectedFolders()
  copyAllSelectedFiles()
  selectedFilesRevealer.revealChild = getCountOfSelectedFilesAndFolders() > 0


proc moveFiles(self: Button) = 
  # Запустить чтото что оставит среди выделенных файлов только те что
  moveAllSelectedFolders()
  moveAllSelectedFiles()
  selectedFilesRevealer.revealChild = getCountOfSelectedFilesAndFolders() > 0
  

proc renameFiles(self: Button, entry: Entry) = 
  renameAllFiles(entry.text)
  selectedFilesRevealer.revealChild = getCountOfSelectedFilesAndFolders() > 0
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
    renameBtn = newButtonFromIconName("user-trash-symbolic")

    revealRenameBox = newBox(Orientation.horizontal, 0)
    revealRenameEntry = newEntry()
    reveal = newRevealer()
  
  revealBtnRename.iconName = "document-edit-symbolic"


  with revealRenameBox:
    append revealRenameEntry
    append renameBtn

  reveal.transitionType = RevealerTransitionType.swingUp
  reveal.transitionDuration = 200
  reveal.revealChild = false
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

