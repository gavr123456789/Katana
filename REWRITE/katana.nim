import gintro/[gtk4, gobject, gio, pango, glib, adw]
import std/with
import page

proc activate(app: gtk4.Application) =
  let
    window = adw.newApplicationWindow(app)
    mainBox = newBox(Orientation.vertical, 0)
    page = createListView(".", true)
    header = adw.newHeaderBar()

  with mainBox: 
    append header
    append page

  with window:
    child = mainBox
    title = "Katana"
    defaultSize = (200, 100)
    show


when isMainModule:
  let app = newApplication("org.gtk.example")
  app.connect("activate", activate)
  discard run(app)