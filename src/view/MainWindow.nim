import gintro/[gtk4, adw]
import std/with
import CreateSection
import ../logic/Slot
import mock
import ../logic/SectionFactory
import os

const N_PAGES = 5

type 
  State = ref object
    carousel: Carousel

proc createPage(num: int): Widget = createSection(dir_view(os.getHomeDir(), true)) 


proc setupCarousel(): Carousel =
  var carousel = newCarousel()
  echo carousel != nil
  carousel.interactive = true
  carousel.allowMouseDrag = true
  for i in 0 ..< N_PAGES:
    carousel.prepend (createPage (i))
  return carousel

var state = State()

proc activate*(app: Application) =
  let
    window = adw.newApplicationWindow(app)

    scrolledWindow = newScrolledWindow()
    viewPort = newViewport()
    adwBox = newBox(Orientation.vertical, 0) # box for adw header + content
    mainBox = newBox(Orientation.vertical, 10)
    carousel = setupCarousel()
    header = adw.newHeaderBar()
  state.carousel = setupCarousel()

  header.showStartTitleButtons = true
  carousel.vexpand = true

  with scrolledWindow:
    hexpand = true
    vexpand = false
    minContentHeight = 200
    child = viewPort

  viewPort.scrollToFocus = true
  viewPort.child = adwBox

  with adwBox:
    append header
    # append carousel
    append mainBox

  with mainBox:
    marginStart = 60
    marginEnd = 60
    marginTop = 30
    marginBottom = 30
    append carousel
    # append createSection(@["a", "b", "c", "d"])

  with window:
    title = "Katana"
    defaultSize = (400, 600)
    setChild scrolledWindow
    show
  