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
  let copyPath = gio.newGFileForPath(q)
  for x in selectedStoreGb.items:
    let xfile = gio.newGFileForPath(q / x)
    xfile.copyAsync(copyPath, {gio.FileCopyFlag.backup}, 0, nil, nil, nil, nil, nil)
  debugEcho "-----sssasss-----"

proc moveFiles(self: Button) = 
  # Удалить все из 
  for x in selectedStoreGb.items:
    let xfile = gio.newGFileForPath(x)
    xfile.deleteAsync(10, nil, nil, nil)
    debugEcho "deleted: ", x
  debugEcho "-----sssasss-----"

proc createRevealerWithCounter*(): RevealerWithCounter =
  result = newRevealer(RevealerWithCounter)
  let
    centerBox = newCenterBox()
    revealBox = newBox(Orientation.vertical, 0)
    revealBtn1 = newButton("move")
    revealBtn2 = newButton("copy")
    revealBtnDel = newButton("delete")
  
  with revealBox:
    orientation = Orientation.horizontal
    append revealBtn1
    append revealBtn2
    append revealBtnDel
  
  revealBtnDel.connect("clicked", deleteFiles)
    
  centerBox.endWidget = revealBox
  result.child = centerBox

func inc*(self: RevealerWithCounter) = self.counter.inc()
func reset*(self: RevealerWithCounter) = self.counter = 0
func dec*(self: RevealerWithCounter) = self.counter.inc()