import gintro/[gtk4, gobject, gio, pango, adw, glib, gdk4, gtksource5]
import std/with


proc createWordCompletion*(sourceView: gtksource5.View, completion: Completion) = 
  let 
    word_provider = newCompletionWords()
  
  word_provider.registerCompletionWords(sourceView.buffer)
  completion.addProvider(word_provider)
  # word_provider.priority = 10

