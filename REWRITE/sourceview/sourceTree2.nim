import gintro/[gtk4, gobject, gio, pango, glib, gdk4, gtksource5]
import std/with
import createSourceView



proc activate(app: gtk4.Application) =

  let
    window = gtk4.newApplicationWindow(app)
    mainBox = newBox(Orientation.vertical, 0)
    scrolledWindow = newScrolledWindow()

    sourceView = newView()
    word_provider = newCompletionWords()
    completion = sourceView.completion

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

  mainBox.append scrolledWindow
  with window:
    child = mainBox
    title = ""
    defaultSize = (600, 600)
    show

proc main() =
  let app = newApplication("org.gtk.example")
  app.connect("activate", activate)
  discard run(app)

main()