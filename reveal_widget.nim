import gintro/[gtk4, gobject, gio, adw]
import std/with
import stores/selected_store
import sets
type 
  RevealerWithCounter* = ref object of gtk4.Revealer
    counter: Natural

proc deleteFiles(self: Button) = 
  # Удалить все из 
  for x in selectedStoreGb.items:
    let xfile = gio.newGFileForPath(x)
    xfile.deleteAsync(10, nil, nil, nil)
    debugEcho "deleted: ", x
  debugEcho "-----sssasss-----"

import stores/directory_lists_store
import gtk_helpers
import tables
import os

proc copyFiles(self: Button) = 
  let q = directoryListsStoreGb[currentPageGb].file.path
  for x in selectedStoreGb.items:
    let xfile = gio.newGFileForPath(x)
    let copyPath = gio.newGFileForPath(q / xfile.basename)

    xfile.copyAsync(copyPath, {gio.FileCopyFlag.backup}, 10, nil, nil, nil, nil, nil)
    debugEcho "copyed from: ", x, " to: ", q / xfile.basename

  debugEcho "-----sssasss-----"

proc moveFiles(self: Button) = 
  let q = directoryListsStoreGb[currentPageGb].file.path
  for x in selectedStoreGb.items:
    let xfile = gio.newGFileForPath(x)
    let copyPath = gio.newGFileForPath(q / xfile.basename)

    echo xfile.move(copyPath, {gio.FileCopyFlag.backup}, nil, nil, nil)
    debugEcho "moved from: ", x, " to: ", q / xfile.basename

  debugEcho "-----sssasss-----"

proc createFolder(self: Button, nameEntry: gtk4.Entry) =
  echo nameEntry.text.len
  if nameEntry.text.len == 0:
    return

  let currentPath = directoryListsStoreGb[currentPageGb].file.path / nameEntry.text
  if not dirExists(currentPath):
    createDir(currentPath)

proc createFile(self: Button, nameEntry: gtk4.Entry) =
  echo nameEntry.text.len
  if nameEntry.text.len == 0:
    return

  let currentPath = directoryListsStoreGb[currentPageGb].file.path / nameEntry.text
  echo currentPath
  if not dirExists(currentPath):
    writeFile(currentPath, "")
    echo "sas"

proc createRevealerWithCounter*(header: adw.HeaderBar): RevealerWithCounter =
  result = newRevealer(RevealerWithCounter)
  let
    centerBox = newCenterBox()
    revealBox = newBox(Orientation.vertical, 0)
    revealBtnMove = newButton("move")
    revealBtnCopy = newButton("copy")
    revealBtnDel = newButton("delete")
    revealBtnCreateFolder = newButton("Create Folder")
    revealBtnCreateFile = newButton("Create File")
    fileNameEntry = newEntry()
  
  # TODO при нажатии должна выезжать штука с полем ввода
  with header: 
    packStart revealBtnCreateFolder
    packStart revealBtnCreateFile
  
  with revealBox:
    orientation = Orientation.horizontal
    # append fileNameEntry
    append revealBtnMove
    append revealBtnCopy
    append revealBtnDel
  
  fileNameEntry.hexpand = true

  revealBtnDel.connect("clicked", deleteFiles)
  revealBtnCopy.connect("clicked", copyFiles)
  revealBtnMove.connect("clicked", moveFiles)
  revealBtnCreateFolder.connect("clicked", createFolder, fileNameEntry)
  revealBtnCreateFile.connect("clicked", createFile, fileNameEntry)
    
  centerBox.endWidget = revealBox
  centerBox.centerWidget = fileNameEntry

  result.child = centerBox

func inc*(self: RevealerWithCounter) = self.counter.inc()
func reset*(self: RevealerWithCounter) = self.counter = 0
func dec*(self: RevealerWithCounter) = self.counter.inc()