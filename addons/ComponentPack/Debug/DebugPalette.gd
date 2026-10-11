@icon("palette.svg")
extends Resource
## A [Resource] that contains 3 Colors.
class_name DebugPalette

## The debug color of the time.
@export_color_no_alpha var time_debug_color:Color = Color("000000ff")
## The debug color of signals.
@export_color_no_alpha var signal_debug_color:Color = Color("000000ff")
## The debug color of properties.
@export_color_no_alpha var property_debug_color:Color = Color("000000ff")
