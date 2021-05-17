import gintro/[gtk4, gobject]
import std/with, std/tables
import CreateSlot

const FOLDER_OPEN = "folder-open-symbolic"
const FOLDER_CLOSED = "gnome-folder-symbolic"

var last_activated_row: Image

proc row_activated_cb(self: ListBox, row: ListBoxRow) =
  
  let icon = row.getChild().Box.getLastChild().Image

  icon.setFromIconName(FOLDER_OPEN)

  if last_activated_row != nil: 
    last_activated_row.setFromIconName(FOLDER_CLOSED)

  last_activated_row = icon
  debugecho "row_activated_cb"

proc createSection*(names: seq[string]): Frame =
  let
    frame = newFrame()
    listBox = newListBox()

  with listBox:
    selectionMode = SelectionMode.single
    showSeparators = true
    setCssClasses("rich-list")
    # setCssClasses("navigation-sidebar")
    # setCssClasses("data-table")
  
  listBox.connect("row-activated", row_activated_cb)

  for name in names:
    listBox.append createSlot(name)

  frame.child = listBox
  result = frame