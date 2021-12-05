import gintro/[gio]
import sets, os

# type FilesAndDirs = object
#   files: HashSet[string]
#   dirs: HashSet[string]

# func separateFilesFromDirs(paths: HashSet[string]): FilesAndDirs =
  
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


proc optimizeFiles(folders, files: HashSet[string]) =
  discard
  let dummyFolders = toHashSet(["q/w/e", "q/w"]) # оставить только q w
  # 1 - найти минимальную общую точку