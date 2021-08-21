import gintro/[gtk4, gobject, gio, pango, glib, adw]
import std/with


proc createButtonWithLabelAndImage*(image: Image, labelFileName: Label): ToggleButton =
  let 
    toggleButton = newToggleButton()
    buttonChildBox = newBox(Orientation.horizontal, 5)

  echo image == nil
  echo labelFileName == nil
  with buttonChildBox:
    append image
    append labelFileName

  with labelFileName:
    wrap = true
    wrapMode = pango.WrapMode.wordChar
    # ellipsize = EllipsizeMode.middle
    maxWidthChars = 15
  
  toggleButton.child = buttonChildBox
  toggleButton.hexpand = true

  result = toggleButton