import gintro/[adw, gtk4, gobject, gio, gdk4, glib]
import std/with, tables

var openedFilesStoreGb* = newTable[int, seq[MediaFile]]()


proc closeFilesOnPage*(paneNum: int) =
  for mediaFile in openedFilesStoreGb[paneNum]:
    echo "closing file", mediaFile.file.getPath
    echo mediaFile.getInputStream().close()
  openedFilesStoreGb.del paneNum