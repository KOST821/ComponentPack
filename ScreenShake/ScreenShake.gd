@tool
@icon("photo_camera.svg")
extends Node
class_name ScreenShake

## Maximum displacement of the camera in pixels (2D) or meters (3D).
@export var max_offset: Vector2 = Vector2(50.0, 50.0)
## Maximum rotation of the camera in degrees (2D only).
@export var max_roll: float = 10.0
## How quickly the shake settles down.
@export var trauma_reduction_rate: float = 0.8
## The noise generator used for the shake.
@export var noise: FastNoiseLite:
	set(value):
		noise = value
		update_configuration_warnings()

##
@export var use_noise:bool = false:
	set(value):
		use_noise = value
		update_configuration_warnings()

## How fast the camera shakes when using noise.
@export var noise_speed: float = 50.0

## Camera that will be screen shaked.
var camera:Node
## Current shake strength.
var _trauma: float = 0.0
## Trauma exponent. Increase for more extreme shaking.
var _trauma_power : int = 2
var _time_passed: float = 0.0

func _get_configuration_warnings() -> PackedStringArray:
	if not noise and use_noise:
		return ["ScreenShake requires a FastNoiseLite resource to function!"]
	return []

func _ready() -> void:
	camera = get_parent()
	if not camera is Camera2D and not camera is Camera3D:
		camera = null
		push_error("ScreenShake must be a child of a Camera2D or Camera3D!")
		return
		
	set_process(not Engine.is_editor_hint())

func add_trauma(amount: float) -> void:
	_trauma = min(_trauma + amount, 1.0)

func _process(delta: float) -> void:
	if _trauma > 0.0:
		_trauma = max(_trauma - trauma_reduction_rate * delta, 0.0)
		_shake(delta)
	elif camera:
		if camera is Camera2D:
			camera.offset = Vector2.ZERO
			camera.rotation = 0.0
		elif camera is Camera3D:
			camera.h_offset = 0.0
			camera.v_offset = 0.0

func _shake(delta: float) -> void:
	var shake_power: float = pow(_trauma, _trauma_power)
	
	if not use_noise:
		if camera is Camera2D:
			camera.rotation_degrees = max_roll * shake_power * randf_range(-1.0, 1.0)
			camera.offset.x = max_offset.x * shake_power * randf_range(-1.0, 1.0)
			camera.offset.y = max_offset.y * shake_power * randf_range(-1.0, 1.0)
		elif camera is Camera3D:
			camera.h_offset = max_offset.x * shake_power * randf_range(-1.0, 1.0)
			camera.v_offset = max_offset.y * shake_power * randf_range(-1.0, 1.0)
	else:
		# CRITICAL: Advance time using delta so shake speed is frame-independent
		_time_passed += delta * noise_speed
		
		if camera is Camera2D:
			var offset_x = max_offset.x * shake_power * noise.get_noise_2d(_time_passed, 0.0)
			var offset_y = max_offset.y * shake_power * noise.get_noise_2d(_time_passed, 1000.0)
			var roll = max_roll * shake_power * noise.get_noise_2d(_time_passed, 2000.0)
			
			camera.offset = Vector2(offset_x, offset_y)
			camera.rotation_degrees = roll
		elif camera is Camera3D:
			var offset_x = max_offset.x * shake_power * noise.get_noise_2d(_time_passed, 0.0)
			var offset_y = max_offset.y * shake_power * noise.get_noise_2d(_time_passed, 1000.0)
			
			camera.h_offset = offset_x
			camera.v_offset = offset_y
