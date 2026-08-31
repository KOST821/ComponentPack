@icon("box.svg")
extends Node
class_name State

@warning_ignore("unused_signal")
signal switch_state(state:State)

@export var states_that_can_change:Dictionary[StringName,State]

var user:CharacterBody2D

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
