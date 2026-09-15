@tool
@icon("gem.svg")
extends Resource
## A Drop Rate blueprint. You can create from drops off chest to a weighted random number generator.
class_name RateLine

## The overall chance (0% to 100%) that this loot pool drops anything at all.
@export_range(0.0, 100.0, 0.1, "suffix:%") var global_drop_chance: float = 100.0:
	set(value):
		global_drop_chance = value
		emit_changed()

## Format: { Item (Variant): Vector3(X: Weight, Y: Min Amount, Z: Max Amount) }
## Note: Weights (X) across this entire dictionary must total exactly 100%.
@export var drops: Dictionary[Variant, Vector3] = {}:
	set(value):
		drops = value
		emit_changed()
