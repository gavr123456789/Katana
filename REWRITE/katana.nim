import gintro/[gtk4, gobject, gio, pango, glib, adw]
import std/with
import std/os
import page, types
import widgets/path
# import widgets/create_file_popup

proc activate(app: gtk4.Application) =
  let
    dir = os.getHomeDir()
    window = adw.newApplicationWindow(app)
    mainBox = newBox(Orientation.vertical, 0)
    # backBtn = newButtonFromIconName("go-previous-symbolic") # temp?
    pathWidget = createPathWidget(dir)
    carousel = newCarousel()
    pageAndWidget = createListView(dir, true, carousel)
    # filePopup = createPopup(pageAndWidget.page)
    header = adw.newHeaderBar()
    boxOfPages = newBox(Orientation.horizontal, 0)


  # with boxOfPages:
  #   append pageAndWidget.widget
  #   append pageAndWidget2.widget
  carousel.append(pageAndWidget.widget)
  # carousel.append(pageAndWidget2.widget)
  with header:
    # packStart backBtn
    # packStart filePopup.menuButton
    titleWidget = pathWidget
  with mainBox: 
    append header
    append carousel
  
  # header.titleWidget = pathWidget

  with window:
    content = mainBox
    title = "Katana"
    defaultSize = (400, 600)
    show


when isMainModule:
  let app = newApplication("com.github.gavr123456789.Katana")
  app.connect("activate", activate)
  discard run(app)