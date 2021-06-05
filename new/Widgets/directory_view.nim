import gintro/[adw, gtk4, gobject, gio]
import std/with
import carouselWidget

proc getFileName(info: gio.FileInfo): string =
  return info.getName()  

proc setup_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  # let a = newListBoxRow()
  # a.setChild()
  listitem.setChild(newButton(""))
  
proc bind_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  let 
    # listRow = listitem.getChild().ListBoxRow
    btn = listitem.getChild().Button
    strobj = cast[FileInfo](listitem.getItem())

  btn.label = strobj.getFileName()

proc unbind_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  # There's nothing to do here. 
  # If you does something like setting a signal in bind_cb,
  # then disconnecting the signal is necessary in unbind_cb. 
  echo "unbind"

proc teardown_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  listitem.setChild (nil)
  # When the child of listitem is set to NULL, the reference to GtkLabel will be released and lb will be destroyed. 
  # Therefore, g_object_unref () for the GtkLabel object doesn't need in the user code. 

proc createDirList(dir: string): ListView =
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
    connect("bind", bind_cb)
    connect("unbind", unbind_cb)
    connect("teardown", teardown_cb)

  return lv

proc inToScroll(widget: Widget): ScrolledWindow =
  result = newScrolledWindow()
  result.child = widget

proc activate(app: gtk4.Application) =
  let
    window = adw.newApplicationWindow(app)
    header = adw.newHeaderBar()
    adwBox = newBox(Orientation.vertical, 0)
    # frame = newFrame()
    listView = createDirList("/").inToScroll
    # scr = newScrolledWindow()

    mainBox = newBox(Orientation.vertical, 10)
    # labelGroup1 = newLabel("Group 1")
    carousel = createCarousel(listView)
    # viewPort = newViewport()


  carousel.append createDirList(".")
  carousel.vexpand = true
  # frame.child = listView
    
  with mainBox:
    marginStart = 60
    marginEnd = 60
    marginTop = 30
    marginBottom = 30
    hexpand = true
    vexpand= true
    # append frame
    append carousel

  
  # with scr:
    # hexpand = true
    # vexpand = false
    # minContentHeight = 200
    # child = mainBox

  with adwBox:
    hexpand= true
    vexpand= true
    append header 
    append mainBox

  with window:
    defaultSize = (400, 600)
    title = "ListView"
    setChild adwBox
    show

proc main =
  let app = newApplication("org.gtk.example")
  app.connect("activate", activate)
  discard run(app)

main()
