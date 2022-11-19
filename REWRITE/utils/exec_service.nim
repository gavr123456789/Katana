import std/[os]

var terminal: string = ""

proc determinateTermProgram = 
  if os.findExe("gnome-terminal") != "":
    terminal = "gnome-terminal"
  elif os.findExe("kde-terminal") != "":
    terminal = "kde-terminal"
  elif os.findExe("cmd") != "":
    terminal = "cmd"
  echo "found ", terminal, " terminal"

determinateTermProgram()

proc runCommandInDir*(command, path: string) =
  
  echo "runCommandInDir command: ", command, " path: ", path 
  os.setCurrentDir path
  discard os.execShellCmd(command)

proc runCommandInTerminal*(command, path: string) =
  if terminal != "":
    os.setCurrentDir path.splitPath().head
    let runInTermCommand = terminal & " -- bash -c \" " & command & "; exec bash\""
    echo "command to run: ", runInTermCommand

    discard os.execShellCmd(runInTermCommand)
  else:
    echo "Terminal program not found!"

proc runShFileInTerminal*(shPath: string) =
  if terminal != "":
    os.setCurrentDir shPath.splitPath().head
    let runInTermCommand = terminal & " -- bash -c \" " & shPath & "; exec bash\""
    echo "command to run: ", runInTermCommand

    discard os.execShellCmd(runInTermCommand)
  else:
    echo "Terminal program not found!"