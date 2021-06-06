import gintro/[gtk4, gobject, gio]
import std/with

type 
  Row* {.requiresInit.} = ref object of Box 
    info*: gio.FileInfo
    btn1*: Button
    btn2*: Button
    pageNum*: int

proc createRowWidget*(pageNum: int, name: string): Row = 
  let 
    row = newBox(Row, Orientation.horizontal, 0)
  row.btn1 = newButton(name)
  row.btn1.hexpand = true
  row.btn2 = newButton("2")

  with row:
    setCssClasses("linked")
    append row.btn1
    append row.btn2
    pageNum = pageNum
    # info = info
  result = row