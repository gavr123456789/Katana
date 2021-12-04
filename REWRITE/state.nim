import sets
import utils/[pathUtils, file_service]
import types
# import widgets/[path]
# var selectedPathGb: string
var selectedPathGb2: GlobalPath = GlobalPath()

var pathWidget*: PathWidget 
var selectedFilesRevealer*: RevealerWithCounter

# TODO добавить отдельно такую же для папок
var selectedFilesPaths: HashSet[string] 
var selectedFoldersPaths: HashSet[string] 

proc addToSelectedFiles*(path: string) =
  selectedFilesPaths.incl path
  echo "current selected files: ", selectedFilesPaths

proc deleteFromSelectedFiles*(path: string) =
  selectedFilesPaths.excl path
  echo "current selected folder: ", selectedFilesPaths


proc addToSelectedFolders*(path: string) =
  selectedFoldersPaths.incl path
  echo "current selected folder: ", selectedFoldersPaths

proc deleteFromSelectedFolders*(path: string) =
  selectedFoldersPaths.excl path
  echo "current selected paths: ", selectedFoldersPaths


proc getCountOfSelectedFilesAndFolders*(): int = 
  selectedFilesPaths.len + selectedFoldersPaths.len

proc deleteAllSelectedFiles*() = 
  deleteAllFilesAsync(selectedFilesPaths)


proc changeCurrentPath*(selectedPath: string) = 
  echo "selectedPathGb changed to ", selectedPath
  # selectedPathGb = selectedPath
  selectedPathGb2.setPath selectedPath

