import gintro/[gtk4]
import std/with, hashes

proc setStartRowParams*(widget: gtk4.Widget) =
  when widget is Label:
    widget.xalign = 0

  with widget:
    halign = Align.start
    valign = Align.center
    hexpand = true

proc setEndRowParams*(widget: Widget) =
  when widget is Label:
    widget.xalign = 0
    
  with widget:
    halign = Align.end
    valign = Align.center
    hexpand = true
  
proc hash*(w: Widget): Hash = 
  result =  cast[Hash](cast[uint](w) shr 3)
  echo result

proc echoIntPtr*(intPtr: pointer) = 
  echo (cast[ptr int](intPtr))[] 