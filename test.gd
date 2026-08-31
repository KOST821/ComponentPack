extends Node2D

@onready var squash_animation: SquashAnimation = $Area2D/Sprite2D/SquashAnimation

func _on_button_pressed() -> void:
	squash_animation.enable = !squash_animation.enable


func _on_h_slider_value_changed(value: float) -> void:
	$CanvasLayer/HBoxContainer/Label2.text = "max: " + str(value)
	squash_animation.x_max_point = value


func _on_h_slider_2_value_changed(value: float) -> void:
	$CanvasLayer/HBoxContainer/Label.text = "min: " + str(value)
	squash_animation.x_lowest_point = value


func _on_h_slider_3_value_changed(value: float) -> void:
	$CanvasLayer/HBoxContainer/Label3.text = "max: " + str(value)
	squash_animation.y_max_point = value


func _on_h_slider_4_value_changed(value: float) -> void:
	$CanvasLayer/HBoxContainer/Label.text = "min: " + str(value)
	squash_animation.y_lowest_point = value
