@icon("gravity.svg")
extends Node
class_name Gravity

@export var gravity:float = 100.0

func get_gravity(delta:float, current_falling_speed:float, max_falling_speed:float = 0.0, descending_gravity_factor:float = 1.0) -> float:
	var gravity_accel:float = gravity
	
	if current_falling_speed > 0.0:
		gravity_accel *= descending_gravity_factor
	
	var _gravity:float = (delta * gravity_accel) + current_falling_speed
	
	if _gravity > max_falling_speed and max_falling_speed > 0.0:
		gravity_accel = max_falling_speed
	
	return _gravity
