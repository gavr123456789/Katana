import gintro/[gtk4, gobject, gio]
import std/with
import createSlot

proc createListBox*(names: seq[string]): Frame =
  let
    frame = newFrame()
    listBox = newListBox()

  with listBox:
    selectionMode = SelectionMode.browse
    showSeparators = true
    # setCssClasses("rich-list")
    setCssClasses("navigation-sidebar")
    # setCssClasses("data-table")

  for name in names:
    listBox.append createSlot(name)

  frame.child = listBox
  result = frame