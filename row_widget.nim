import gintro/[gtk4, gobject, gio, pango]
import std/with


type 
  FileRow* {.requiresInit.} = ref object of Box 
    info*: gio.FileInfo
    fullPath*: string
    btn1*: ToggleButton
    btn2*: ToggleButton
    image*: Image
    labelFileName*: Label
    pageNum*: int
    btn1SignalId*: uint64 # if signal disconnect problems, change to culong
    btn2SignalId*: uint64 # if signal disconnect problems, change to culong
    # btnReveal3SignalId*: uint64 # if signal disconnect problems, change to culong

proc `iconName=`*(self: FileRow, iconName: string) =
  self.image.setFromIconName(iconName)



proc createFileRowWidget*(pageNum: int, name: string, reveal: Revealer = nil): FileRow = 
  let 
    row = newBox(FileRow, Orientation.horizontal, 0)
    # labelFileName = newLabel(name)
    buttonBox = newBox(Orientation.horizontal, 5)

  row.labelFileName = newLabel(name)
  row.image = newImage()
  row.btn1 = newToggleButton()
  row.btn2 = newToggleButton("↪")
  
  
  with buttonBox:
    # setCssClasses("linked")
    append row.image
    append row.labelFileName

  

  with row.labelFileName:
    ellipsize = EllipsizeMode.middle
    maxWidthChars = 13

  # row.btn1.child = buttonBox
  # row.btn1.hexpand = true
  with row.btn1:
    child = row.image
    hexpand = true


  with row:
    setCssClasses("linked")
    append row.btn1
    append row.btn2
    pageNum = pageNum

  result = row

