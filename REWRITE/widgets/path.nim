import gintro/[gtk4, gobject, gio, pango, glib, adw]
import json

let x = json.JObject

type 
  PathWidget* = ref object of Box
    backBtn*: Button
    entry*: Entry

# back btn, Stack((lidt of pathBtn)(text input))
proc createPathWidget*(dir: string): PathWidget = 
  let 
    pathWidget = newBox(PathWidget, Orientation.horizontal, 0)
    pathEntry = newEntry()
  
  
  pathWidget.cssClasses = "linked"

  pathWidget.append pathEntry



  result = pathWidget

