import gintro/[gtk4, gobject, gio, pango, glib, gdk4]
import std/with
import createSourceView



proc activate(app: gtk4.Application) =
  # adw.init()

  let
    window = gtk4.newApplicationWindow(app)
    # header = adw.newHeaderBar()
    mainBox = newBox(Orientation.vertical, 0)
    # tabBar = newTabBar()
    # tabView = newTabView()
    # sourceViewScrolled = createPage()
    sourceView = createSourceView()


  # let page1 = tabView.append sourceViewScrolled


  # tabBar.view = tabView

  with mainBox: 
    # append header
    # append tabBar
    # append sourceViewScrolled
    append sourceView
  # with header:
  #   packStart getCompletionBtn

  with window:
    child = mainBox
    title = ""
    defaultSize = (600, 600)
    show

proc main() =
  let app = newApplication("org.gtk.example")
  app.connect("activate", activate)
  discard run(app)

main()