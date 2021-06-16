import gintro/[adw, gtk4, gobject, gio]
import std/with
import carouselWidget, createListView
import gtkHelpers




proc activate(app: gtk4.Application) =
  let
    window = adw.newApplicationWindow(app)
    header = adw.newHeaderBar()
    adwBox = newBox(Orientation.vertical, 0)
    listView = createListView("/", 0).inToScroll
    mainBox = newBox(Orientation.vertical, 10)

  carouselGb = createCarousel(listView)
  carouselGb.vexpand = true
    
  with mainBox:
    marginStart = 60
    marginEnd = 60
    marginTop = 30
    marginBottom = 30
    # hexpand = true
    # vexpand= true
    append carouselGb

  with adwBox:
    # hexpand= true
    # vexpand= true
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
