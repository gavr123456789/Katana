import gintro/[gtk4, gobject, gio, pango, glib, adw]
import std/with
import types
import gtk_utils/set_file_row_for_file
import gtk_utils/widgets_utils

proc createRow*(): Row =
  let 
    row = newBox(Row, Orientation.vertical, 0)
    hbox = newBox(Row, Orientation.horizontal, 0)


  row.append hbox

  hbox.cssClasses = "linked"

  row.image = newImage()
  row.labelFileName = newLabel()
  # row.btn1 = newToggleButton()

  row.btn1 = createButtonWithLabelAndImage(row.image, row.labelFileName)
  row.btn2 = newToggleButton()
  # row.btn1.addCssClass("flat")
  # row.btn2.addCssClass("flat")
  row.btn2.label = "→"

  
  hbox.append row.btn1
  hbox.append row.btn2

  result = row




when isMainModule:
  proc activate(app: gtk4.Application) =
    let
      window = adw.newApplicationWindow(app)
      mainBox = newBox(Orientation.vertical, 0)
      file = gio.newGFileForPath(".")
      fileInfo = file.queryInfo("*", {})
      row = createRow()
      header = adw.newHeaderBar()

    row.set_file_row_for_file(fileInfo)

    with mainBox: 
      append header
      append row

    with window:
      content = mainBox
      title = "Katana row"
      defaultSize = (100, 100)
      show

  proc main() =

    let app = newApplication("org.gtk.example")
    app.connect("activate", activate)
    discard run(app)

  main()