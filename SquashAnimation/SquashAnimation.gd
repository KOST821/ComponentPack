@tool
@icon("gobot.svg")
extends Node
class_name SquashAnimation

enum TYPE \
	{
	## The equation has the form of midpoint + amplitude × sin(time).
	SINE,
	## The equation has the form of midpoint + amplitude × cos(time).
	COSINE,
	## The equation has the form of midpoint + amplitude × tan(time), with -1 ≤ tan(time) ≤ 1.
	TANGENT,
		## The equation has the form of midpoint + amplitude × 2.0 × sin(time) × cos(time).
	SINE_AND_COSINE,
	## The equation has the form of midpoint + amplitude × 2.0 × (|sin(time)|)².
	BOUNCE
	}

## The [Node2D] or [Control] Node that will use this component [br] [br]
## If empty the parent will be taken. If parent is [Node2D] or [Control] Node.
@export var user: Node:
	set(value):
		user = value
		update_configuration_warnings()

## How fast the animation is played.
@export var speed: float = 3.0
## If false, the animation stops and resets after the duration is reached.
@export var looping: bool = true
## How long the animation lasts if looping is false.
@export var duration: float = 1.0
## Enables or Disables the Component.
@export var enable: bool = false:
	set(value):
		if Engine.is_editor_hint():
			if value == true:
				if !user:
					push_error('You forgot to place the "user" to the SquashAnimation (',self,'). Automatically aborted enabling, KOSSAINIS')
					return
				
				base_scale = user.scale
				base_rotation = user.rotation
				
				enable = value
			else:
				enable = value
				_reset_transform()
		else:
			enable = value
			if enable:
				_time_passed = 0.0 
			else:
				_reset_transform()
## Enables or Disables the Component in the editor.
@export var editor_disable: bool = true:
	set(value):
		if enable and !value:
			base_rotation = user.rotation
			base_scale = user.scale
		editor_disable = value
		if Engine.is_editor_hint():
			if editor_disable:
				_reset_transform()
		#if Engine.is_editor_hint():
			#if enable == true:
				#if !user:
					#push_error('You forgot to place the "user" to the SquashAnimation (',self,'). Automatically aborted enabling, KOSSAINIS')
					#return
			#else:
				#if !user:
					#print_rich('[color=fff837ff]WARNING: You do not have enable to true!')
					#return
			#
			#if value == true:
				#_reset_transform()
			#
			#editor_disable = value
		#else:
			#editor_disable = value
			#if editor_disable == false:
				#_reset_transform()

@export_group("Deformation Limits")
## Axis X of animation
@export_subgroup("Axis X", "x")
## The lowest point of the squash animation on the X axis.
@export var x_lowest_point: float = 0.9
## The maximum point of the squash animation on the X axis.
@export var x_max_point: float = 1.1
## Type of the equation used to [member user.scale] the X axis, using amplitude and midpoint. [br] [br]
## amplitude = (Max Point - Lowest Point) / 2.0 [br] [br]
## midpoint = (Max Point + Lowest Point) / 2.0
@export var x_type: TYPE = TYPE.SINE

## Axis Y of animation
@export_subgroup("Axis Y", "y")
## The lowest point of the squash animation on the Y axis.
@export var y_lowest_point: float = 0.9
## The maximum point of the squash animation on the Y axis.
@export var y_max_point: float = 1.1
## Type of the equation used to [member user.scale] the Y axis, using amplitude and midpoint. [br] [br]
## amplitude = (Max Point - Lowest Point) / 2.0 [br] [br]
## midpoint = (Max Point + Lowest Point) / 2.0
@export var y_type: TYPE = TYPE.COSINE

@export_group("Rotation Limits")
## The maximum [member user.rotation] (in degrees).
@export var target_tilt_degrees: float = 15.0
## The speed of the rotation.
@export var tilt_speed: float = 10.0
## How fast is the rotation speed.
@export var wobble_frequency: float = 0.5

var _time_passed: float = 0.0
var base_scale: Vector2
var base_rotation:float

func _get_configuration_warnings() -> PackedStringArray:
	if not user:
		return ["SquashAnimation needs to have a user target set to work!"]
	elif not user is Node2D and not user is Control:
		return ["The set user target is neither a Control nor an Node2D!"]
	else:
		return []

func _ready() -> void:
	if not user:
		user = get_parent() as Node
		if user:
			push_warning('You forgot to place the "user" to the SquashAnimation (',self,'). Automatically added the parent (',user,'), KOSSAINIS')
		else:
			push_error("You forgot to place the user to the SquashAnimation (",self,"). Automatically tried to add the parent (",get_parent(),") but it wasn't a Node2D or Control Node, KOSSAINIS")
			return
	
	base_scale = user.scale
	base_rotation = user.rotation

func _process(delta: float) -> void:
	var is_previewing = Engine.is_editor_hint() and editor_disable
	if not enable or is_previewing: return
	
	_time_passed += delta * speed
	
	if not looping and not is_previewing:
		if _time_passed >= duration:
			stop()
			return
	
	# Axis X
	var x_wave: float = get_type(x_type, x_max_point, x_lowest_point, _time_passed)
	user.scale.x = base_scale.x * x_wave
	
	# Axis Y
	var y_wave: float = get_type(y_type, y_max_point, y_lowest_point, _time_passed)
	user.scale.y = base_scale.y * y_wave
	
	# Rotation
	var wobble_wave = sin(_time_passed * wobble_frequency)
	var dynamic_tilt_degrees = target_tilt_degrees * wobble_wave
	var target_rotation_rad: float = deg_to_rad(dynamic_tilt_degrees)
	user.rotation = lerp_angle(user.rotation, base_rotation + target_rotation_rad, tilt_speed * delta)


func get_type(type: TYPE, max_point: float, lowest_point: float, time_pass: float) -> float:
	var amplitude: float = (max_point - lowest_point) / 2.0
	var midpoint: float = (max_point + lowest_point) / 2.0
	
	match type:
		TYPE.SINE:
			return midpoint + amplitude * sin(time_pass)
			
		TYPE.COSINE:
			return midpoint + amplitude * cos(time_pass)
			
		TYPE.TANGENT:
			var clamped_tan = clamp(tan(time_pass), -1.0, 1.0)
			return midpoint + amplitude * clamped_tan
			
		TYPE.SINE_AND_COSINE:
			var combined_amp: float = (max_point - lowest_point)
			return midpoint + combined_amp * sin(time_pass) * cos(time_pass)
		
		TYPE.BOUNCE:
			# abs() forces the wave to stay positive (creating a sharp bounce point)
			# pow(..., 2.0) smooths out the top of the arc, creating "hang time"
			var bounce_wave = pow(abs(sin(time_pass)), 2.0)
			# We map this 0 to 1 wave to your lowest and max points
			return lowest_point + (max_point - lowest_point) * bounce_wave
		
	return midpoint

func _reset_transform() -> void:
	if user:
		user.scale = base_scale
		user.rotation = base_rotation
	_time_passed = 0.0

## Call this from other scripts (like a Player script) to trigger the animation.
func play() -> void:
	enable = true

## Manually stops the animation and resets the transform.
func stop() -> void:
	enable = false
