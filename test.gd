extends Node3D
class_name TEST

@export var scene:PackedScene
var has_grav:bool = false
var is_on:bool = false

func _on_button_pressed(on:bool) -> void:
	if on :
		has_grav = true
	else:
		has_grav = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		_on_button_pressed(!is_on)
	if event.is_action_pressed("ui_accept"):
		if has_grav:
			var n:= scene.instantiate()
			n.get_child(0).gravity = 10
			n.get_child(0).rotate_based_on_velocity = true
			add_child(n)
			n.global_position = $Marker2D/Marker2D.global_position
			n.global_rotation = $Marker2D/Marker2D.global_rotation
		else:
			var n:= scene.instantiate()
			add_child(n)
			n.global_position = $Marker2D/Marker2D.global_position
			n.global_rotation = $Marker2D/Marker2D.global_rotation

func _process(_delta: float) -> void:
	$Marker2D.rotation.z += _delta
	
