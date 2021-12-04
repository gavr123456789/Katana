import gintro/[gtk4, gobject, gio, pango, glib, adw]
import std/[with, os, strutils, sets]
import row, types
import gtk_utils/[set_file_row_for_file, widgets_utils, shortcuts, utils]
import utils/[sorts_and_filters, file_service]
import widgets/[path, in_to_search_and_reveal, create_file_popup, selected_files]
import state
proc createListView*(
  dir: string,
  revealerOpened: bool,
  carousel: Carousel
  # backBtn: Button, 
  # pathEntry: PathWidget
  ): PageAndWidget ;

proc openFile(pageAndFileInfo: PageAndFileInfo) =
  let fullPath = pageAndFileInfo.getPathToFile()

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


proc gestureMiddleClickFileCb(self: GestureClick, nPress: int, x: cdouble, y: cdouble, pageAndFileInfo: PageAndFileInfo) =
  echo "middle click"
  # if pageAndFileInfo.button.active == true:
  let fullPath = pageAndFileInfo.getPathToFile()
  openFileInApp(fullPath.cstring)

proc gestureRightClickCb(self: GestureClick, nPress: int, x: cdouble, y: cdouble, page: Page) =
  changeCurrentPath(page.getPathFromPage())
  page.showProgressBar()


proc gestureMiddleClickDirCb(self: GestureClick, nPress: int, x: cdouble, y: cdouble, data: PageAndFileInfoAndCarousel) =
  # if pageAndFileInfo.button.active == true:
  let pageAndFileInfo = PageAndFileInfo(page: data.page, info: data.info)
  let fullPath = pageAndFileInfo.getPathToFile()
  echo "middle click directory "
  let x = createListView(fullPath, true, data.carousel)
  data.carousel.append(x.widget)
  # openFileInApp(fullPath.cstring)


proc openFileCb(btn: ToggleButton, pageAndFileInfo: PageAndFileInfo) = 
  if btn.active == true:
    btn.active = false
    openFile(pageAndFileInfo)


proc folderSelectedCb(btn: ToggleButton, pageAndFileInfo: PageAndFileInfo) = 
  let pathToFile = pageAndFileInfo.getPathToFile()
  if btn.active:
    addToSelectedFolders(pathToFile)
    for x in getAllFilesFromDir(pathToFile):
      addToSelectedFiles(x)
  else:
    deleteFromSelectedFolders(pathToFile)
    for x in getAllFilesFromDir(pathToFile):
      removeFromSelectedFiles(x)
  selectedFilesRevealer.revealChild = getCountOfSelectedFilesAndFolders() > 0

proc fileSelectedCb(btn: ToggleButton, pageAndFileInfo: PageAndFileInfo) = 
  let pathToFile = pageAndFileInfo.getPathToFile()
  if btn.active:
    addToSelectedFiles(pathToFile)
  else:
    removeFromSelectedFiles(pathToFile)
  selectedFilesRevealer.revealChild = getCountOfSelectedFilesAndFolders() > 0

proc openFolder(btn: ToggleButton, pageAndFileInfo: PageAndFileInfo) = 
  let fullPath = pageAndFileInfo.getPathToFile()
  pageAndFileInfo.page.setPagePath(fullPath)
  # TODO uncomment. while we opening folders in same view - not needed
  # pageAndFileInfo.page.changeActivatedArrowBtn(btn)

proc goBackCb(btn: Button, page: Page) = 
  let 
    # currentBtnFile = pageAndFileInfo.info.name
    currentPath = page.directoryList.file.path 
    backPath = os.parentDir(currentPath)
  if currentPath != "/":
    page.setPagePath(backPath)
    echo "DIS WAS SET TO ", backPath
    echo "back"

