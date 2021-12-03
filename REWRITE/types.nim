import gintro/[gtk4, gobject, gio, pango, glib, adw]
import state

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


proc changeActivatedArrowBtn*(page: Page, btn: ToggleButton) =
  assert page != nil
  if page.activatedArrowBtn == btn: return

  if page.activatedArrowBtn != nil:
    page.activatedArrowBtn.active = false
  
  page.activatedArrowBtn = btn
  # btn2.active = true

func `iconName=`*(row: Row, iconName: string) =
  row.image.setFromIconName(iconName)

import os
proc getFullPathFromPageAndFileInfo*(pageAndFileInfo: PageAndFileInfo): string = 
  pageAndFileInfo.page.directoryList.file.path / pageAndFileInfo.info.name

proc getPathFromPage*(page: Page): string = 
  page.directoryList.file.path

proc setPagePath*(page: Page, path: string) = 
  page.directoryList.setFile(gio.newGFileForPath(path.cstring))
  changeState(path)
