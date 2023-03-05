import std/strutils
import unpack

const desktopExample = """[Desktop Entry]
Name=Creaks
Exec="/home/gavr/bin/Games/Creaks/run.sh"
Icon=/home/gavr/bin/Games/Creaks/Creaks_Data/Resources/UnityPlayer.png
Type=Application
Categories=Game;
StartupNotify=true
Comment=Start Creaks
Comment[ru_RU]=Запустить Creaks
"""

type DesktopEntry = object 
  name: string
  exec: string
  icon: string
  categories: seq[string]


proc parseDesktop(filePath: string): DesktopEntry = 
  doAssert(filePath.endsWith(".desktop"))
  let x = readFile(filePath).split('\n')[1..^1]
  for line in x:
    if line.startsWith('[') or line.startsWith('\n') or line == "":
      continue
    echo line
    echo line.split '='
    [firstPart, secondPart] <- line.split('=')
    case firstPart:
    of "Name":
      result.name = secondPart
    of "Exec":
      result.exec = secondPart
    of "Categories":
      result.categories = secondPart.split(';')[0..^2] # todo
    of "Icon":
      result.icon = secondPart
    
    


echo parseDesktop("Creaks.desktop")
