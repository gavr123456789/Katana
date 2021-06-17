import gintro/[gtk4, gobject, gio]
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
  row.btn1 = newToggleButton(name)
  row.btn1.hexpand = true
  row.btn2 = newToggleButton("↪")

  with row:
    setCssClasses("linked")
    append row.btn1
    append row.btn2
    pageNum = pageNum
    # info = info
  result = row

