extends Node
class_name MovableObject


@export var movable_object:CharacterBody2D

@export var speed:float = 30.0

@export var gravity:float = 2000.0

@export var left_raycast:RayCast2D

@export var right_raycast:RayCast2D

@export var group:String

@export var left:StringName

@export var right:StringName

@export var grab:StringName

@export var method:StringName

var grabbed:bool
var pusher:CollisionObject2D

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_push_movement()
	_pull_movement()
	
	movable_object.move_and_slide()

func _apply_gravity(delta:float)->void:
	if not movable_object.is_on_floor():
		movable_object.velocity.y = gravity * delta

func get_collision_normal() -> float:
	if left_raycast: return 1.0
	
	elif right_raycast: return -1.0
	
	else: return 0.0

func _is_interacting() -> bool:
	return left_raycast.is_colliding() or right_raycast.is_colliding()

func _get_collider():
	for raycast:RayCast2D in [left_raycast, right_raycast]:
		if raycast.is_colliding() and raycast.get_collider().is_in_group(group):
			return raycast.get_collider()
		
		return null

func _push_movement() -> void:
	var direction:float = Input.get_axis(left, right)
	
	if direction == get_collision_normal() and direction:
		movable_object.velocity.x = speed * direction
	
	else:
		movable_object.velocity.x = 0.0

func _pull_movement() -> void:
	var direction:float = Input.get_axis(left, right)
	
	if grabbed:
		movable_object.velocity.x = speed * direction

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(grab) and _is_interacting():
		grabbed = true
	
	if event.is_action_released(grab):
		grabbed = false
		pusher.call_deferred(method, false)
		pusher = null

func _set_pusher() -> void:
	pusher = _get_collider()
	
	if not pusher:
		return
	
	if pusher.has_method(method):
		pusher.call_deferred(method, true, speed)
