import gintro/[gtk4, gdk4, gobject, gio]
import ../stores/open_files_store
import tables
import ../utils/table_utils

proc createBoxWithPlayer*(path: string, paneN: int): Box =
  result = newBox(Orientation.horizontal, 0)

  let
    mediaFile = newMediaFileForFilename(path)
    mediaControls = newMediaControls(mediaFile)
  
  openedFilesStoreGb[paneN] = mediaFile

  result.append mediaControls
  mediaControls.hexpand = true

