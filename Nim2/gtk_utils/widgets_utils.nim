import gintro/[gtk4, gobject, gio, pango, glib, adw]
import std/with

proc inToScroll*(widget: Widget): ScrolledWindow =
  result = newScrolledWindow()
  result.minContentWidth = 240
  result.setPropagateNaturalWidth true
  result.setPropagateNaturalHeight true
  result.vexpand = true
  # result.hexpand = true
  result.child = widget


proc createButtonWithLabelAndImage*(image: Image, labelFileName: Label): ToggleButton =
  let 
    toggleButton = newToggleButton()
    buttonChildBox = newBox(Orientation.horizontal, 4)

  with buttonChildBox:
    append image
    append labelFileName

  with labelFileName:
    # ellipsize = EllipsizeMode.middle
    wrap = true
    wrapMode = pango.WrapMode.wordChar
    maxWidthChars = 15
  
  toggleButton.child = buttonChildBox
  toggleButton.hexpand = true

  result = toggleButton