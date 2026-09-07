@icon("rotary_dial.svg")
extends Node
class_name InteractiveUI

## Who uses the component.
@export var user:Control

## The ease type of animation.
@export var ease_type:Tween.EaseType
## The trans type of animation.
@export var trans_type:Tween.TransitionType

## The max rotation the user can rotate in degrees.
@export var max_scale:Vector2 = Vector2.ONE * 1.3
## The min scale the user can reach.
@export var min_rotation:float = 17.0:
	set(value):
		min_rotation = value
		_rad_rotation_min = deg_to_rad(min_rotation)
		
## The max rotation the user can rotate in degrees.
@export var max_rotation:float = 21.0:
	set(value):
		max_rotation = value
		_rad_rotation_max = deg_to_rad(max_rotation)

## The time of the animation.
@export_range(0.0,1.0,0.01,"or_greater") var time:float = 0.29

var _starting_rotation:float
var _starting_scale:Vector2

var _tween:Tween

var _rad_rotation_max:float
var _rad_rotation_min:float

func _ready() -> void:
	if user == null:
		user = get_parent() as Control
		if user == null:
			push_error("You forgot to place the user to the InteractiveUI (",self,"). Automatically tried to add the parent (",get_parent(),") but it wasn't a Control Node, KOSSAINIS")
			return
		push_warning('You forgot to place the "user" to the InteractiveUI (',self,'). Automatically added the parent (',user,'), KOSSAINIS')
	
	user.pivot_offset_ratio = Vector2.ONE / 2.0
	_starting_rotation = user.rotation
	_starting_scale = user.scale
	
	if !user.mouse_entered.is_connected(_on_mouse_entered):
		user.mouse_entered.connect(_on_mouse_entered)
	if !user.mouse_exited.is_connected(_on_mouse_exited):
		user.mouse_exited.connect(_on_mouse_exited)
	
	_rad_rotation_min = deg_to_rad(min_rotation)
	_rad_rotation_max = deg_to_rad(max_rotation)

func _on_mouse_entered() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	
	var ampl:int = [-1,1].pick_random()
	var final_rotation:float = ampl * randf_range(_rad_rotation_min, _rad_rotation_max)
	
	_tween = create_tween().set_ease(ease_type).set_trans(trans_type).set_parallel(true)
	_tween.tween_property(user,"scale", max_scale, time)
	_tween.tween_property(user,"rotation", final_rotation, time)

func _on_mouse_exited() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	
	_tween = create_tween().set_ease(ease_type).set_trans(trans_type).set_parallel(true)
	_tween.tween_property(user,"scale", _starting_scale, time)
	_tween.tween_property(user,"rotation", _starting_rotation, time)
