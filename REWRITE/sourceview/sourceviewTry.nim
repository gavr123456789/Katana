import gintro/[gtk4, gobject, gio, pango, adw, glib, gdk4]
import std/with
import createSourceView

proc windowOnClose(self: adw.ApplicationWindow, x: string): bool = 
  echo x
  return gdk4.EVENT_PROPAGATE




proc activate(app: gtk4.Application) =
  adw.init()

  let
    window = adw.newApplicationWindow(app)
    header = adw.newHeaderBar()
    mainBox = newBox(Orientation.vertical, 0)
    tabBar = newTabBar()
    tabView = newTabView()
    getCompletionBtn = newButton("get completition")

    sourceViewScrolled = createPage(getCompletionBtn)

  let page1 = tabView.append sourceViewScrolled


  tabBar.view = tabView
  window.connect("close_request", windowOnClose, "closing")

  with mainBox: 
    append header
    append tabBar
    append tabView

  with header:
    packStart getCompletionBtn

  with window:
    content = mainBox
    title = ""
    defaultSize = (100, 300)
    show

proc main() =
  let app = newApplication("org.gtk.example")
  app.connect("activate", activate)
  discard run(app)

main()