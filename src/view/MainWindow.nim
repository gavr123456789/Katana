import gintro/[gtk4, adw]
import std/with
import SectionView
import ../logic/Slot
import ../logic/Section

import mock
import ../logic/SectionFactory
import os

const N_PAGES = 5

type 
  MainWindowState = ref object
    carousel: Carousel
    carousel2: Carousel

var state* = MainWindowState()


proc row_activated_cb(self: ListBox, row: ListBoxRow);

proc createPage(): Widget = 
  SectionView.callBackFunc = row_activated_cb

  let
    scrolledWindow = newScrolledWindow()
    # viewPort = newViewport()
    content = createSection(dir_view(os.getHomeDir(), true))
  # scrolledWindow.vexpand = true
  with scrolledWindow:
    setChild content
    kineticScrolling = true
    propagateNaturalWidth = true
    setPolicy(PolicyType.never, PolicyType.always)
  return scrolledWindow

proc setupCarousel(): Carousel =
  var carousel = newCarousel()
  carousel.interactive = true
  carousel.allowMouseDrag = true
  carousel.allowLongSwipes = true
  carousel.spacing = 5
  # for i in 0 ..< N_PAGES:
  carousel.prepend (createPage())
  return carousel

proc addNewCarouselSection(carousel: Carousel, section: Section) =
  # Получить текущую выбранную папку и передать в createPage
  carousel.append(createPage())

### убрать отсюда
var last_activated_row: Image
const FOLDER_OPEN = "folder-open-symbolic"
const FOLDER_CLOSED = "gnome-folder-symbolic"

proc row_activated_cb(self: ListBox, row: ListBoxRow)  =
  
  let icon = row.getChild().Box.getLastChild().Image
  
  icon.setFromIconName(FOLDER_OPEN)
  
  if last_activated_row != nil: 
    last_activated_row.setFromIconName(FOLDER_CLOSED)
  
  last_activated_row = icon
  
  state.carousel.prepend(createPage())
  debugEcho "row_activated_cb"

###


proc activate*(app: Application) =
  let
    window = adw.newApplicationWindow(app)

    scrolledWindow = newScrolledWindow()
    viewPort = newViewport()
    adwBox = newBox(Orientation.vertical, 0) # box for adw header + content
    mainBox = newBox(Orientation.vertical, 10)
    header = adw.newHeaderBar()

  state.carousel = setupCarousel()
  state.carousel2 = setupCarousel()

  header.showStartTitleButtons = true
  state.carousel.vexpand = true
  state.carousel2.vexpand = true

  # window
  #   adwBox
  #     header
  #     scrolledWindow
  #       mainBox

  with scrolledWindow:
    hexpand = true
    vexpand = true
    kineticScrolling = true
    minContentHeight = 400
    child = viewPort

  viewPort.scrollToFocus = true

  let viewportForMainBox = newViewport()
  viewportForMainBox.setChild scrolledWindow
  scrolledWindow.setChild mainBox

  with adwBox:
    append header
    append viewportForMainBox

  with mainBox:
    marginStart = 60
    marginEnd = 60
    marginTop = 30
    marginBottom = 30
    append state.carousel
    append state.carousel2

  with window:
    title = "Katana"
    defaultSize = (400, 600)
    setChild adwBox
    show
  