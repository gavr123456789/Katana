import gintro/[gtk4, gobject, gio, pango, glib, adw]
import std/with
import row
import utils/sorts_and_filters
import widgets/in_to_scroll
import widgets/in_to_search_and_reveal
import gtk_utils/set_file_row_for_file
import gtk_utils/shortcuts
import types
# import os

proc openFolder(btn: ToggleButton, pageAndFileInfo: PageAndFileInfo) = 
  let 
    currentBtnFile = pageAndFileInfo.info.name
    pathToCurrentFile = pageAndFileInfo.page.directoryList.file.path & "/" & currentBtnFile

  echo  "folder pressed ", pathToCurrentFile 
  pageAndFileInfo.page.directoryList.setFile(gio.newGFileForPath(pathToCurrentFile))
  # TODO uncomment. while we opening folders in same view - not needed
  # pageAndFileInfo.page.changeActivatedArrowBtn(btn)


proc openFile(btn: ToggleButton, page: Page) = 
  echo  "file pressed"

import types

# Factory signals
proc getFileName(info: gio.FileInfo): string =
  return info.getName()  

proc setup_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  listitem.setChild(createRow())
  
proc bind_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem, page: Page) =
  let 
    row = listitem.getChild().Row
    info = cast[gio.FileInfo](listitem.getItem())

  # kind choosed
  row.set_file_row_for_file(info)
  case row.kind
  of DirOrFile.dir: 
    row.btn2.connect("toggled", openFolder, (page: page, info: info))
  of DirOrFile.file: 
    discard
    # row.btn2.connect("toggled", openFile, page)



proc unbind_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  discard
  # echo "unbind"

proc teardown_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  echo listitem.child == nil
  listitem.setChild (nil)


proc createListView(dir: string, revealerOpened: bool): Widget =
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
    page = createPage(revealerOpened, dl)

    gestureClick = newGestureClick()
  
  
  

  # sort
  ms.append(folderFirstSorter)
  ms.append(dotFilesFirstSorter)
  ms.append(stringSorter)

  # sort expressions
  stringSorter.expression = newCClosureExpression(g_string_get_type(), nil, 0, nil, cast[Callback](sortAlphabet), nil, nil)
  dotFilesFirstSorter.expression = newCClosureExpression(g_int_get_type(), nil, 0, nil, cast[Callback](sortDotFilesFirst), nil, nil)
  folderFirstSorter.expression = newCClosureExpression(g_int_get_type(), nil, 0, nil, cast[Callback](sortFolderFirst), nil, nil)
  folderFirstSorter.sortOrder = SortType.descending
  boolFilter.expression = newCClosureExpression(g_boolean_get_type(), nil, 0, nil, cast[Callback](filterHidden22), nil, nil)

  # filter
  multiFilter.append(boolFilter)

  #factory
  with factory:
    connect("setup", setup_cb)
    connect("bind", bind_cb, page)
    connect("unbind", unbind_cb)
    connect("teardown", teardown_cb)

  lv.inToShortcutController(multiFilter, dir)
  return lv.inToScroll().inToSearch(page, multiFilter, revealerOpened)
  





proc activate(app: gtk4.Application) =
  let
    window = adw.newApplicationWindow(app)
    mainBox = newBox(Orientation.vertical, 0)
    listView = createListView(".", true)
    header = adw.newHeaderBar()

  with mainBox: 
    append header
    append listView

  with window:
    child = mainBox
    title = "Katana Page"
    defaultSize = (200, 100)
    show


when isMainModule:
  let app = newApplication("org.gtk.example")
  app.connect("activate", activate)
  discard run(app)

