import gintro/[gtk4, adw]
import std/with
import CreateSection
import ../logic/Slot
import mock
import ../logic/SectionFactory
import os

const N_PAGES = 5

type 
  MainWindowState = ref object
    carousel: Carousel

proc createPage(num: int): Widget = 
  let
    scrolledWindow = newScrolledWindow()
    # viewPort = newViewport()
    content = createSection(dir_view(os.getHomeDir(), true))
  # scrolledWindow.vexpand = true
  scrolledWindow.setChild content
  scrolledWindow.propagateNaturalWidth = true
  return scrolledWindow


proc setupCarousel(): Carousel =
  var carousel = newCarousel()
  carousel.interactive = true
  carousel.allowMouseDrag = true
  for i in 0 ..< N_PAGES:
    carousel.prepend (createPage (i))
  return carousel

var state* = MainWindowState()

proc activate*(app: Application) =
  let
    window = adw.newApplicationWindow(app)

    scrolledWindow = newScrolledWindow()
    viewPort = newViewport()
    adwBox = newBox(Orientation.vertical, 0) # box for adw header + content
    mainBox = newBox(Orientation.vertical, 10)
    header = adw.newHeaderBar()

  state.carousel = setupCarousel()

  header.showStartTitleButtons = true
  state.carousel.vexpand = true

  # window
  #   adwBox
  #     header
  #     scrolledWindow
  #       mainBox

  with scrolledWindow:
    hexpand = true
    vexpand = true
    minContentHeight = 200
    child = viewPort

  viewPort.scrollToFocus = true

  scrolledWindow.setChild mainBox
  with adwBox:
    append header
    append scrolledWindow

  with mainBox:
    marginStart = 60
    marginEnd = 60
    marginTop = 30
    marginBottom = 30
    append state.carousel

  with window:
    title = "Katana"
    defaultSize = (400, 600)
    setChild adwBox
    show
  