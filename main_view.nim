import gintro/[adw, gtk4, gobject, gio, gdk4, glib]
import std/with
import main_widgets/carousel_widget, main_widgets/list_view
import gtk_helpers
import stores/gtk_widgets_store
import widgets/reveal_widget
import widgets/title_with_player

const H_KEY = 43

proc carouselKeyPressedCb(self: EventControllerKey, keyval: int, keycode: int, state: gdk4.ModifierType, carousel: CarouselWithPaths): bool =
  echo keycode
  echo keyval
  echo state
  if (state.contains ModifierFlag.control) and (keycode == H_KEY):
    echo "ctrl h pressed"
  return true
  

proc activate(app: gtk4.Application) =
  let
    window = adw.newApplicationWindow(app)
    header = adw.newHeaderBar()
    adwBox = newBox(Orientation.vertical, 0)
    listView = createListView("/home/gavr", 0).inToScroll.inToBox true
    mainBox = newBox(Orientation.vertical, 0)
    whiteBackBox = newBox(Orientation.vertical, 0)

    revealFileCRUD = createRevealerWithCounter(header)
    carouselIndicatorLines = newCarouselIndicatorLines()
    titleWithPlayer = createTitleStackWithPlayer()

    keyPressController = newEventControllerKey()


  window.iconName = "camera-flash" # TODO

  # mainApplicationWindowGb = window
  header.titleWidget = titleWithPlayer

  carouselGb = createCarousel(listView)
  carouselGb.vexpand = true
  carouselGb.connect("page_changed", setCurrentPage2)

  keyPressController.connect("key-pressed", carouselKeyPressedCb, carouselGb)
  window.addController(keyPressController)

  carouselIndicatorLines.carousel = carouselGb

  revealFileCRUDGb = revealFileCRUD  
  titleWithPlayerGb = titleWithPlayer

  with mainBox:
    # marginStart = 60
    # marginEnd = 60
    # marginTop = 30
    marginBottom = 30
    append carouselGb

  # TODO background color primary
  with whiteBackBox:
    vexpand = true
    hexpand = true
    append revealFileCRUD
    append mainBox
    append carouselIndicatorLines

  with adwBox:
    append header 
    append whiteBackBox


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
