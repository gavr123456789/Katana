import gintro/[adw, gtk4, gobject, gio, gdk4, glib]
import std/with, tables

# var openedFiles: seq[]
var openedFilesStoreGb* = newTable[int, gtk4.DirectoryList]()