import gintro/[gtk4, gobject, gio, pango, glib, adw]
import std/with
import row
import utils/sorts_and_filters
import widgets/in_to_scroll
import widgets/in_to_search_and_reveal
import utils/set_file_row_for_file
import utils/shortcuts


import types

# Factory signals
proc getFileName(info: gio.FileInfo): string =
  return info.getName()  

proc setup_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  listitem.setChild(createRow())
  
proc bind_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  let 
    row = listitem.getChild().Row
    fileInfo = cast[gio.FileInfo](listitem.getItem())

  row.set_file_row_for_file(fileInfo)


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
    connect("bind", bind_cb)
    connect("unbind", unbind_cb)
    connect("teardown", teardown_cb)

  lv.inToShortcutController(multiFilter, dir)

  return lv.inToScroll().inToSearch(multiFilter, revealerOpened)
  





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
    title = "Katana"
    defaultSize = (600, 400)
    show


when isMainModule:
  let app = newApplication("org.gtk.example")
  app.connect("activate", activate)
  discard run(app)

