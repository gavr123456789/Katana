
import gintro/[gtk4, gobject, gio, adw]
import std/with
import row_widget
import types
import carouselWidget



# proc getFileName(info: gio.FileInfo): string =
#   return info.getName()  

proc openFileCb(self: Button, pathAndNum: PathAndNum );
  

### FABRIC
proc setup_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  listitem.setChild(createRowWidget(0, ""))
  
  # listitem.setChild(newButton(""))
  
proc bind_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem, pathAndNum: PathAndNum) =
  echo pathAndNum.path
  let 
    row = listitem.getChild().Row
    fileInfo = cast[FileInfo](listitem.getItem())

  row.btn1.connect("clicked", openFileCb, (pathAndNum.num, pathAndNum.path & "/" & fileInfo.getName()))
  row.btn1.label = fileInfo.getName()
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
    ls = listModel(dl)
    ns = gtk4.newMultiSelection(ls)
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




proc openFileCb(self: Button, pathAndNum: PathAndNum ) =
  echo pathAndNum.path
  # Создать page с сурсом path
  let page = createListView(pathAndNum.path, pathAndNum.num + 1)
  # создать карусель с этим
  carouselGb.append(page)
  # удалить все страницы до той с которой нажали
  # carouselGb.removeLastNPages(pathAndNum.num) # TODO вылет
  # carouselGb.