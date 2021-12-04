import gintro/[gio]
import sets, os

# type FilesAndDirs = object
#   files: HashSet[string]
#   dirs: HashSet[string]

# func separateFilesFromDirs(paths: HashSet[string]): FilesAndDirs =
  

proc deleteAllFilesAsync*(paths: HashSet[string]) =
  for path in paths:
    # let a = splitFile(path)
    # TODO не удаляет папки
    let xfile = gio.newGFileForPath(path.cstring)
    xfile.deleteAsync(10, nil, nil, nil)

