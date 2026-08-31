extends RefCounted
class_name UserBasedState

var user: Node


func enter() -> void:
	pass


func exit() -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func unhandled_input(_event: InputEvent) -> void:
	pass
