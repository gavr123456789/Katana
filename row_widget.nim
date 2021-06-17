import gintro/[gtk4, gobject, gio, pango]
import std/with


type 
  Row* {.requiresInit.} = ref object of Box 
    info*: gio.FileInfo
    btn1*: ToggleButton
    btn2*: ToggleButton
    pageNum*: int

proc createRowWidget*(pageNum: int, name: string): Row = 
  let 
    row = newBox(Row, Orientation.horizontal, 0)
    labelFileName = newLabel(name)
  row.btn1 = newToggleButton()
  row.btn2 = newToggleButton("↪")
  
  with labelFileName:
    ellipsize = EllipsizeMode.middle
    maxWidthChars = 10

  with row.btn1:
    child = labelFileName
    hexpand = true


  with row:
    setCssClasses("linked")
    append row.btn1
    append row.btn2
    pageNum = pageNum
  result = row

