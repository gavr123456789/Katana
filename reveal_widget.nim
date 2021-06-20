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
  # Удалить все из 
  for x in selectedStoreGb.items:
    let xfile = gio.newGFileForPath(x)
    xfile.deleteAsync(10, nil, nil, nil)
    debugEcho "deleted: ", x
  debugEcho "-----sssasss-----"

proc createFolder(self: Button, nameEntry: gtk4.Entry) =
  echo nameEntry.text.len
  if nameEntry.text.len == 0:
    return

  let currentPath = directoryListsStoreGb[currentPageGb].file.path
  if not dirExists(currentPath / nameEntry.text):
    createDir(currentPath / nameEntry.text)


proc createRevealerWithCounter*(): RevealerWithCounter =
  result = newRevealer(RevealerWithCounter)
  let
    centerBox = newCenterBox()
    revealBox = newBox(Orientation.vertical, 0)
    revealBtn1 = newButton("move")
    revealBtnCopy = newButton("copy")
    revealBtnDel = newButton("delete")
    revealBtnCreateFolder = newButton("Create Folder")
    revealBtnCreateFile = newButton("Create File")
    fileNameEntry = newEntry()
  
  
  with revealBox:
    orientation = Orientation.horizontal
    # append fileNameEntry
    append revealBtn1
    append revealBtnCopy
    append revealBtnDel
    append revealBtnCreateFolder
    append revealBtnCreateFile
  
  fileNameEntry.hexpand = true

  revealBtnDel.connect("clicked", deleteFiles)
  revealBtnCopy.connect("clicked", copyFiles)
  revealBtnCreateFolder.connect("clicked", createFolder, fileNameEntry)
    
  centerBox.endWidget = revealBox
  centerBox.centerWidget = fileNameEntry

  result.child = centerBox

func inc*(self: RevealerWithCounter) = self.counter.inc()
func reset*(self: RevealerWithCounter) = self.counter = 0
func dec*(self: RevealerWithCounter) = self.counter.inc()