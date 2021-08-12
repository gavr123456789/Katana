import gintro/[gtk4, gobject, gio, adw, glib]
import std/with, os
import ../types, ../utils/ext_to_icons, ../gtk_helpers, carousel_widget, row_widget
import ../stores/directory_lists_store

proc openFolderCb(self: ToggleButton, pathAndNum: PathAndNum );
proc openFileCb(self: ToggleButton, path: string );
proc selectFileCb(self: ToggleButton, pspec: ParamSpec, row: FileRow );

# press arrow btn
proc openFileCb(self: ToggleButton, path: string ) = 
  if self.active == true:
    self.active = false
    gtk_helpers.openFileInApp(path)

### FABRIC
proc setup_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem, fullPath: string) =
  listitem.setChild(createFileRow())

  
import ../widgets/boxWithPlayer
proc parseRegular(row: FileRow, path: string, fileInfo: gio.FileInfo, pageNum: int) =
  # echo path, " is ", gio.FileType.regular
  let (_, _, ext) = fileInfo.getName().splitFile()
  row.btn2.label = "→"
  row.iconName = getFileIconFromExt ext
  if ext == ".mp3":
    ###
    debugEcho "setup_cb, найден MP3"
    let playerBox = createBoxWithPlayer(path, pageNum)
    row.backBtn = newButton("←")
    playerBox.append row.backBtn
    row.switchStackBtnSignalid = row.backBtn.connect("clicked", backToMainStackCb, row)

    row.addSecondStack playerBox
    row.arrowBtnSignalid = row.btn2.connect("toggled", openSecondStackCb, row) # TODO функция перемещающая стак на плеер
  else:
    row.arrowBtnSignalid = row.btn2.connect("toggled", openFileCb, path) # TODO функция открывающая  файл

proc parseDir(row: FileRow, path: string, fileInfo: gio.FileInfo, num: int) = 
      # echo path, " is ", gio.FileType.directory
    row.iconName = getFolderIconFromName(fileInfo.getName()) 
    row.arrowBtnSignalid = row.btn2.connect("toggled", openFolderCb, (num, path))


proc bind_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem, pathAndNum: PathAndNum) =
  let 
    row = listitem.getChild().FileRow
    fileInfo = cast[gio.FileInfo](listitem.getItem())
    fileName = fileInfo.getName()
    path = pathAndNum.path / fileName
    fileType = fileInfo.getFileType

  if fileInfo.isHidden == true:
    row.opacity = 0.5

  discard listitem.bindProperty("selected", row.btn1, "active", {syncCreate})
  # discard row.btn1.bindProperty("active", row.btn1, "active", {syncCreate})
  row.btn1.connect("notify::active", selectFileCb, row)

  # debugEcho fileInfo.listAttributes
  # debugEcho "size: ", fileInfo.getSize
  # debugEcho "allocated-size: ", fileInfo.getAttributeUInt64("standard::allocated-size")
  # debugEcho "standard::content-type: ", fileInfo.getAttributeString("standard::content-type")

  case fileType:
  of gio.FileType.unknown:
    # echo path, " is ", gio.FileType.unknown
    let (_, name, ext) = fileInfo.getName().splitFile()
    let isDir = ext == ""
    
    if isDir:
      row.iconName = getFolderIconFromName(name) 
      parseDir(row, path, fileInfo, pathAndNum.num)
    else:
      row.iconName = getFileIconFromExt(ext) 
      parseRegular(row, path, fileInfo, pathAndNum.num)


  of regular:
    parseRegular(row, path, fileInfo, pathAndNum.num)
      
  of directory:
    parseDir(row, path, fileInfo, pathAndNum.num)

  of symbolicLink, special, shortcut, mountable:
    echo path, " is something else"

  # row.fileBtnSignalid = row.btn1.connect("toggled", selectFileCb, row)
  row.labelFileName.label = fileInfo.getName()
  # row.info = fileInfo
  row.fullPath = path

proc unbind_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  let row = listitem.getChild().FileRow
  row.btn2.signalHandlerDisconnect(row.arrowBtnSignalid)
  row.btn1.signalHandlerDisconnect(row.fileBtnSignalid)
  # looks like it all already disconnected
  if row.switchStackBtnSignalid != 0:
    row.backBtn.signalHandlerDisconnect(row.switchStackBtnSignalid)

    

proc teardown_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  debugEcho "teardown_cb"
  
  # if listitem.getChild != nil:
  #   debugEcho "refCount: ", listitem.getChild.refCount
  #   listitem.setChild nil
  # else:
  #   debugEcho "listitem.getChild == nil"

  # if listitem.getItem() != nil:
  #   debugEcho "refCount: ", listitem.getItem().refCount
  #   GC_unref listitem
  # else:
  #   debugEcho "listitem.getItem == nil"
  
  if listitem != nil:
    debugEcho "refCount: ", listitem.refCount
    # listitem.child.unref
    # listitem.child.GC_unref
    listitem.child = nil

    # var item = listitem.getItem()
    # let row = listitem.getChild().FileRow

    # row.unref
    # item.unref
    # item.GC_unref

    # listitem.unref
    # listitem.GC_unref

    # listitem.getChild.unref
    # listitem.getItem.unref
    # listitem.child.unref
    # debugEcho "refCount: ", listitem.refCount
    # GC_fullCollect()
  else:
    debugEcho "listitem == nil"

