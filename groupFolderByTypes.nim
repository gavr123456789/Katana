import tables, os

type AnyTable = Table[string, seq[string]] or TableRef[string, seq[string]]

### PACK


func add(table: var AnyTable, key: string, value: string) =
  if table.hasKeyOrPut(key, @[value]):
    table[key].add value


proc moveFiles(files: seq[string], dest: string) =
  for file in files:
    echo "try to move file: ", file, " to dir: ", dest

    file.moveFile(dest / lastPathPart file)

proc collectFilePathsByType(dir: string): TableRef[string, seq[string]] =
  var typeToPath = newTable[string, seq[string]]()
  for kind, path in walkDir(dir):
    if kind == pcFile:
      let (path, name, ext) = path.splitFile()
      typeToPath.add(ext, path/name & ext)
  result = typeToPath

proc groupFolderByTypes*(dir: string) =
  let filePaths = collectFilePathsByType dir
  for key, value in filePaths:
    echo key , " ", value
    let dest = dir / "_" & key[1 .. ^1]
    createDir(dest)
    moveFiles(value, dest) 

### UNPACK
import strutils
proc collectFilesFromDir(dir: string, startedWith: string = ""): seq[string] = 
  if startedWith == "":
    for kind, path in walkDir(dir):
      result.add path
  else: 
    for kind, path in walkDir(dir):
      if path.lastPathPart.startsWith startedWith:
        result.add path

proc deleteDirs(dirs: seq[string]) = 
  for dir in dirs:
    removeDir dir

proc unpackFilesFromDirsTo(dirs: seq[string], to: string) = 
  for dir in dirs: 
    let filesFromDir = collectFilesFromDir(dir)
    moveFiles(filesFromDir, to)
      
    

proc collectDirsStartedFromUnderscore(dir: string): seq[string] = collectFilesFromDir(dir, "_")

proc unpackFilesFromFoldersByTypes*(dir: string) = 
  let dirsStartedFromUnderscore = collectDirsStartedFromUnderscore(dir)
  if dirsStartedFromUnderscore.len > 0:
    unpackFilesFromDirsTo(dirsStartedFromUnderscore, dir)
    deleteDirs(dirsStartedFromUnderscore)
  else: 
    debugEcho "dirs started with underscore not found"


when isMainModule:
  let TEST_FOLDER = getCurrentDir() / "test_folder"
  groupFolderByTypes TEST_FOLDER
  # unpackFilesFromFoldersByTypes TEST_FOLDER