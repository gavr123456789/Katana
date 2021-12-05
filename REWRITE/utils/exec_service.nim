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

proc runShFileInTerminal*(shPath: string) =
  if terminal != "":
    os.setCurrentDir shPath.splitPath().head
    let runInTermCommand = terminal & " -- bash -c \" " & shPath & "; exec bash\""
    discard os.execShellCmd(runInTermCommand)
  else:
    echo "Terminal program not found!"