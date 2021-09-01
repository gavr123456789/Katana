import gintro/[gtk4, gobject, gio, pango, glib, adw]

type 
  DirOrFile* = enum
    file
    dir



type 
  Page* = ref object of Box
    revealer*: Revealer
    activatedArrowBtn*: ToggleButton
    directoryList*: DirectoryList
    selection*: MultiSelection

type
  PageAndFileInfo* = tuple
    page: Page  
    info: gio.FileInfo


proc changeActivatedArrowBtn*(self: Page, btn: ToggleButton) =
  assert self != nil
  if self.activatedArrowBtn == btn: return

  if self.activatedArrowBtn != nil:
    self.activatedArrowBtn.active = false
  
  self.activatedArrowBtn = btn
  # btn2.active = true

type
  Row* = ref object of Box
    btn1*: ToggleButton
    btn2*: ToggleButton
    image*: Image
    labelFileName*: Label
    kind*: DirOrFile
proc `iconName=`*(self: Row, iconName: string) =
  self.image.setFromIconName(iconName)