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
  selectedFilesRevealer.revealChild = getCountOfSelectedFilesAndFolders() > 0
  discard
  # let q = directoryListsStoreGb[carouselGb.getCurrentPageNumber()].file.path
  # for x in selectedStoreGb.items:
  #   let xfile = gio.newGFileForPath(x.fullPath)
  #   let copyPath = gio.newGFileForPath(q / xfile.basename)
  #   x.btn1.active = false
  #   xfile.copyAsync(copyPath, {gio.FileCopyFlag.backup}, 10, nil, nil, nil, nil, nil)
  #   debugEcho "copyed from: ", x.fullPath, " to: ", q / xfile.basename

  # revealFileCRUDGb.revealChild = false
  # selectedStoreGb.clear()

proc moveFiles(self: Button) = 
  selectedFilesRevealer.revealChild = getCountOfSelectedFilesAndFolders() > 0
  discard
  # let q = directoryListsStoreGb[carouselGb.getCurrentPageNumber()].file.path
  # for x in selectedStoreGb.items:
  #   let xfile = gio.newGFileForPath(x.fullPath)
  #   let copyPath = gio.newGFileForPath(q / xfile.basename)
  #   if x.fullPath != q / xfile.basename:
  #     echo xfile.move(copyPath, {gio.FileCopyFlag.backup}, nil, nil, nil)
  #     debugEcho "moved from: ", x.fullPath, " to: ", q / xfile.basename
  #   else: 
  #     x.btn1.active = false

  # revealFileCRUDGb.revealChild = false
  # selectedStoreGb.clear()

proc createFile(entry: Entry, reveal: Revealer) = 
  discard
  # echo entry.text.len
  # if entry.text.len == 0:
  #   reveal.revealChild = false
  #   return

  # let currentPath = directoryListsStoreGb[carouselGb.getCurrentPageNumber()].file.path / entry.text
  # echo currentPath
  # if not dirExists(currentPath):
  #   writeFile(currentPath, "")
    
  # reveal.revealChild = false
  # entry.text = ""
  


proc createFolder(entry: Entry, reveal: Revealer) = 
  discard
  # echo reveal.revealChild

  # if entry.text.len == 0:
  #   reveal.revealChild = false
  #   return

  # let currentPath = directoryListsStoreGb[carouselGb.getCurrentPageNumber()].file.path / entry.text
  # if not dirExists(currentPath):
  #   createDir(currentPath)
  
  # reveal.revealChild = false
  # entry.text = ""
  


proc openFolderEntry(self: Button, revealerAndEntry: RevealerAndEntry) =
  revealerAndEntry.revealer.revealChild = not revealerAndEntry.revealer.revealChild
  if revealerAndEntry.revealer.revealChild:
    discard revealerAndEntry.entry.grabFocus()


proc openFileEntry(self: Button, revealerAndEntry: RevealerAndEntry) =
  revealerAndEntry.revealer.revealChild = not revealerAndEntry.revealer.revealChild
  if revealerAndEntry.revealer.revealChild:
    discard revealerAndEntry.entry.grabFocus()

# proc createFile(self: Button, folderNameEntry: gtk4.Entry) =


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
    # revealBtnClose = newButtonFromIconName("close-symbolic")
    # Create Btns
    revealBtnCreateFolder = newButtonFromIconName("folder-new-symbolic")
    revealBtnCreateFile = newButtonFromIconName("document-new-symbolic")
    # Revealers
    folderNameReveal = newRevealer()
    fileNameReveal = newRevealer()
    # Name Entries
    folderNameEntry = newEntry()
    fileNameEntry = newEntry()

  # with headerButtonsBox: 
  #   append revealBtnCreateFolder
  #   append folderNameReveal
  #   append revealBtnCreateFile
  #   append fileNameReveal
  
  with folderNameReveal:
    child = folderNameEntry
    hexpand = true
    transitionType = RevealerTransitionType.slideLeft

  with fileNameReveal:
    child = fileNameEntry
    hexpand = true
    transitionType = RevealerTransitionType.slideLeft

  # with header: 
  #   packStart headerButtonsBox
  
  with revealBox:
    setCssClasses("linked")
    orientation = Orientation.horizontal
    append revealBtnMove
    append revealBtnCopy
    append revealBtnDel
  

  revealBtnDel.connect("clicked", deleteFiles)
  revealBtnCopy.connect("clicked", copyFiles)
  revealBtnMove.connect("clicked", moveFiles)

  revealBtnCreateFolder.connect("clicked", openFolderEntry, (folderNameReveal, folderNameEntry))
  revealBtnCreateFile.connect("clicked", openFileEntry, (fileNameReveal, fileNameEntry)) # fileNameEntry

  fileNameEntry.hexpand = true
  fileNameEntry.connect("activate", createFile, fileNameReveal)
  folderNameEntry.connect("activate", createFolder, folderNameReveal)
  
  centerBox.centerWidget = revealBox
  # centerBox.centerWidget = renameEntry

  result.child = centerBox

