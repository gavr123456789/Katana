import gintro/[gtk4, gdk4, gobject, gio]

proc createBoxWithPlayer*(path: string): Box =
  result = newBox(Orientation.horizontal, 0)
  # result.homogeneous = true
  let
    mediaFile = newMediaFileForFilename(path)
    mediaControls = newMediaControls(mediaFile)
  result.append mediaControls
  mediaControls.hexpand = true