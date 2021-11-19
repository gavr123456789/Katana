import gintro/[gtk4, gobject, gio, pango, glib, adw]
import std/[with, os, strutils]
import row, types
import gtk_utils/[set_file_row_for_file, widgets_utils, shortcuts, utils]
import utils/sorts_and_filters
import widgets/[path, in_to_search_and_reveal, create_file_popup]

proc openFile(pageAndFileInfo: PageAndFileInfo) =
  let fullPath = pageAndFileInfo.getFullPathFromPageAndFileInfo()

  if fullPath.endsWith ".sh":
      let pathWithEscapedSpaces = fullPath.replace(" ", "\\ ")
      let command = "gnome-terminal -- bash -c \"" & pathWithEscapedSpaces & "; exec bash\""
      echo command
      discard os.execShellCmd(command)
  elif fullPath.endsWith ".zip":
    echo "zip archive"
  else: 
    # echo "onClick"
    openFileInApp(fullPath.cstring)


proc gestureMiddleClickCb(self: GestureClick, nPress: int, x: cdouble, y: cdouble, pageAndFileInfo: PageAndFileInfo) =
  echo "middle click"
  # if pageAndFileInfo.button.active == true:
  let fullPath = pageAndFileInfo.getFullPathFromPageAndFileInfo()
  openFileInApp(fullPath.cstring)


proc openFileCb(btn: ToggleButton, pageAndFileInfo: PageAndFileInfo) = 
  if btn.active == true:
    btn.active = false
    openFile(pageAndFileInfo)

proc gestureLongPressCb(
  self: GestureLongPress,
  x: cdouble,
  y: cdouble, 
  pageAndFileInfo: PageAndFileInfo
) =
  echo "long press cb"
  let fullPath = pageAndFileInfo.getFullPathFromPageAndFileInfo()
  openFileInApp(fullPath.cstring)


proc openFolder(btn: ToggleButton, pageAndFileInfo: PageAndFileInfo) = 
  let fullPath = pageAndFileInfo.getFullPathFromPageAndFileInfo().cstring
  pageAndFileInfo.page.directoryList.setFile(gio.newGFileForPath(fullPath))
  # TODO uncomment. while we opening folders in same view - not needed
  # pageAndFileInfo.page.changeActivatedArrowBtn(btn)

proc goBackCb(btn: Button, page: Page) = 
  let 
    # currentBtnFile = pageAndFileInfo.info.name
    currentPath = page.directoryList.file.path 
    backPath = os.parentDir(currentPath)
  if currentPath != "/":
    page.directoryList.setFile(gio.newGFileForPath(backPath.cstring))
    echo "DIS WAS SET TO ", backPath
    echo "back"
    
  
# Factory signals
proc setup_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  listitem.setChild(createRow())
  
proc bind_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem, data: CarouselPage) =
  let 
    row = listitem.getChild().Row
    info = cast[gio.FileInfo](listitem.getItem())


  row.set_file_row_for_file(info)  # kind choosed

  # selected = toggled
  discard listitem.bindProperty("selected", row.btn1, "active", {})

  case row.kind
  of DirOrFile.dir: 
    row.btn2.connect("toggled", openFolder, PageAndFileInfo(page: data.pageWidget, info: info))
  of DirOrFile.file: 
    # discard
    row.btn2.connect("toggled", openFileCb,  PageAndFileInfo(page: data.pageWidget, info: info))
    let 
      # gestureLongPress = newGestureLongPress()
      gestureMiddleClick = newGestureClick()

    # with gestureLongPress:
    #   connect("pressed", gestureLongPressCb, PageAndFileInfo(page: data.page, info: info))
    with gestureMiddleClick:
      setButton(2)
      connect("pressed", gestureMiddleClickCb, PageAndFileInfo(page: data.pageWidget, info: info))
    with row.btn2:
      # addController(gestureLongPress)
      addController(gestureMiddleClick)
    # gestureLongPress.group(gestureLeftClick)


proc unbind_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  discard

proc teardown_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  listitem.setChild (nil)


proc newExpression(gType: GType, callBackFunc: auto): CClosureExpression = 
  newCClosureExpression(gType, nil, 0, nil, cast[Callback](callBackFunc), nil, nil)

proc createListView*(
  dir: string,
  revealerOpened: bool,
  carousel: Carousel
  # backBtn: Button, 
  # pathEntry: PathWidget
  ): PageAndWidget =
  
  let
    file = gio.newGFileForPath(dir)
    dl = gtk4.newDirectoryList("*", file)
    lm = listModel(dl)
    mainBox = newBox(Orientation.vertical, 0)
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
    page = createPage(revealerOpened, dl, ns)
    # toolbar
    toolbarBox = newBox(Orientation.horizontal, 0)
    backBtn = newButtonFromIconName("go-previous-symbolic") 
    filePopup = createPopup(page)


    # gestureClick = newGestureClick()
  
  doAssert page != nil

  backBtn.connect("clicked", goBackCb, page)
  # createFileBtn.connect("clicked", createFile, EntryAndPopoverAndPage(page: page, entry: ))
  # sort
  ms.append(folderFirstSorter)
  ms.append(dotFilesFirstSorter)
  ms.append(stringSorter)

  # sort expressions
  stringSorter.expression = newExpression(g_string_get_type(), sortAlphabet)
  dotFilesFirstSorter.expression = newExpression(g_int_get_type(), sortDotFilesFirst)
  folderFirstSorter.expression = newExpression(g_int_get_type(), sortFolderFirst)
  folderFirstSorter.sortOrder = SortType.descending
  boolFilter.expression = newExpression(g_boolean_get_type(), filterHidden22)

  # filter
  multiFilter.append(boolFilter)

  #factory
  var asd: CarouselPage = (pageWidget: page, carousel: carousel)
  factory.connect("bind", bind_cb, asd)
  with factory:
    connect("setup", setup_cb)
    connect("unbind", unbind_cb)
    connect("teardown", teardown_cb)

  # Надо передавать туда такой объект внутри которого вседа актуальная директория
  lv.inToShortcutController(multiFilter, page.directoryList)
  let fileManager = lv.inToScroll().inToSearch(page, multiFilter, revealerOpened)

  with toolbarBox:
    # addCssClass("linked")
    append backBtn
    append filePopup.menuButton
  filePopup.menuButton.addCssClass("flat")
  backBtn.addCssClass("flat")
  with mainBox:
    append toolbarBox
    append fileManager

  result.widget = mainBox
  result.page = page