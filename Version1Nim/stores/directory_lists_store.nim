import gintro/[gtk4, gio]
import tables, os
import selected_store

let directoryListsStoreGb* = newTable[int, gtk4.DirectoryList]()

proc printDirectoryListsStore*(self: TableRef[int, gtk4.DirectoryList]) = 
  for x, y in self.pairs:
    echo $x, ": ", y.file.path / y.file.basename
  echo "\n"

func getAllListStores*(self: TableRef[int, gtk4.DirectoryList]): seq[gtk4.DirectoryList] = 
  for dirList in self.values:
    result.add dirList


proc unselectAllOnEveryPage() = 
  let allDirLists = getAllListStores(directoryListsStoreGb)
  # for dir in allDirLists:
    # dir.listModel.