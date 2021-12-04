import gintro/[gtk4, gobject, gio, pango, glib, adw]
import utils/pathUtils

type 
  DirOrFile* = enum
    file
    dir
# TODO скрыть directoryList и создавать Page через функцию newPage
  Page* = ref object of Box
    revealer*: Revealer
    activatedArrowBtn*: ToggleButton
    directoryList*: gtk4.DirectoryList
    selection*: MultiSelection

  Row* = ref object of Box
    btn1*: ToggleButton # выбор файла
    btn2*: ToggleButton # переход в директорию или открытие файла
    image*: Image
    labelFileName*: Label
    kind*: DirOrFile

  PageAndFileInfo* = ref object
    page*: Page  
    info*: gio.FileInfo

  PageAndFileInfoAndCarousel* = ref object
    page*: Page  
    info*: gio.FileInfo
    carousel*: Carousel

  # For gesture click
  PageAndFileInfoAndButton* = object
    page*: Page  
    info*: gio.FileInfo
    button*: ToggleButton
  PageAndWidget* = object
    page*: Page  
    widget*: Widget
  CarouselPage* = tuple
    pageWidget: Page
    carousel: Carousel
  CarouselAndPageWidget* = object 
    pageWidget*: Widget
    carousel*: Carousel

  PathWidget* = ref object of Box
    backBtn*: Button
    entry*: Entry
    path*: GlobalPath

proc changeActivatedArrowBtn*(page: Page, btn: ToggleButton) =
  assert page != nil
  if page.activatedArrowBtn == btn: return

  if page.activatedArrowBtn != nil:
    page.activatedArrowBtn.active = false
  
  page.activatedArrowBtn = btn
  # btn2.active = true

func `iconName=`*(row: Row, iconName: string) =
  row.image.setFromIconName(iconName)



type 
  RevealerWithCounter* = ref object of gtk4.Revealer
    counter: Natural
  
  RevealerAndEntry* = tuple
    revealer: Revealer
    entry: Entry