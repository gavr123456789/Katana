import gintro/[gtk4, gobject, gio, pango, glib, adw]
import std/with
import std/os
import page, types
import widgets/[path, selected_files]
import state
# import widgets/create_file_popup



proc activate(app: gtk4.Application) =
  let
    dir = os.getHomeDir()
    window = adw.newApplicationWindow(app)
    mainBox = newBox(Orientation.vertical, 0)
    carousel = newCarousel()
    pageAndWidget = createListView(dir, true, carousel)
    header = adw.newHeaderBar()
  pathWidget = createPathWidget(dir)
  selectedFilesRevealer = createSelectedFilesRevealer()
  carousel.append(pageAndWidget.widget)
  with header:
    titleWidget = pathWidget
  with mainBox: 
    append header
    append carousel
    append selectedFilesRevealer
  

  with window:
    content = mainBox
    title = "Katana"
    defaultSize = (400, 600)
    show


when isMainModule:
  let app = newApplication("com.github.gavr123456789.Katana")
  app.connect("activate", activate)
  discard run(app)