
import gintro/[gtk4, gobject, gio, adw]
import std/with, options
import os
import row_widget
import types
import carousel_widget
import gtk_helpers

proc openFileCb(self: ToggleButton, pathAndNum: PathAndNum );
proc selectFileCb(self: ToggleButton, pathAndNum: PathAndNum );
  

### FABRIC
proc setup_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  listitem.setChild(createRowWidget(0, ""))
  
proc bind_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem, pathAndNum: PathAndNum) =
  let 
    row = listitem.getChild().Row
    fileInfo = cast[gio.FileInfo](listitem.getItem())
    path = pathAndNum.path / fileInfo.getName()

  row.btn2SignalId = row.btn2.connect("toggled", openFileCb, (pathAndNum.num, path))
  row.btn1SignalId = row.btn1.connect("toggled", selectFileCb, (pathAndNum.num, path))
  row.btn1.child.Label.label = fileInfo.getName()
  row.info = fileInfo
  # debugEcho "connect: ", row.btn2SignalId
  

proc unbind_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  let 
    row = listitem.getChild().Row
  # debugEcho "vivadisconnect: ", row.btn2SignalId
  row.btn2.signalHandlerDisconnect(row.btn2SignalId)
  row.btn1.signalHandlerDisconnect(row.btn1SignalId)

proc teardown_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  listitem.GC_unref

### LOGIC
proc createListView*(dir: string, num: int): ListView =
  let
    file = gio.newGFileForPath(dir)
    dl = gtk4.newDirectoryList("standard::name", file)
    lm = listModel(dl)
    ns = gtk4.newMultiSelection(lm)
    factory = gtk4.newSignalListItemFactory()
    lv = newListView(ns, factory)

  
  # lv.setCssClasses("rich-list")
  dl.setMonitored true

  with factory:
    connect("setup", setup_cb)
    connect("bind", bind_cb, ( num: num, path: dl.getFile().getPath()) )
    connect("unbind", unbind_cb)
    connect("teardown", teardown_cb)

  return lv


import tables
var lastToggledPerPage = newTable[int, ToggleButton]()

proc openFileCb(self: ToggleButton, pathAndNum: PathAndNum ) =

  if self.active:
    # Если на этой странице уже есть активированная кнопка
     
    if lastToggledPerPage.contains pathAndNum.num:
      lastToggledPerPage[pathAndNum.num].active = false
      lastToggledPerPage[pathAndNum.num] = self
    else:
      lastToggledPerPage[pathAndNum.num] = self

    # Создать page с сурсом path
    carouselGb.append createListView(pathAndNum.path, pathAndNum.num + 1).inToScroll()
    # Если текущая страница не равна той странице где кнопка то скролим туда, иначе лагает

  else:
    # Закрыть все начиная с текущего номера из path and num и антуглнуть предыдущую туглед
    debugEcho "untoggle"
    # debugEcho "carouselGb.nPages: ", carouselGb.nPages
    # debugEcho "pathAndNum.num: ", pathAndNum.num
    carouselGb.removeNPagesFrom(pathAndNum.num)
    lastToggledPerPage.del pathAndNum.num
    
  if pathAndNum.num != gtk_helpers.currentPageGb:
    debugEcho "try scroll to ", pathAndNum.num
    carouselGb.scrollToN(pathAndNum.num )



import stores/selected_store
import sets
import stores/gtk_widgets_store

proc selectFileCb(self: ToggleButton, pathAndNum: PathAndNum ) =
  # debugEcho pathAndNum.path
  if self.active:
    selectedStoreGb.incl pathAndNum.path
  else:
    selectedStoreGb.excl pathAndNum.path

  if selectedStoreGb.len != 0:
    discard
    
    # Показываем бар выбора действий
    revealGb.revealChild = true
  else: 
    # Показываем бар выбора действий
    discard
    revealGb.revealChild = false


