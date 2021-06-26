
import gintro/[gtk4, gobject, gio, adw]
import std/with
import os
import row_widget
import types
import carousel_widget
import gtk_helpers
import stores/directory_lists_store
import utils

proc openFileCb(self: ToggleButton, pathAndNum: PathAndNum );
proc selectFileCb(self: ToggleButton, row: FileRow );
  

### FABRIC
proc setup_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  echo "setup_cb"
  listitem.setChild(createFileRow(0, ""))
  
proc bind_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem, pathAndNum: PathAndNum) =
  echo "bind_cb"

  let 
    row = listitem.getChild().FileRow
    fileInfo = cast[gio.FileInfo](listitem.getItem())
    path = pathAndNum.path / fileInfo.getName()
    fileType = fileInfo.getFileType

  case fileType:

  of gio.FileType.unknown:
    echo path, " is ", gio.FileType.unknown
    let (_, name, ext) = fileInfo.getName().splitFile()
    row.iconName = if ext == "":
      getFolderIconFromName(name) 
    else:
      getFileIconFromExt(ext) 


  of regular:
    echo path, " is ", gio.FileType.regular
    # var q: ref bool
    # let mime = gio.contentTypeGuess(fileInfo.getName(), "", q)
    echo "file attributes is ", fileInfo.listAttributes
    let (_, _, ext) = fileInfo.getName().splitFile()
    echo "file type is ", ext
    row.iconName = getFileIconFromExt ext

  of directory:
    echo path, " is ", gio.FileType.directory
    row.iconName = getFolderIconFromName(fileInfo.getName()) 

  of symbolicLink:
    echo path, " is ", gio.FileType.symbolicLink
  of special:
    echo path, " is ", gio.FileType.special
  of shortcut:
    echo path, " is ", gio.FileType.shortcut
  of mountable:
    echo path, " is ", gio.FileType.mountable

  row.btn2SignalId = row.btn2.connect("toggled", openFileCb, (pathAndNum.num, path))
  row.btn1SignalId = row.btn1.connect("toggled", selectFileCb, row)
  row.labelFileName.label = fileInfo.getName()
  row.info = fileInfo
  row.fullPath = path
  
  # debugEcho "connect: ", row.btn2SignalId
  

proc unbind_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  let 
    row = listitem.getChild().FileRow
  # debugEcho "vivadisconnect: ", row.btn2SignalId
  row.btn2.signalHandlerDisconnect(row.btn2SignalId)
  row.btn1.signalHandlerDisconnect(row.btn1SignalId)

proc teardown_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  listitem.GC_unref

### LOGIC
import tables

proc gestureRigthClickCb(self: GestureClick, nPress: int, x: cdouble, y: cdouble, pathAndNum: PathAndNum) =
  echo "hello gestures ", nPress, " ", x, " ", y
  echo "num: ", pathAndNum.num, " path: ", pathAndNum.path
  if pathAndNum.num != gtk_helpers.currentPageGb:
    debugEcho "try scroll to ", pathAndNum.num
    carouselGb.scrollToN(pathAndNum.num )
  

proc createListView*(dir: string, num: int): ListView =
  let
    file = gio.newGFileForPath(dir)
    dl = gtk4.newDirectoryList("standard::name", file)
    lm = listModel(dl)
    ns = gtk4.newNoSelection(lm)
    factory = gtk4.newSignalListItemFactory()
    lv = newListView(ns, factory)

    gestureClick = newGestureClick()

  gestureClick.setButton(3) # rigth click
  gestureClick.connect("pressed", gestureRigthClickCb, ( num: num, path: dl.getFile().getPath()) )

  lv.addController(gestureClick)

  directoryListsStoreGb[num] = dl
  directoryListsStoreGb.printDirectoryListsStore()
  
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
    carouselGb.append createListView(pathAndNum.path, pathAndNum.num + 1).inToScroll.inToBox(false)
    # Если текущая страница не равна той странице где кнопка то скролим туда, иначе лагает

  else:
    # Закрыть все начиная с текущего номера из path and num и антуглнуть предыдущую туглед
    debugEcho "untoggle"
    # debugEcho "carouselGb.nPages: ", carouselGb.nPages
    # debugEcho "pathAndNum.num: ", pathAndNum.num
    carouselGb.removeNPagesFrom(pathAndNum.num)
    lastToggledPerPage.del pathAndNum.num
    
  # if pathAndNum.num != gtk_helpers.currentPageGb:
  #   debugEcho "try scroll to ", pathAndNum.num
  #   carouselGb.scrollToN(pathAndNum.num )



import stores/selected_store
import sets
import stores/gtk_widgets_store

proc selectFileCb(self: ToggleButton, row: FileRow ) =
  # debugEcho pathAndNum.path
  if self.active:
    selectedStoreGb.incl row
  else:
    selectedStoreGb.excl row

  if selectedStoreGb.len != 0:
    discard
    
    # Показываем бар выбора действий
    revealGb.revealChild = true
  else: 
    # Показываем бар выбора действий
    discard
    revealGb.revealChild = false


