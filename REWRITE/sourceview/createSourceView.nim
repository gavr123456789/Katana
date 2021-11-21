import gintro/[gtk4, gobject, gio, pango, adw, glib, gdk4, gtksource5]
import std/with

proc createSourceView*(): gtksource5.View =
  let 
    buffer = newBuffer()
    # sourceView =
  result = newViewWithBuffer(buffer)



proc getCompletionBtnCb(btn: Button) = 
  echo "sas"

proc createPage*(getCompletitionBtn: Button): ScrolledWindow = 
  let 
    sourceView = createSourceView()
    sourceCompletion = sourceView.completion
    sourceBuffer = sourceView.buffer.Buffer
    scrolledWindow = newScrolledWindow()

    langManager = newLanguageManager()
    lang = langManager.getLanguage("typescript-jsx")

    wordsComplitter = newCompletionWords("words")

  # var lang = guessLanguage(langManager, files[0].path, nil)
  # add word provider
  sourceCompletion.addProvider wordsComplitter
  wordsComplitter.registerCompletionWords(sourceBuffer)

  # add syntax highlight
  echo langManager.getLanguageIds()
  sourceBuffer.setLanguage(lang)

  # set nim scheme
  
  with sourceView:
    enableSnippets = true
    showLineNumbers = true
    monospace = true
    autoIndent = true
    leftMargin = 2
    rightMargin = 2
    hexpand = true
    vexpand = true
  # with scrolledWindow:
  #   hexpand = true
  #   vexpand = true
  
  # connects
  getCompletitionBtn.connect("clicked", getCompletionBtnCb)

  scrolledWindow.child = sourceView
  result = scrolledWindow




