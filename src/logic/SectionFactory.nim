import os, sequtils
import Slot
import Section

# функция принимает путь и возвращает seq слотов
proc dir_view*(start_dir_path: string, hidden: bool, num_in_manager: int): Section =
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
  
  let allSlots = dirs_list.concat files_list
  let section = newSection(allSlots, num_in_manager)
  result = section

when isMainModule:
  let sas = dir_view(os.getCurrentDir().parentDir(), true, 0)
  