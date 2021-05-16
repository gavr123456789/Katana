import gintro/[gtk4]
import std/with
import createSection

proc activate*(app: gtk4.Application) =
  let
    window = newApplicationWindow(app)

    scrolledWindow = newScrolledWindow()
    viewPort = newViewport()
    mainBox = newBox(Orientation.vertical, 10)


  with scrolledWindow:
    hexpand = true
    vexpand = false
    minContentHeight = 200
    child = viewPort

  viewPort.scrollToFocus = true
  viewPort.child = mainBox

  with mainBox:
    marginStart = 60
    marginEnd = 60
    marginTop = 30
    marginBottom = 30
    append createSection(@["a", "b", "c", "d"])

  with window:
    title = "Katana"
    defaultSize = (400, 600)
    setChild scrolledWindow
    show

