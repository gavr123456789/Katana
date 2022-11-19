import gintro/[gtk4, gobject, gio, pango, glib, gdk4, gtksource5, adw]
import std/with
import createSourceView
import htsparse/cpp/cpp
import print

proc showAstCb(btn: Button, view: View) = 
  var startIter = TextIter()
  var endIter = TextIter()
  view.TextView.buffer.getBounds(startIter, endIter)
  let text = view.TextView.buffer.getText(startIter, endIter, false)
  echo parseCppString(text).treeRepr()

proc activate(app: gtk4.Application) =

  let
    window = adw.newApplicationWindow(app)
    header = adw.newHeaderBar()

    popover = newPopover()
    menuButton = newMenuButton()

    mainBox = newBox(Orientation.vertical, 0)
    showAstBtn = newButtonFromIconName("preferences-devices-tree-symbolic")
    scrolledWindow = newScrolledWindow()

    buffer = newBuffer()

    sourceView = newViewWithBuffer(buffer)
    # sourceCompletion = sourceView.completion
    sourceBuffer = sourceView.buffer.Buffer


    word_provider = newCompletionWords()
    completion = sourceView.completion

    langManager = newLanguageManager()
    lang = langManager.getLanguage("cpp")

    # style 
    styleSchemeManager = newStyleSchemeManager()
    styleSchemePreview = newStyleSchemeChooserWidget()
  
  sourceBuffer.styleScheme = styleSchemeManager.getScheme("Adwaita")
  # discard sourceBuffer.bindProperty("styleScheme", styleSchemePreview, "styleScheme", {})
  discard sourceBuffer.bindProperty("style_scheme", styleSchemePreview, "style_scheme", {BindingFlag.bidirectional})

  # print langManager.getLanguageIds()
  # print styleSchemeManager.get_scheme_ids()


  sourceBuffer.setLanguage(lang)
  

  # popover with styleChooser
  with menuButton: 
    iconName = "cinnamon-preferences-color-symbolic"
    popover = popover
  with popover: 
    child = styleSchemePreview

  scrolledWindow.child = sourceView
  scrolledWindow.minContentWidth = 600

  word_provider.registerCompletionWords(sourceView.TextView.buffer)
  # word_provider.priority = 2
  completion.addProvider(word_provider)

  with sourceView:
    canFocus = true
    hexpand = true
    vexpand = true 
    monospace = true
    # visible = true
  

  with header:
    packStart showAstBtn
    packStart menuButton

  

  showAstBtn.connect("clicked", showAstCb, sourceView)


  with mainBox:
    append header
    append scrolledWindow
  with window:
    content = mainBox
    title = ""
    defaultSize = (600, 600)
    show

proc main() =
  let app = newApplication("org.gtk.example")
  app.connect("activate", activate)
  discard run(app)

main()