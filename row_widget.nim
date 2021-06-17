import gintro/[gtk4, gobject, gio, pango]
import std/with
import types

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
  
  
  labelFileName.ellipsize = EllipsizeMode.middle
  labelFileName.maxWidthChars = 10
  row.btn1 = newToggleButton()
  row.btn1.child = labelFileName
  row.btn1.hexpand = true
  row.btn2 = newToggleButton("↪")

  with row:
    setCssClasses("linked")
    append row.btn1
    append row.btn2
    pageNum = pageNum
    # info = info
  result = row

