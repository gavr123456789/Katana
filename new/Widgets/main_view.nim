import gintro/[adw, gtk4, gobject, gio]
import std/with
import carouselWidget, row_widget, createDirList


proc inToScroll(widget: Widget): ScrolledWindow =
  result = newScrolledWindow()
  result.minContentHeight = 200
  result.vexpand = true
  result.hexpand = true
  result.child = widget


proc activate(app: gtk4.Application) =
  let
    window = adw.newApplicationWindow(app)
    header = adw.newHeaderBar()
    adwBox = newBox(Orientation.vertical, 0)
    # frame = newFrame()
    listView = createDirList("/", 0).inToScroll
    # scr = newScrolledWindow()

    mainBox = newBox(Orientation.vertical, 10)
    # labelGroup1 = newLabel("Group 1")
  carouselGb = createCarousel(listView)
    # viewPort = newViewport()


  carouselGb.vexpand = true
  # carouselGb.hexpand = true
  # frame.child = listView
    
  with mainBox:
    marginStart = 60
    marginEnd = 60
    marginTop = 30
    marginBottom = 30
    hexpand = true
    vexpand= true
    # append frame
    append carouselGb

  
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
