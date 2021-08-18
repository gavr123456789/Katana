import gintro/[gtk4, gobject, gio, adw, glib]
import std/with, os
import ../types, ../utils/ext_to_icons, ../gtk_helpers, carousel_widget, row_widget
import ../stores/directory_lists_store

type 
  PathAndExt = tuple
    path: string
    ext: string
    name: string


proc openFolderCb(self: ToggleButton, pathAndNum: PathAndNum );
proc selectFileCb(self: ToggleButton, pspec: ParamSpec, row: FileRow );

# press arrow btn
proc openFileCb(self: ToggleButton, pathAndExt: PathAndExt ) = 
  if self.active == true:
    self.active = false
    if pathAndExt.ext == ".sh":
      let command = "gnome-terminal --wait --command \"" & pathAndExt.path & "\""
      echo command
      discard os.execShellCmd(command)
    else: 
      gtk_helpers.openFileInApp(pathAndExt.path)

### FABRIC
proc setup_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem, fullPath: string) =
  listitem.setChild(createFileRow())

  
import ../widgets/boxWithPlayer
proc parseRegular(row: FileRow, path: string, fileInfo: gio.FileInfo, pageNum: int) =
  # echo path, " is ", gio.FileType.regular
  let (_, name, ext) = fileInfo.getName().splitFile()
  row.btn2.label = "→"
  row.iconName = getFileIconFromExt ext
  if ext == ".mp3":
    ###
    debugEcho "setup_cb, найден MP3"
    # let playerBox = createBoxWithPlayer(path, pageNum)
    # row.backBtn = newButton("←")
    # playerBox.append row.backBtn
    # row.switchStackBtnSignalid = row.backBtn.connect("clicked", backToMainStackCb, row)

    # row.addSecondStack playerBox
    row.arrowBtnSignalid = row.btn2.connect("toggled", openSecondStackCb, row) # TODO функция перемещающая стак на плеер
  else:
    row.arrowBtnSignalid = row.btn2.connect("toggled", openFileCb, (path: path, ext: ext, name: name)) # TODO функция открывающая  файл

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
  row.fileBtnSignalid = row.btn1.connect("notify::active", selectFileCb, row)

  # debugEcho fileInfo.listAttributes
  # debugEcho "size: ", fileInfo.getSize
  # debugEcho "allocated-size: ", fileInfo.getAttributeUInt64("standard::allocated-size")
  # debugEcho "standard::content-type: ", fileInfo.getAttributeString("standard::content-type")

  case fileType:
  of gio.FileType.unknown:
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

  row.labelFileName.label = fileInfo.getName()
  row.fullPath = path

proc unbind_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  let row = listitem.getChild().FileRow

  if row.arrowBtnSignalid != 0: row.btn2.signalHandlerDisconnect(row.arrowBtnSignalid)
  # if row.fileBtnSignalid != 0: row.btn1.signalHandlerDisconnect(row.fileBtnSignalid)
  if row.switchStackBtnSignalid != 0: row.backBtn.signalHandlerDisconnect(row.switchStackBtnSignalid)

proc teardown_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  # debugEcho "teardown_cb"

  if listitem != nil:
    listitem.child = nil

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
import ../utils/shortcuts

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

  # lv.enableRubberband = true

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

  let path = dl.getFile().getPath()
  with factory:
    connect("setup", setup_cb, path)
    connect("bind", bind_cb, ( num: num, path: path) )
    connect("unbind", unbind_cb)
    connect("teardown", teardown_cb)

  debugEcho "SSASS  ", dir, "  ", path
  # lv.inToKeyboardController()
  lv.inToShortcutController(multiFilter, dir)
  
  return lv.inToScroll().inToSearch(multiFilter, revealerOpened)



import ../stores/last_toggled_per_page

proc openFolderCb(self: ToggleButton, pathAndNum: PathAndNum ) =

  if self.active:
    # Если на этой странице уже есть активированная кнопка
     
    if lastToggledPerPageGb.contains pathAndNum.num:
      lastToggledPerPageGb[pathAndNum.num].active = false
      lastToggledPerPageGb[pathAndNum.num] = self
    else:
      lastToggledPerPageGb[pathAndNum.num] = self

    # Создать page с сурсом path
    carouselGb.append createListView(pathAndNum.path, pathAndNum.num + 1, false)
    # Если текущая страница не равна той странице где кнопка то скролим туда, иначе лагает

  else:
    # Закрыть все начиная с текущего номера из path and num и антуглнуть предыдущую туглед
    # debugEcho "untoggle"
    # debugEcho "carouselGb.nPages: ", carouselGb.nPages
    # debugEcho "pathAndNum.num: ", pathAndNum.num
    carouselGb.removeNPagesAfter(pathAndNum.num)

    lastToggledPerPageGb.del pathAndNum.num
    




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


