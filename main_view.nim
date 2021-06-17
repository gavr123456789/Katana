import gintro/[adw, gtk4, gobject, gio]
import std/with
import carousel_widget, list_view
import gtk_helpers




proc activate(app: gtk4.Application) =
  let
    window = adw.newApplicationWindow(app)
    header = adw.newHeaderBar()
    adwBox = newBox(Orientation.vertical, 0)
    listView = createListView(".", 0).inToScroll
    mainBox = newBox(Orientation.vertical, 0)
    reveal = newRevealer()
    centerBox = newCenterBox()
    revealBox = newBox(Orientation.vertical, 0)
    revealBtn1 = newButton("1")
    revealBtn2 = newButton("2")
    revealBtn3 = newButton("3")

  with revealBox:
    orientation = Orientation.horizontal
    append revealBtn1
    append revealBtn2
    append revealBtn3
  
  centerBox.endWidget = revealBox

  reveal.child = centerBox

  carouselGb = createCarousel(listView)
  carouselGb.vexpand = true
    
  with mainBox:
    marginStart = 60
    marginEnd = 60
    marginTop = 30
    marginBottom = 30
    append carouselGb

  with adwBox:
    append header 
    append reveal
    append mainBox

  with window:
    defaultSize = (400, 600)
    title = "ListView"
    setChild adwBox
    show

proc main =
  let app = newApplication("org.gtk.example")
  app.connect("activate", activate)
  discard run(app)

main()
