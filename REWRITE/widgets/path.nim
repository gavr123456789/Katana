import gintro/[gtk4, gobject, gio, pango, glib, adw]
import os, strutils, std/with
import ../utils/pathUtils
import ../types
import ../state



type 
  ToggleWithNum = ref object of Button
    num: int

  Data = tuple
    toggleBtn: ToggleWithNum
    path: GlobalPath




proc gestureMiddleClickCb(self: GestureClick, nPress: int, x: cdouble, y: cdouble, data: Data) =
  echo data.path.getNPath data.toggleBtn.num + 1


proc addMiddleClick(toggleBtn: ToggleWithNum, path: GlobalPath ) =
  let gestureClick = newGestureClick()
  gestureClick.setButton(2)
  gestureClick.connect("pressed", gestureMiddleClickCb, (toggleBtn, path)) # TODO fun
  toggleBtn.addController(gestureClick)

proc createPathWidget*(path: string): PathWidget = 

  let 
    pathWidget = newBox(PathWidget, Orientation.horizontal, 0)

  pathWidget.cssClasses = "linked"
  result = pathWidget

  result.path = GlobalPath()
  result.path.setPath path
    
  let 
    splittedPath = path.split DirSep

  var prevToggleBtn = newButton(ToggleWithNum, splittedPath[0].cstring)
  prevToggleBtn.addMiddleClick(result.path)
  prevToggleBtn.num = 0

  pathWidget.append prevToggleBtn

  for i, str in splittedPath[1..^2]:
    echo "path widget, path part = ", str
    let 
      toggleBtn = newButton(ToggleWithNum, str.cstring)
    toggleBtn.addMiddleClick(result.path)
    toggleBtn.addCssClass("flat")
    toggleBtn.num = i + 1

    # toggleBtn.group = prevToggleBtn
    prevToggleBtn = toggleBtn

    pathWidget.append toggleBtn
  

proc getPathToFile*(pageAndFileInfo: PageAndFileInfo): string = 
  pageAndFileInfo.page.directoryList.file.path / pageAndFileInfo.info.name

proc getPathFromPage*(page: Page): string = 
  page.directoryList.file.path

proc setPagePath*(page: Page, path: string) = 
  page.directoryList.setFile(gio.newGFileForPath(path.cstring))
  changeCurrentPath(path)



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