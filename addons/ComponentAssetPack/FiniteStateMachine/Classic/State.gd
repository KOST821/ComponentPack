@icon("box.svg")
extends Node
class_name StateNB

@warning_ignore("unused_signal")
signal switch_state(state:StateNB)

## An [Array] that has a title and a state to be connected to. [i]Use it to switch states[/i].
@export var states_that_can_change:Dictionary[StringName,StateNB]

var user:Node

func _enter_state()->void:
	pass

func _exit_state()->void:
	pass

func _update(_delta:float)->void:
	pass

func _physics_update(_delta: float) -> void:
	pass

func _transition()->void:
	pass

func unhandle_input(_event:InputEvent)->void:
	pass
