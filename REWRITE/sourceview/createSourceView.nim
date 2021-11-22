import gintro/[gtk4, gobject, gio, pango, adw, glib, gdk4, gtksource5]
import std/with
import createWordCompletion

proc createSourceView*(): gtksource5.View =
  let 
    buffer = newBuffer()
    sourceView = newViewWithBuffer(buffer)
    sourceCompletion = sourceView.completion
    sourceBuffer = sourceView.buffer.Buffer

    langManager = newLanguageManager()
    lang = langManager.getLanguage("typescript-jsx")


  # var lang = guessLanguage(langManager, files[0].path, nil)
  # add word provider
  createWordCompletion(sourceView, sourceCompletion)

  # add syntax highlight
  echo langManager.getLanguageIds()
  sourceBuffer.setLanguage(lang)

  # set nim scheme
  
  with sourceView:
    enableSnippets = true
    showLineNumbers = true
    monospace = true
    autoIndent = true
    leftMargin = 40
    rightMargin = 2
    hexpand = true
    vexpand = true
    smartBackspace = true
    smartHomeEnd = SmartHomeEndType.always

  result = sourceView



proc getCompletionBtnCb(btn: Button) = 
  echo "sas"

proc createPage*(getCompletitionBtn: Button): Box = 
  let 
    sourceView = createSourceView()
    scrolledWindow = newScrolledWindow()
    sourceViewWithPreviewBox = newBox(Orientation.horizontal, 0)
    # sourceStyleSchemePreview = newSourceStyleSchemePreview()


  with sourceViewWithPreviewBox:
    append scrolledWindow
    # append sourceStyleSchemePreview

  # connects
  getCompletitionBtn.connect("clicked", getCompletionBtnCb)

  scrolledWindow.child = sourceView
  result = sourceViewWithPreviewBox




