import gintro/[gtk4]
import std/with

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