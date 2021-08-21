import gintro/[gtk4, gobject, gio, pango, glib, adw]
import std/with
import ../types
import os
import ../utils/ext_to_icons

proc setAsDir(row: Row, name: string) =
  row.kind = DirOrFile.dir
  row.iconName = getFolderIconFromName(name)
  

proc setAsFile(row: Row, ext: string) =
  row.kind = DirOrFile.file
  row.iconName = getFileIconFromExt(ext) 

proc set_file_row_for_file*(row: Row, fileInfo: gio.FileInfo) =
  let
    fileType = fileInfo.fileType
    # fileName = fileInfo.name
    (_, name, ext) = fileInfo.getName().splitFile()
    isDir = ext == ""

  row.labelFileName.text = fileInfo.name

  if fileInfo.isHidden == true:
    row.opacity = 0.5
  
  case fileType:
  of gio.FileType.unknown:
    # let (_, name, ext) = fileInfo.getName().splitFile()
    # let isDir = ext == ""
    
    if isDir:
      setAsDir(row, name)
    else:
      setAsFile(row, ext)


  of regular:
    echo name, "regular"
    setAsFile(row, name)
      
  of directory:
    echo name, " directory"
    setAsDir(row, ext)

  of symbolicLink, special, shortcut, mountable:
    echo name, " is something else"
