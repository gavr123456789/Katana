import gintro/[gtk4, gobject]
import std/with

const MEDIA_START = "media-playback-start-symbolic"
const MEDIA_STOP = "media-playback-stop-symbolic"
const FOLDER_OPEN = "folder-open-symbolic"
const FOLDER_CLOSED = "gnome-folder-symbolic"

proc createSlot*(text: string): gtk4.ListBoxRow = 
  let 
    box_row = newBox(Orientation.horizontal, 5)
    label = newLabel(text)
    image = newImageFromIconName(FOLDER_CLOSED)
    list_box_row = newListBoxRow()
    # toggle_btn = newToggleButtonWithMnemonic(text)
    # arrow_toggle_button = newToggleButton()
    
  # box_row.setCssClasses("linked")
  with label: 
    hexpand = true
  # with arrow_toggle_button:
    # set_child image

  with box_row:
    append label 
    append image
  
  # list_box_row.connect("activate", row_activate)
  
  # list_box_row.activate()


  list_box_row.child = box_row
  return list_box_row