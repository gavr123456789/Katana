import gintro/[gtk4, gobject, gio, pango, glib, adw]
import std/with
import ../types
import os
import ../utils/ext_to_icons

proc setAsDir(row: Row, name: string) =
  row.kind = DirOrFile.dir
  row.iconName = getFolderIconFromName(name)
  

proc setAsFile(row: Row, ext: string) =
  # doAssert ext != ""
  row.kind = DirOrFile.file
  # debugEcho "set file ", ext, " for icon"
  row.iconName = getFileIconFromExt(ext) 

proc set_file_row_for_file*(row: Row, fileInfo: gio.FileInfo) =
  let
    fileType = fileInfo.fileType
    # fileName = fileInfo.name
    (_, name, ext) = fileInfo.getName().splitFile()
    isDir = ext == ""
  # echo "yyyyL: ", fileInfo.getName().splitFile()
  row.labelFileName.text = fileInfo.name.cstring

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
    setAsFile(row, ext)
      
  of directory:
    row.setAsDir name

  of symbolicLink, special, shortcut, mountable:
    echo name, " is something else"
