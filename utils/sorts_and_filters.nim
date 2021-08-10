import gintro/[gtk4, gobject, gio, adw]

proc gintro_hack*(f: auto, p: auto) =
  f.impl = p
  f.ignoreFinalizer = true # fast hack, we would use a {.global.} var in the macro. Or maybe do in a other way?

# sords
proc sortAlphabet*(fileInfo: ptr FileInfo00): cstring {.cdecl.} = 
  var f = newFileInfo()
  gintro_hack(f, fileInfo)
  result = g_strdup(f.getName() )
  
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
proc filterHidden*(fileInfo: ptr FileInfo00): bool {.cdecl.} = 
  # var f = newFileInfo()
  # gintro_hack(f, fileInfo)
  # echo "filterHidden", not f.isHidden, "name: ", f.getName
  result = true

  # result = not f.isHidden

proc filterHidden2*(fileInfo: ptr FileInfo00): bool = 
  var f = newFileInfo()
  gintro_hack(f, fileInfo)

  if f.isHidden():
    echo " name: ", f.getName, " true" 
    return true
  else: 
    echo " name: ", f.getName, " false" 
    return false
  # var sass = f.isHidden()
  # echo "filterHidden2 ", not f.isHidden, " name: ", f.getName

  # return not sass# not f.getName.startsWith "."
  # result = not f.isHidden
