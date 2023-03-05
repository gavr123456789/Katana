import gintro/[gtk4, gdk4, gobject, gio, glib]
proc openFileInApp*(filePath: cstring) =
  let file = gio.newGFileForPath(filePath)
  gtk4.showUri(nil, file.uri, gdk4.CURRENT_TIME)