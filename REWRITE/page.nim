import gintro/[gtk4, gobject, gio, pango, glib, adw]
import std/with
import row
import utils/sorts_and_filters
import gtk_utils/widgets_utils
import widgets/path
import widgets/in_to_search_and_reveal
import gtk_utils/set_file_row_for_file
import gtk_utils/shortcuts
import types
import os
import gtk_utils/utils
import strutils

# import utils/read/

proc openFile(btn: ToggleButton, pageAndFileInfo: PageAndFileInfo) = 
  let fullPath = pageAndFileInfo.getFullPathFromPageAndFileInfo()

  if btn.active == true:
    btn.active = false
    if fullPath.endsWith ".sh":
      let pathWithEscapedSpaces = fullPath.replace(" ", "\\ ")
      let command = "gnome-terminal --wait --command \"" & pathWithEscapedSpaces & "\""
      echo command
      discard os.execShellCmd(command)
    elif fullPath.endsWith ".zip":
      echo "zip archive"
    else: 
      openFileInApp(fullPath.cstring)


proc openFolder(btn: ToggleButton, pageAndFileInfo: PageAndFileInfo) = 
  let fullPath = pageAndFileInfo.getFullPathFromPageAndFileInfo().cstring
  pageAndFileInfo.page.directoryList.setFile(gio.newGFileForPath(fullPath))
  # TODO uncomment. while we opening folders in same view - not needed
  # pageAndFileInfo.page.changeActivatedArrowBtn(btn)

proc goBackCb(btn: Button, page: Page) = 
  let 
    # currentBtnFile = pageAndFileInfo.info.name
    pathToCurrentFolder = page.directoryList.file.path 
    backPath = os.parentDir(pathToCurrentFolder)
  if pathToCurrentFolder != "/":
    page.directoryList.setFile(gio.newGFileForPath(backPath.cstring))
    echo "DIS WAS SET TO ", backPath
    echo "back"
    


# Factory signals
proc getFileName(info: gio.FileInfo): string =
  return info.getName()  

proc setup_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  listitem.setChild(createRow())
  
proc bind_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem, page: Page) =
  let 
    row = listitem.getChild().Row
    info = cast[gio.FileInfo](listitem.getItem())


  row.set_file_row_for_file(info)  # kind choosed

  # selected = toggled
  discard listitem.bindProperty("selected", row.btn1, "active", {})

  case row.kind
  of DirOrFile.dir: 
    row.btn2.connect("toggled", openFolder, PageAndFileInfo(page: page, info: info))
  of DirOrFile.file: 
    # discard
    row.btn2.connect("toggled", openFile,  PageAndFileInfo(page: page, info: info))



proc unbind_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  discard

proc teardown_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  listitem.setChild (nil)




proc newExpression(gType: GType, callBackFunc: auto): CClosureExpression = 
  newCClosureExpression(gType, nil, 0, nil, cast[Callback](callBackFunc), nil, nil)

proc createListView*(dir: string, revealerOpened: bool, backBtn: Button, pathEntry: PathWidget): Widget =
  echo "----createListView---- DIR IS ", dir  
  
  let
    file = gio.newGFileForPath(dir)
    dl = gtk4.newDirectoryList("*", file)
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
    page = createPage(revealerOpened, dl, ns)

    # gestureClick = newGestureClick()
  
  
  backBtn.connect("clicked", goBackCb, page)

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
  with factory:
    connect("setup", setup_cb)
    connect("bind", bind_cb, page)
    connect("unbind", unbind_cb)
    connect("teardown", teardown_cb)

  echo "Выставили шоткат директории на ", dir
  # Надо передавать туда такой объект внутри которого вседа актуальная директория
  lv.inToShortcutController(multiFilter, page.directoryList)
  return lv.inToScroll().inToSearch(page, multiFilter, revealerOpened)
  



when isMainModule:
  proc activate(app: gtk4.Application) =
    let
      dir = "."
      window = adw.newApplicationWindow(app)
      mainBox = newBox(Orientation.vertical, 0)
      backBtn = newButtonFromIconName("go-previous-symbolic") # temp?
      pathWidget = createPathWidget(".")
      page = createListView(dir, true, backBtn, pathWidget)
      header = adw.newHeaderBar()


    header.packStart backBtn
    header.titleWidget = pathWidget
    
    with mainBox: 
      append header
      append page
    
    # header.titleWidget = pathWidget

    with window:
      content = mainBox
      title = "Katana"
      defaultSize = (200, 100)
      show


  proc main = 
    let app = newApplication("org.gtk.example")
    app.connect("activate", activate)
    discard run(app)

  main()