proc closePageCb(btn: Button, carouselAndPage: CarouselAndPageWidget) = 
  let carousel = carouselAndPage.carousel
  carousel.remove carouselAndPage.pageWidget
  echo "QQQQQQQQQQQQQQQQ", carouselAndPage.pageWidget == nil
  var i = 0
  # while carouselAndPage.pageWidget != nil:
    # carouselAndPage.pageWidget.unref()
    # i.inc()
    # echo i
  carouselAndPage.pageWidget.unref()

  removeLastSelectedPage()

  # carouselAndPage.pageWidget.unref()
  # carouselAndPage.pageWidget = nil
  # carouselAndPage.pageWidget.unref()

  echo "WWWWWWWWWWWWWWWW", carouselAndPage.pageWidget == nil

  if carousel.nPages == 0:
    let pageAndWidget = createListView(os.getHomeDir(), true, carousel)
    # pathWidget = createPathWidget(os.getHomeDir())
    carousel.append(pageAndWidget.widget)

  
# Factory signals
proc setup_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  listitem.setChild(createRow())
  
proc bind_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem, data: CarouselPage) =
  let 
    row = listitem.getChild().Row
    info = cast[gio.FileInfo](listitem.getItem())
    pageAndFileInfo = PageAndFileInfo(page: data.pageWidget, info: info)
    filePath = pageAndFileInfo.getPathToFile()

  row.set_file_row_for_file(info)  # kind choosed

  # selected = toggled
  discard listitem.bindProperty("selected", row.btn1, "active", {})
  
    
  case row.kind

  of DirOrFile.dir: 
    let gestureMiddleClick = newGestureClick()
    row.btn2.connect("toggled", openFolder, PageAndFileInfo(page: data.pageWidget, info: info))
    row.btn1.connect("toggled", folderSelectedCb, PageAndFileInfo(page: data.pageWidget, info: info))
    
    if selectedFoldersContainsPath filePath:
      echo "selected files containg ", filePath
      row.btn1.active = true

    with gestureMiddleClick:
      setButton(2)
      connect("pressed", gestureMiddleClickDirCb, PageAndFileInfoAndCarousel(page: data.pageWidget, info: info, carousel: data.carousel))
    row.btn2.addController gestureMiddleClick

  of DirOrFile.file: 
    if selectedFilesContainsPath filePath:
      echo "selected files containg ", filePath
      row.btn1.active = true

    row.btn2.connect("toggled", openFileCb,  pageAndFileInfo)
    row.btn1.connect("toggled", fileSelectedCb, pageAndFileInfo)
    
    let 
      gestureMiddleClick = newGestureClick()

    with gestureMiddleClick:
      setButton(2)
      connect("pressed", gestureMiddleClickFileCb, PageAndFileInfo(page: data.pageWidget, info: info))

    with row.btn2:
      # addController(gestureLongPress)
      addController gestureMiddleClick

proc unbind_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  discard

proc teardown_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  # listitem.getChild.unref()
  listitem.setChild (nil)


proc newExpression(gType: GType, callBackFunc: auto): CClosureExpression = 
  newCClosureExpression(gType, nil, 0, nil, cast[Callback](callBackFunc), nil, nil)

proc createListView*(
  dir: string,
  revealerOpened: bool,
  carousel: Carousel
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
    closeBtn = newButtonFromIconName("close-symbolic") 
    filePopup = createPopup(page)
  
  doAssert page != nil



  backBtn.connect("clicked", goBackCb, page)
  closeBtn.connect("clicked", closePageCb, CarouselAndPageWidget(carousel: carousel, pageWidget: mainBox))
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
    hexpand = true
    prepend filePopup.menuButton
    prepend backBtn
    append closeBtn
  filePopup.menuButton.addCssClass("flat")
  backBtn.addCssClass("flat")
  closeBtn.addCssClass("flat")
  
  with mainBox:
    append toolbarBox
    append fileManager

  result.widget = mainBox
  result.page = page
  page.showProgressBar()

  let gestureRightClick = newGestureClick()

  with gestureRightClick:
    setButton(3)
    connect("pressed", gestureRightClickCb, page)
  mainBox.addController gestureRightClick
  return result

    