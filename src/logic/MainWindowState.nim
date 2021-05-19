import gintro/[gtk4, adw]
import SectionManager
import ../view/SectionView
import SectionFactory
import Section
import std/with, os, tables

type 
  MainWindowState* = ref object
    carousel*: Carousel
    sectionManager*: SectionManager
    sas: Table[ListBox, int]
    # carousel2*: Carousel

var stateMW*: MainWindowState


proc row_activated_cb(self: ListBox, row: ListBoxRow);

proc createPage(path: string): ScrolledWindow = 
  SectionView.callBackFunc = row_activated_cb

  let
    scrolledWindow = newScrolledWindow()
    content = createSection(dir_view(path, true))

  with scrolledWindow:
    setChild content
    kineticScrolling = true
    propagateNaturalWidth = true
    setPolicy(PolicyType.never, PolicyType.always)
  return scrolledWindow

proc setupCarousel*(): Carousel =
  var carousel = newCarousel()
  carousel.interactive = true
  carousel.allowMouseDrag = true
  carousel.allowLongSwipes = true
  carousel.spacing = 5
  # for i in 0 ..< N_PAGES:
  carousel.prepend (createPage(os.getHomeDir()))
  return carousel

proc addNewSection(carousel: Carousel, section: Section) =
  # Получить текущую выбранную папку и передать в createPage
  carousel.append(createPage(section.get_selected_slot_path()))


var last_activated_row: Image
const FOLDER_OPEN = "folder-open-symbolic"
const FOLDER_CLOSED = "gnome-folder-symbolic"

proc row_activated_cb(self: ListBox, row: ListBoxRow) =
  let icon = row.getChild().Box.getLastChild().Image
  
  icon.setFromIconName(FOLDER_OPEN)
  
  if last_activated_row != nil: 
    last_activated_row.setFromIconName(FOLDER_CLOSED)
  
  last_activated_row = icon
  
  # state.carousel.addNewSection()
  debugEcho "row_activated_cb"


proc newMainWindowState*(firstSection: Section): MainWindowState = 
  let mainState = MainWindowState()
  with mainState:
    carousel = setupCarousel()
    sectionManager = newSectionManager(firstSection)
    
  mainState.carousel = setupCarousel()
  mainState.sectionManager = newSectionManager(firstSection)
  mainState.carousel.vexpand = true
  result = mainState