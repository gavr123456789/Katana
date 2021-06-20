import gintro/[gtk4, gio]
import tables, os

var directoryListsStoreGb* = newTable[int, gtk4.DirectoryList]()

proc printDirectoryListsStore*(self: TableRef[int, gtk4.DirectoryList]) = 
  for x, y in self.pairs:
    echo $x, ": ", y.file.path / y.file.basename
  echo "\n"