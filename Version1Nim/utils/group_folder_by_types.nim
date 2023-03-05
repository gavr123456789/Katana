import tables, os
import table_utils

type 
  GroupFormat* = enum
    byDate
    byType

func addUnderscoreAndRemoveDot(fileExt: string): string = 
  return if fileExt.len > 0: 
        "_" & fileExt[1 .. ^1]
      else: 
        "_NO_FORMAT"

proc moveFiles(files: seq[string], dest: string) =
  for file in files:
    echo "try to move file: ", file, " to dir: ", dest

    file.moveFile(dest / lastPathPart file)

import times, strutils
proc collectFilePathsByType(dir: string): TableRef[string, seq[string]] =
  var typeToPath = newTable[string, seq[string]]()
  for kind, fullPath in walkDir(dir):
    if kind != pcFile: continue
    let 
      (_, _, ext) = fullPath.splitFile()
      extWithoutDot = ext.addUnderscoreAndRemoveDot.toLower
      
    typeToPath.add(extWithoutDot, fullPath)
  result = typeToPath

# import times
proc collectFilePathsByDate(dir: string): TableRef[string, seq[string]] =
  var typeToPath = newTable[string, seq[string]]()
  let f = initTimeFormat("yyyy-MM-dd")
  for kind, fullPath in walkDir(dir):
    if kind == pcFile:
      
      let date = fullPath.getLastAccessTime().local.format(f)

      typeToPath.add("_" & date, fullPath)
  result = typeToPath

proc groupFolderByTypes*(dir: string, groupFormat: GroupFormat) =
  let filePaths =  case groupFormat:
    of byDate: collectFilePathsByDate dir
    of byType: collectFilePathsByType dir

  debugEcho "COLLECTED FILE PATHS BY TYPE: ", filePaths
  for key, value in filePaths:
    echo "key: ", key , " value: ", value

    let dest = dir / key


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
  # groupFolderByTypes(TEST_FOLDER, GroupFormat.byDate)
  unpackFilesFromFoldersByTypes TEST_FOLDER