import gintro/[gtk4, adw]
import std/with, os
# import SectionView
# import ../logic/Slot
# import ../logic/Section
import ../logic/SectionManager
import ../logic/SectionFactory
import ../logic/MainWindowState

const SHOT_HIDDEN = false

proc activate*(app: Application) =
  let
    window = adw.newApplicationWindow(app)

    scrolledWindow = newScrolledWindow()
    viewPort = newViewport()
    adwBox = newBox(Orientation.vertical, 0) # box for adw header + content
    mainBox = newBox(Orientation.vertical, 10)
    header = adw.newHeaderBar()

  let firstSection = dir_view(os.getHomeDir(), SHOT_HIDDEN)
  stateMW = newMainWindowState(firstSection)

  header.showStartTitleButtons = true


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
    append stateMW.carousel
    # append stateMW.carousel2

  with window:
    title = "Katana"
    defaultSize = (400, 600)
    setChild adwBox
    show
  