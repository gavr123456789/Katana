import gintro/[adw, gtk4, gobject, gio, gdk4, glib]
import std/with
import main_widgets/carousel_widget, main_widgets/list_view
import gtk_helpers
import stores/gtk_widgets_store
import widgets/reveal_widget
import widgets/title_with_player


proc activate(app: gtk4.Application) =
  let
    window = adw.newApplicationWindow(app)
    header = adw.newHeaderBar()
    adwBox = newBox(Orientation.vertical, 0)
    listView = createListView("/home/gavr", 0, true)
    mainBox = newBox(Orientation.vertical, 0)

    revealFileCRUD = createRevealerWithCounter(header)
    carouselIndicatorLines = newCarouselIndicatorLines()
    titleWithPlayer = createTitleStackWithPlayer()

  window.iconName = "camera-flash" # TODO


  header.titleWidget = titleWithPlayer

  carouselGb = createCarousel(listView)
  carouselGb.vexpand = true
  carouselGb.connect("page_changed", setCurrentPage2)


  carouselIndicatorLines.carousel = carouselGb

  revealFileCRUDGb = revealFileCRUD  
  titleWithPlayerGb = titleWithPlayer

  with mainBox:
    # marginStart = 60
    # marginEnd = 60
    # marginTop = 30
    marginBottom = 30
    append carouselGb


  with adwBox:
    append header 
    # append whiteBackBox
    append revealFileCRUD
    append mainBox
    append carouselIndicatorLines


  with window:
    defaultSize = (600, 400)
    title = "Katana"
    content = adwBox
    show


proc main =
  let app = newApplication("org.gtk.example")
  app.connect("activate", activate)
  discard run(app)

main()
