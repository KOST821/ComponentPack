extends Node2D

@onready var squash_animation: SquashAnimation = $Area2D/Sprite2D/SquashAnimation

func _on_button_pressed() -> void:
	$CanvasLayer/ColorRect/NoiseTransition.transition_out()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		$CanvasLayer/ColorRect/NoiseTransition.transition_in()

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
