import gintro/[gtk4, gobject, gio, pango, glib, adw]

type 
  DirOrFile* = enum
    file
    dir

  Page* = ref object of Box
    revealer*: Revealer
    activatedArrowBtn*: ToggleButton
    directoryList*: DirectoryList
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


proc changeActivatedArrowBtn*(self: Page, btn: ToggleButton) =
  assert self != nil
  if self.activatedArrowBtn == btn: return

  if self.activatedArrowBtn != nil:
    self.activatedArrowBtn.active = false
  
  self.activatedArrowBtn = btn
  # btn2.active = true

proc `iconName=`*(self: Row, iconName: string) =
  self.image.setFromIconName(iconName)