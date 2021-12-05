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

var lastSelectedPage: Page

proc removeLastSelectedPage*() = 
  lastSelectedPage = nil

# Files
proc addToSelectedFiles*(path: string) =
  selectedFilesPaths.incl path
  echo "current selected files: ", selectedFilesPaths

proc removeFromSelectedFiles*(path: string) =
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
  selectedFilesPaths.clear()
proc deleteAllSelectedFolders*() = 
  deleteAllFoldersAsync(selectedFoldersPaths)
  selectedFoldersPaths.clear()


proc moveAllSelectedFolders*() = 
  moveAllFoldersAsync(selectedFoldersPaths, selectedPathGb2.path)
  selectedFoldersPaths.clear()
proc moveAllSelectedFiles*() = 
  moveAllFilesAsync(selectedFilesPaths, selectedPathGb2.path)
  selectedFilesPaths.clear()

proc copyAllSelectedFolders*() = 
  copyAllFoldersAsync(selectedFoldersPaths, selectedPathGb2.path)
  selectedFoldersPaths.clear()
proc copyAllSelectedFiles*() = 
  copyAllFilesAsync(selectedFilesPaths, selectedPathGb2.path)
  selectedFilesPaths.clear()

proc renameAllFiles*(newName: string) =
  renameFiles(selectedFilesPaths, newName)
  renameFiles(selectedFoldersPaths, newName)
  selectedFoldersPaths.clear()
  selectedFilesPaths.clear()

proc selectedFilesContainsPath*(path: string): bool = 
  selectedFilesPaths.contains path
proc selectedFoldersContainsPath*(path: string): bool = 
  selectedFoldersPaths.contains path


proc changeCurrentPath*(selectedPath: string) = 
  echo "selectedPathGb changed to ", selectedPath
  # selectedPathGb = selectedPath
  selectedPathGb2.setPath selectedPath

proc getCurrentPath*(): string = 
  # selectedPathGb = selectedPath
  selectedPathGb2.path

# GUI
import gintro/gtk4

func `showProgressBar=`(self: Page, revealChild: bool) =
  self.revealer.revealChild = revealChild

proc showProgressBar*(self: Page) = 
  if self == lastSelectedPage:
    return

  if lastSelectedPage == nil:
    lastSelectedPage = self
    self.showProgressBar = true
  else:
    lastSelectedPage.showProgressBar = false
    self.showProgressBar = true
    lastSelectedPage = self


    

