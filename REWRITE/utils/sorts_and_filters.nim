import gintro/[gobject, gio]

proc gintro_hack*(f: auto, p: auto) =
  f.impl = p
  f.ignoreFinalizer = true # fast hack, we would use a {.global.} var in the macro. Or maybe do in a other way?

# sords
proc sortAlphabet*(fileInfo: ptr FileInfo00): cstring {.cdecl.} = 
  # echo "sortAlphabet"
  var f = newFileInfo()
  gintro_hack(f, fileInfo)
  result = g_strdup(f.getName().cstring )
  
import strutils
proc sortDotFilesFirst*(fileInfo: ptr FileInfo00): cint {.cdecl.} = 

  var f = newFileInfo()
  gintro_hack(f, fileInfo)

  if f.getName().startsWith("."):
    0
  else: 
    1

proc sortFolderFirst*(fileInfo: ptr FileInfo00): cint {.cdecl.} = 
  var f = newFileInfo()
  gintro_hack(f, fileInfo)
  result = cast[cint] (f.getFileType())

# filters
proc filterHidden22*(fileInfo: ptr FileInfo00): bool {.cdecl.} = 
  var f = newFileInfo()
  gintro_hack(f, fileInfo)
  # return f.isHidden()
  if f.isHidden():
    # echo "         false" 
    return false
  else: 
    # echo " true" 
    return true
