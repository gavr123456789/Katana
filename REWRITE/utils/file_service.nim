import gintro/[gio]
import sets, os

proc deleteAllFoldersAsync*(paths: HashSet[string]) =
  for path in paths:
    os.removeDir path

proc deleteAllFilesAsync*(paths: HashSet[string]) =
  for path in paths:
    let xfile = gio.newGFileForPath(path.cstring)
    xfile.deleteAsync(10, nil, nil, nil)

proc moveAllFoldersAsync*(paths: HashSet[string], targetPath: string) =
  for path in paths:
    try:
      echo "trying to move from ", path, " to ", targetPath
      let q = path.extractFilename()
      moveDir(path, targetPath / q)
      
    except OSError:
      let
        e = getCurrentException()
        msg = getCurrentExceptionMsg()
      echo "error ", repr(e), " with message: ", msg
proc moveAllFilesAsync*(paths: HashSet[string], targetPath: string) =
  for path in paths:
    try:
      echo "trying to move from ", path, " to ", targetPath
      let q = path.extractFilename()
      moveFile(path, targetPath / q)
      
    except OSError:
      let
        e = getCurrentException()
        msg = getCurrentExceptionMsg()
      echo "error ", repr(e), " with message: ", msg


proc copyAllFoldersAsync*(paths: HashSet[string], targetPath: string) =
  for path in paths:
    try:
      echo "trying to move from ", path, " to ", targetPath
      let q = path.extractFilename()
      copyDir(path, targetPath / q)
      
    except OSError:
      let
        e = getCurrentException()
        msg = getCurrentExceptionMsg()
      echo "error ", repr(e), " with message: ", msg
proc copyAllFilesAsync*(paths: HashSet[string], targetPath: string) =
  for path in paths:
    try:
      echo "trying to move from ", path, " to ", targetPath
      let q = path.extractFilename()
      copyFile(path, targetPath / q)
      
    except OSError:
      let
        e = getCurrentException()
        msg = getCurrentExceptionMsg()
      echo "error ", repr(e), " with message: ", msg


proc getAllFilesFromDir*(path: string): HashSet[string] = 
  for file in path.walkDirRec():
    echo file
    result.incl file


proc renameFile(path, newName: string) {.inline.} = 
  moveFile(path, path.splitPath().head / newName)

import std/tables
proc renameFiles*(paths: HashSet[string], newName: string) =
  if paths.len == 1:
    for path in paths:
      moveFile(path, path.splitPath().head / newName)
      return


  # найти те файлы что лежат в одной и той же папке
  var sas = initTable[string, HashSet[string]]()
  for path in paths:
    sas[path.splitPath().head].incl path # хешсет не был засечен чтобы в него уже чето инклюдить

  # пути к файлам которые там лежат
  echo sas
  # for path in sas.keys:
  #   echo "key: ", path, " value: ", sas[path]
  #   echo "==="
  
  # for path in paths:
  #   renameFile(path, newName)