@icon("gravity.svg")
extends Node
class_name Gravity

@export var gravity:float = 100.0

func get_gravity(delta:float, current_falling_speed:float = 0.0, descending_gravity_factor:float = 1.0, max_falling_speed:float = 0.0) -> float:
	var gravity_accel:float = current_falling_speed
	
	if gravity_accel > 0.0:
		gravity_accel *= descending_gravity_factor
	
	gravity_accel += delta * gravity
	
	if max_falling_speed == 0.0:
		pass
		
	elif gravity_accel > max_falling_speed:
		gravity_accel = max_falling_speed
	
	return gravity_accel
