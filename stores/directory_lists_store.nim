import gintro/[gtk4, gio]
import tables

var directoryListsStoreGb* = newTable[int, gtk4.DirectoryList]()

proc printDirectoryListsStore*(self: Table[int, gtk4.DirectoryList]) = 
  for x, y in self.pairs:
    echo $x, ": ", y.file.basename
  echo "\n"