### LOGIC
import tables

proc gestureRigthClickCb(self: GestureClick, nPress: int, x: cdouble, y: cdouble, pathAndNum: NumAndListView) =
  echo "hello gestures ", nPress, " ", x, " ", y
  # debugEcho "try scroll to ", pathAndNum.num
  carouselGb.gotoPage(pathAndNum.num)
  echo "try to sas"
  echo pathAndNum.lv.focusable
  echo pathAndNum.lv.grabFocus()
  


import ../utils/sorts_and_filters
import ../widgets/box_with_progress_bar_reveal

proc createListView*(dir: string, num: int, revealerOpened: bool): BoxWithProgressBarReveal =
  let
    file = gio.newGFileForPath(dir)
    dl = gtk4.newDirectoryList("standard::*", file)
    lm = listModel(dl)
    # sorts
    ms = newMultiSorter()
    stringSorter = newStringSorter()
    folderFirstSorter = newNumericSorter()
    dotFilesFirstSorter = newNumericSorter()
    sortListModel = newSortListModel(lm, ms)
    # filters
    multiFilter = newEveryFilter()
    filterListModel = newFilterListModel(listModel(sortListModel), multiFilter)
    boolFilter = newBoolFilter()
    # list
    ns = gtk4.newMultiSelection(filterListModel.listModel)
    factory = gtk4.newSignalListItemFactory()
    lv = newListView(ns, factory)

    gestureClick = newGestureClick()

  lv.enableRubberband = true

  # sort
  ms.append(folderFirstSorter)
  ms.append(dotFilesFirstSorter)
  ms.append(stringSorter)

  # sort expressions
  stringSorter.expression = newCClosureExpression(g_string_get_type(), nil, 0, nil, cast[Callback](sortAlphabet), nil, nil)
  dotFilesFirstSorter.expression = newCClosureExpression(g_int_get_type(), nil, 0, nil, cast[Callback](sortDotFilesFirst), nil, nil)
  folderFirstSorter.expression = newCClosureExpression(g_int_get_type(), nil, 0, nil, cast[Callback](sortFolderFirst), nil, nil)
  folderFirstSorter.sortOrder = SortType.descending

  # filter
  multiFilter.append(boolFilter)

  # filter expressions
  boolFilter.expression = newCClosureExpression(g_boolean_get_type(), nil, 0, nil, cast[Callback](filterHidden22), nil, nil)


  gestureClick.setButton(3) # rigth click
  # Передавать сюда лист вью и там грабать фокус
  gestureClick.connect("pressed", gestureRigthClickCb, ( num: num, lv: lv) ) 

  lv.addController(gestureClick)

  # TODO directoryListsStoreGb part of ListView
  directoryListsStoreGb[num] = dl
  # directoryListsStoreGb.printDirectoryListsStore()
 
  dl.setMonitored true

  with factory:
    connect("setup", setup_cb, dl.getFile().getPath())
    connect("bind", bind_cb, ( num: num, path: dl.getFile().getPath()) )
    connect("unbind", unbind_cb)
    connect("teardown", teardown_cb)

  # lv.inToKeyboardController()
  lv.inToShortcutController(multiFilter)
  

  return lv.inToScroll().inToSearch(multiFilter, revealerOpened)


import tables
var lastToggledPerPage = newTable[int, ToggleButton]()

proc openFolderCb(self: ToggleButton, pathAndNum: PathAndNum ) =

  if self.active:
    # Если на этой странице уже есть активированная кнопка
     
    if lastToggledPerPage.contains pathAndNum.num:
      lastToggledPerPage[pathAndNum.num].active = false
      lastToggledPerPage[pathAndNum.num] = self
    else:
      lastToggledPerPage[pathAndNum.num] = self

    # Создать page с сурсом path
    carouselGb.append createListView(pathAndNum.path, pathAndNum.num + 1, false)
    # Если текущая страница не равна той странице где кнопка то скролим туда, иначе лагает

  else:
    # Закрыть все начиная с текущего номера из path and num и антуглнуть предыдущую туглед
    # debugEcho "untoggle"
    # debugEcho "carouselGb.nPages: ", carouselGb.nPages
    # debugEcho "pathAndNum.num: ", pathAndNum.num
    carouselGb.removeNPagesAfter(pathAndNum.num)
    echo "\n\n"
    # echo getFreeMem()
    echo GC_getStatistics()
    echo "\n\n"
    # remove last toggled
    lastToggledPerPage.del pathAndNum.num
    




import ../stores/selected_store
import sets
import ../stores/gtk_widgets_store

proc selectFileCb(self: ToggleButton, pspec: ParamSpec, row: FileRow ) =
  if self.active:
    selectedStoreGb.incl row
  else:
    selectedStoreGb.excl row

  if selectedStoreGb.len != 0:
    discard
    
    # Показываем бар выбора действий
    revealFileCRUDGb.revealChild = true
  else: 
    revealFileCRUDGb.revealChild = false


