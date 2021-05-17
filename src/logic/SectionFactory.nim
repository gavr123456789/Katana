import os, sequtils
import Slot

# функция принимает путь и возвращает seq слотов
proc dir_view*(start_dir_path: string, hidden: bool): seq[Slot] =
  debugEcho "start dir = ", start_dir_path
  var files_list: seq[Slot]
  var dirs_list: seq[Slot]

  if hidden:
    for kind, path in walkDir(start_dir_path):
      case kind
      of pcDir, pcLinkToDir:
        dirs_list.add path.splitFile()
      of pcFile, pcLinkToFile:
        files_list.add path.splitFile()
  else:
    for kind, path in walkDir(start_dir_path):
      if not path.isHidden():
        case kind
        of pcDir, pcLinkToDir:
          dirs_list.add path.splitFile()
        of pcFile, pcLinkToFile:
          files_list.add path.splitFile()
  
  result = dirs_list.concat files_list

when isMainModule:
  let sas = dir_view(os.getCurrentDir().parentDir(), true)
  
  echo sas