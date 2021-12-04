import os, strutils

type GlobalPath* = ref object
    path: string

proc addToPath*(self: GlobalPath, dirOrFile: string) =
  self.path = self.path / dirOrFile

proc insertPath*(self: GlobalPath, path: string) =
# сравниваем каждый из элементов текущего пути и пришедшего
# начиная с первого отличающегося заменяем каждый последующий
  var selfSplitted = self.path.split DirSep
  let pathSplitted = path.split DirSep
  var diffStartFrom: int

  for i in 0..selfSplitted.high:
    if selfSplitted[i] != pathSplitted[i]:
      diffStartFrom = i
  
  if diffStartFrom != 0:
    for i in 0..diffStartFrom:
      selfSplitted[i] = pathSplitted[i]
  
  self.path = selfSplitted.join $DirSep


proc setPath*(self: GlobalPath, path: string) =
  assert DirSep in path or path == "."
  self.path = path


# /1/2/3, get 2 will return /1/2
proc getNPath*(self: GlobalPath, n: int): string =
  let x = self.path.split DirSep
  var y: seq[string]
  if x.len == 1:
    return x[0]

  assert x.len >= n
  for i in 0..<n:
    y.add x[i]

  result = y.join $DirSep



when isMainModule:
  let globalPath = GlobalPath()
  globalPath.setPath "a/b/c"
  assert globalPath.path == "a/b/c"

  globalPath.addToPath "d"
  assert globalPath.path == "a/b/c/d"

  assert (globalPath.getNPath 3) == "a/b/c"
  assert (globalPath.getNPath 2) == "a/b"

  globalPath.insertPath("a/b/q/w/e")





