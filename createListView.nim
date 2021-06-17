
import gintro/[gtk4, gobject, gio, adw]
import std/with, options
import row_widget
import types
import carouselWidget
import os
import gtkHelpers


# proc getFileName(info: gio.FileInfo): string =
#   return info.getName()  

proc openFileCb(self: ToggleButton, pathAndNum: PathAndNum );
  

### FABRIC
proc setup_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  listitem.setChild(createRowWidget(0, ""))
  
  # listitem.setChild(newButton(""))
  
proc bind_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem, pathAndNum: PathAndNum) =
  # echo pathAndNum.path
  let 
    row = listitem.getChild().Row
    fileInfo = cast[gio.FileInfo](listitem.getItem())

  row.btn2.connect("toggled", openFileCb, (pathAndNum.num, pathAndNum.path / fileInfo.getName()))
  row.btn1.child.Label.label = fileInfo.getName()
  row.info = fileInfo

proc unbind_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  echo "unbind"

proc teardown_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  listitem.setChild (nil)

### LOGIC

proc createListView*(dir: string, num: int): ListView =
  let
    file = gio.newGFileForPath(dir)
    dl = gtk4.newDirectoryList("standard::name", file)
    lm = listModel(dl)
    ns = gtk4.newMultiSelection(lm)
    factory = gtk4.newSignalListItemFactory()
    lv = newListView(ns, factory)

  # lv.enableRubberband = true
  
  
  # lv.setCssClasses("rich-list")
  dl.setMonitored true

  with factory:
    connect("setup", setup_cb)
    connect("bind", bind_cb, ( num: num, path: dl.getFile().getPath()) )
    connect("unbind", unbind_cb)
    connect("teardown", teardown_cb)

  return lv


# proc createListBox(dir: string, num: int, model: ListModel): ListBox =
#   let 
#     listBox = newListBox()

#   listBox.cssClasses = "rich-list"
#   listBox.bindModel model, setup_cb
#   return listBox 

var lastToggledBtn: Option[ToggleButton]

proc openFileCb(self: ToggleButton, pathAndNum: PathAndNum ) =

  debugEcho "current path num:", pathAndNum.num
  if self.active:
    # Создать page с сурсом path
    carouselGb.append createListView(pathAndNum.path, pathAndNum.num + 1).inToScroll()
  else:
    # Закрыть все начиная с текущего номера из path and num и антуглнуть предыдущую туглед
    debugEcho "untoggle"
    debugEcho "carouselGb.nPages: ", carouselGb.nPages
    debugEcho "pathAndNum.num: ", pathAndNum.num
    carouselGb.removeNPagesFrom(pathAndNum.num)

