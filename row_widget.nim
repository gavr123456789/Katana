import gintro/[gtk4, gobject, gio, pango]
import std/with


type 
  Row* {.requiresInit.} = ref object of Box 
    info*: gio.FileInfo
    fullPath*: string
    btn1*: ToggleButton
    btn2*: ToggleButton
    image*: Image
    labelFileName*: Label
    pageNum*: int
    btn2SignalId*: uint64 # if signal disconnect problems, change to culong
    btn1SignalId*: uint64 # if signal disconnect problems, change to culong

proc `iconName=`*(self: Row, iconName: string) =
  self.image.setFromIconName(iconName)

proc createRowWidget*(pageNum: int, name: string): Row = 
  let 
    row = newBox(Row, Orientation.horizontal, 0)
    # labelFileName = newLabel(name)
    box = newBox(Orientation.horizontal, 5)

  row.labelFileName = newLabel(name)
  row.image = newImage()
  row.btn1 = newToggleButton()
  row.btn2 = newToggleButton("↪")
  
  
  with box:
    # setCssClasses("linked")
    append row.image
    append row.labelFileName

  with row.labelFileName:
    ellipsize = EllipsizeMode.middle
    maxWidthChars = 13

  row.btn1.child = box
  row.btn1.hexpand = true
  # with row.btn1:
  #   child = row.image
  #   hexpand = true


  with row:
    setCssClasses("linked")
    append row.btn1
    append row.btn2
    pageNum = pageNum
  result = row

