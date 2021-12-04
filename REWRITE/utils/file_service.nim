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

proc moveAllFilesAsync*(paths: HashSet[string], targetPath: string) =
  for path in paths:
    let 
      xfile = gio.newGFileForPath(path.cstring)
      targetFile = gio.newGFileForPath(targetPath.cstring)
    if path.splitPath().head != targetPath:
      echo xfile.move(targetFile, {gio.FileCopyFlag.backup}, nil, nil, nil)
    else:
      echo "file ", path, " already in ", targetPath

proc getAllFilesFromDir*(path: string): HashSet[string] = 
  for file in path.walkDirRec():
    echo file
    result.incl file