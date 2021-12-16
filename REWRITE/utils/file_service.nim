import gintro/[gio]
import sets, os

# {.push raises:[].}

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
  let sas = path.splitFile()
  let newNameSplited = newName.splitFile()
  # if sas.ext == "" and newNameSplited.ext == "":
  #   moveFile(path, path.splitPath().head / newName)
  # elif sas.ext == "" and newNameSplited.ext != "":
  #   moveFile(path, path.splitPath().head / newName)
  # elif sas.ext != "" and newNameSplited.ext != "":
  #   moveFile(path, path.splitPath().head / newName)
    
  # sas.txt
  # newsas.txt

  if sas.ext != "" and newNameSplited.ext == "":
    moveFile(path, path.splitPath().head / newName & sas.ext)
  else: 
    moveFile(path, path.splitPath().head / newName)


proc renameFolder(path, newName: string) {.inline.} = 
  moveDir(path, path.splitPath().head / newName)

import std/tables
import print
proc renameFiles*(paths: HashSet[string], newName: string) =
  if paths.len == 0: return
    
  if paths.len == 1:
    for path in paths:
      renameFile(path, newName)
      return

proc renameFolders*(paths: HashSet[string], newName: string) {.inline.} =
  if paths.len == 0: return
    
  if paths.len == 1:
    for path in paths:
      renameFolder(path, newName)
      return

  # найти те файлы что лежат в одной и той же папке

  var table = initTable[string, HashSet[string]]()
  for path in paths:
    let asd = path.splitPath().head
    if table.hasKeyOrPut(asd, [path].toHashSet()):
      table[asd].incl path # хешсет не был засечен чтобы в него уже чето инклюдить

  # пути к файлам которые там лежат
  print table

  var counter = 1
  for key in table.keys:
    # если больше одного то к каждой добавлять цифру на конце
    if table[key].len > 1:
      for path in table[key]:
        let splittedFile = newName.splitFile
        if splittedFile.ext != "":
          renameFile(path, splittedFile.name & " " & $counter & splittedFile.ext)
        else:
          renameFile(path, newName & " " & $counter)
        counter.inc
    else:
      for path in table[key]:
        renameFile(path, newName)
    counter = 1
      

    # renameFile(path, newName)

proc setFilesExecutable*(paths: HashSet[string]) {.inline.} = 
  let execPermission = {fpUserExec, fpGroupExec, fpOthersExec}

  for path in paths:
    let currentFilePermission = getFilePermissions(path)
    echo "currentFilePermission.contains FilePermission.fpUserExec = ", currentFilePermission.contains FilePermission.fpUserExec
    echo "currentFilePermission = ", currentFilePermission

    if (currentFilePermission.contains FilePermission.fpUserExec):
      let currentMinusExec = currentFilePermission - execPermission
      echo "permissions to set without exec: ", currentMinusExec
      setFilePermissions(path, currentMinusExec)
    else:
      let currentPlusExec = currentFilePermission + execPermission
      echo "permissions to set with exec: ", currentPlusExec
      setFilePermissions(path, currentPlusExec)

    echo "current file permissions: ", getFilePermissions(path)

