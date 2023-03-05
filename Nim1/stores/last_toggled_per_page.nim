import tables
import gintro/[gtk4]

var lastToggledPerPageGb* = newTable[int, ToggleButton]()