import gintro/[gtk4, gobject, gio]
import std/with

proc createSlot*(text: string): gtk4.Box = 
  let 
    box_row = newBox(Orientation.horizontal, 0)
    # toggle_btn = newToggleButtonWithMnemonic(text)
    label = newLabel(text)
    image = newImageFromIconName("media-playback-start-symbolic")
    # arrow_toggle_button = newToggleButton()
    
  box_row.setCssClasses("linked")
  with label: 
    hexpand = true
  # with arrow_toggle_button:
    # set_child image

  with box_row:
    append label 
    append image
  
  return box_row