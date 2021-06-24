import gintro/[gtk4, gobject, gio, adw]
import std/with
import sets
import stores/selected_store
import stores/gtk_widgets_store

type 
  RevealerWithCounter* = ref object of gtk4.Revealer
    counter: Natural
  # RevealerAndEntry = tuple
  #   entry: Entry
  #   revealer: Revealer

proc deleteFiles(self: Button) = 
  # Удалить все из 
  for x in selectedStoreGb.items:
    let xfile = gio.newGFileForPath(x)
    xfile.deleteAsync(10, nil, nil, nil)
    debugEcho "deleted: ", x
  debugEcho "-----sssasss-----"
  
  revealGb.revealChild = false
  selectedStoreGb.clear()

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

  revealGb.revealChild = false
  selectedStoreGb.clear()
  debugEcho "-----sssasss-----"

proc moveFiles(self: Button) = 
  let q = directoryListsStoreGb[currentPageGb].file.path
  for x in selectedStoreGb.items:
    let xfile = gio.newGFileForPath(x)
    let copyPath = gio.newGFileForPath(q / xfile.basename)

    echo xfile.move(copyPath, {gio.FileCopyFlag.backup}, nil, nil, nil)
    debugEcho "moved from: ", x, " to: ", q / xfile.basename
  revealGb.revealChild = false
  selectedStoreGb.clear()
  
  debugEcho "-----sssasss-----"

proc createFile(entry: Entry, reveal: Revealer) = 
  echo entry.text.len
  if entry.text.len == 0:
    reveal.revealChild = false
    return

  let currentPath = directoryListsStoreGb[currentPageGb].file.path / entry.text
  echo currentPath
  if not dirExists(currentPath):
    writeFile(currentPath, "")
    
  reveal.revealChild = false
  entry.text = ""
  


proc createFolder(entry: Entry, reveal: Revealer) = 
  echo reveal.revealChild

  if entry.text.len == 0:
    reveal.revealChild = false
    return

  let currentPath = directoryListsStoreGb[currentPageGb].file.path / entry.text
  if not dirExists(currentPath):
    createDir(currentPath)
  
  reveal.revealChild = false
  entry.text = ""
  


proc openFolderEntry(self: Button, revealer: Revealer) =
  revealer.revealChild = not revealer.revealChild

proc openFileEntry(self: Button, revealer: Revealer) =
  revealer.revealChild = not revealer.revealChild


# proc createFile(self: Button, folderNameEntry: gtk4.Entry) =


proc createRevealerWithCounter*(header: adw.HeaderBar): RevealerWithCounter =
  result = newRevealer(RevealerWithCounter)
  let
    centerBox = newCenterBox()
    revealBox = newBox(Orientation.vertical, 0)
    headerButtonsBox = newBox(Orientation.horizontal, 3)
    # File Control Btns
    revealBtnMove = newButtonFromIconName("insert-object-symbolic")
    revealBtnCopy = newButtonFromIconName("edit-copy-symbolic")
    revealBtnDel = newButtonFromIconName("user-trash-symbolic")
    # Create Btns
    revealBtnCreateFolder = newButtonFromIconName("folder-new-symbolic")
    revealBtnCreateFile = newButtonFromIconName("document-new-symbolic")
    # Revealers
    folderNameReveal = newRevealer()
    fileNameReveal = newRevealer()
    # Name Entries
    folderNameEntry = newEntry()
    fileNameEntry = newEntry()

  with headerButtonsBox: 
    append revealBtnCreateFolder
    append folderNameReveal
    append revealBtnCreateFile
    append fileNameReveal
  
  with folderNameReveal:
    child = folderNameEntry
    hexpand = true
    transitionType = RevealerTransitionType.slideLeft

  with fileNameReveal:
    child = fileNameEntry
    hexpand = true
    transitionType = RevealerTransitionType.slideLeft

  with header: 
    packStart headerButtonsBox
  
  with revealBox:
    setCssClasses("linked")
    orientation = Orientation.horizontal
    append revealBtnMove
    append revealBtnCopy
    append revealBtnDel
  

  revealBtnDel.connect("clicked", deleteFiles)
  revealBtnCopy.connect("clicked", copyFiles)
  revealBtnMove.connect("clicked", moveFiles)

  revealBtnCreateFolder.connect("clicked", openFolderEntry, folderNameReveal)
  revealBtnCreateFile.connect("clicked", openFileEntry, fileNameReveal) # fileNameEntry

  fileNameEntry.hexpand = true
  fileNameEntry.connect("activate", createFile, fileNameReveal)
  folderNameEntry.connect("activate", createFolder, folderNameReveal)
  
  centerBox.centerWidget = revealBox
  # centerBox.centerWidget = renameEntry

  result.child = centerBox

# func inc*(self: RevealerWithCounter) = self.counter.inc()
# func reset*(self: RevealerWithCounter) = self.counter = 0
# func dec*(self: RevealerWithCounter) = self.counter.inc()