import gintro/[adw, gtk4, gobject, gio]
import std/with
import carousel_widget, list_view
import gtk_helpers
import stores/gtk_widgets_store
import reveal_widget


proc activate(app: gtk4.Application) =
  let
    window = adw.newApplicationWindow(app)
    header = adw.newHeaderBar()
    adwBox = newBox(Orientation.vertical, 0)
    listView = createListView(".", 0).inToScroll.inToBox true
    mainBox = newBox(Orientation.vertical, 0)
    reveal = createRevealerWithCounter(header)
    carouselIndicatorLines = newCarouselIndicatorLines()

  # mainApplicationWindowGb = window

  carouselGb = createCarousel(listView)
  carouselGb.vexpand = true
  carouselGb.connect("page_changed", setCurrentPage2)

  carouselIndicatorLines.carousel = carouselGb

  revealGb = reveal  


  with mainBox:
    # marginStart = 60
    # marginEnd = 60
    # marginTop = 30
    marginBottom = 30
    append carouselGb

  with adwBox:
    append header 
    append reveal
    append mainBox
    append carouselIndicatorLines


  with window:
    defaultSize = (600, 400)
    title = "Katana"
    setChild adwBox
    show

proc main =
  let app = newApplication("org.gtk.example")
  app.connect("activate", activate)
  discard run(app)

main()
