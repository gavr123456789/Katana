import gintro/[gtk4, gobject, gio, pango, glib, adw]

type 
  DirOrFile* = enum
    file
    dir

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
  # For gesture click
  PageAndFileInfoAndButton* = object
    page*: Page  
    info*: gio.FileInfo
    button*: ToggleButton
  PageAndWidget* = object
    page*: Page  
    widget*: Widget


proc changeActivatedArrowBtn*(page: Page, btn: ToggleButton) =
  assert page != nil
  if page.activatedArrowBtn == btn: return

  if page.activatedArrowBtn != nil:
    page.activatedArrowBtn.active = false
  
  page.activatedArrowBtn = btn
  # btn2.active = true

proc `iconName=`*(row: Row, iconName: string) =
  row.image.setFromIconName(iconName)

import os
proc getFullPathFromPageAndFileInfo*(pageAndFileInfo: PageAndFileInfo): string = 
  pageAndFileInfo.page.directoryList.file.path / pageAndFileInfo.info.name