import gintro/[gtk4, gobject, gio, pango, glib, adw]
import os, strutils, std/with
import ../utils/path

type 
  PathWidget* = ref object of Box
    backBtn*: Button
    entry*: Entry
    path: GlobalPath
  
  ToggleWithNum = ref object of ToggleButton
    num: int

  Data = tuple
    toggleBtn: ToggleWithNum
    path: GlobalPath

  MiddleClick = proc (self: GestureClick, nPress: int, x: cdouble, y: cdouble, arg: ToggleWithNum){.closure.}



proc gestureMiddleClickCb(self: GestureClick, nPress: int, x: cdouble, y: cdouble, data: Data) =
  echo data.path.getNPath data.toggleBtn.num + 1


proc addMiddleClick(toggleBtn: ToggleWithNum, path: GlobalPath ) =
  let gestureClick = newGestureClick()
  gestureClick.setButton(2)
  gestureClick.connect("pressed", gestureMiddleClickCb, (toggleBtn, path)) # TODO fun
  toggleBtn.addController(gestureClick)

proc createPathWidget*(path: string): PathWidget = 
  # static: assert (DirSep in path or "." in path)

  let 
    pathWidget = newBox(PathWidget, Orientation.horizontal, 0)

  pathWidget.cssClasses = "linked"
  result = pathWidget

  result.path = GlobalPath()
  result.path.setPath path
    
  let 
    splittedPath = path.split DirSep

  var prevToggleBtn = newToggleButton(ToggleWithNum, splittedPath[0])
  prevToggleBtn.addMiddleClick(result.path)
  prevToggleBtn.num = 0

  pathWidget.append prevToggleBtn

  for i, str in splittedPath[1..^1]:
    let 
      toggleBtn = newToggleButton(ToggleWithNum, str)
    toggleBtn.addMiddleClick(result.path)
    toggleBtn.num = i + 1

    toggleBtn.group = prevToggleBtn
    prevToggleBtn = toggleBtn

    # pathWidget.append toggleBtn
  

proc addToPathWidget(self: PathWidget, path: string) = 
  self.path.addToPath path
  let tglBtn = newToggleButton()
  # ...

when isMainModule:
  proc activate(app: gtk4.Application) =
    let
      window = adw.newApplicationWindow(app)
      mainBox = newBox(Orientation.vertical, 5)
      
      header = adw.newHeaderBar()

    with mainBox: 
      append header
      append createPathWidget("a/b/c/d.txt")
  

    with window:
      child = mainBox
      title = "Katana path widget"
      defaultSize = (100, 100)
      show

  proc main() =
    let app = newApplication("org.gtk.example")
    app.connect("activate", activate)
    discard run(app)
  
  main()