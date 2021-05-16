import gintro/[gtk4, gobject, gio]
import view/MainWindow


proc main =
  let app = newApplication("org.gtk.example")
  app.connect("activate", activate)
  discard run(app)

main()