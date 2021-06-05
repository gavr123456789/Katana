import gintro/[adw, gtk4, gobject, gio]
import std/with

type 
  RowWidget = ref object of adw.ExpanderRow