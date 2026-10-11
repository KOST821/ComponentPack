@tool
@icon("arrow_projectile.svg")
extends Node
## Gives movement and gravity to a Projectile in 3D axis.
class_name ProjectileMovement3D

## Looking from +Z to -Z
enum STARTING_POS \
{
	## The Projectile front is RIGHT.
	RIGHT,
	## The Projectile front is LEFT.
	LEFT,
	## The Projectile front is UP.
	UP,
	## The Projectile front is DOWN.
	DOWN,
	## The Projectile front is FRONT [i](away from you)[/i].
	FRONT,
	## The Projectile front is BACK [i](to you)[/i].
	BACK
}


## Who is using this component.
@export var user: Node3D:
	set(value):
		user = value
		update_configuration_warnings()

## The speed (in m/sec) that the user will have.
@export_custom(PROPERTY_HINT_NONE, "suffix:m/s") var speed: float = 10.0
## The gravity this component has.
@export_range(0.0, 100.0, 0.1, "or_greater", "hide_control", "suffix:m/s²") var gravity: float = 0.0
## If true the front of the Projectile will always match the travel direction.
@export var rotate_based_on_velocity: bool = false
## The facing direction of your sprite.
@export var starting_sprite_position: STARTING_POS = STARTING_POS.RIGHT
## Time in seconds before the projectile is destroyed. 0 means infinite.
@export_range(0.0, 60.0, 0.1, "or_greater", "suffix:s") var lifetime: float = 0.0

var _velocity: Vector3
var _starting_sprite_position_vector: Vector3
var _time_alive: float = 0.0
var _is_frame1:bool = true

func _get_configuration_warnings() -> PackedStringArray:
	if not user or not user is Node3D:
		return ["No valid user set for the ProjectileMovement3D Component!"]
	return []

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if not user:
		user = get_parent() as Node3D
	
	if not user:
		return
	
	_starting_sprite_position_vector = _position(starting_sprite_position)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() or not user:
		return
	
	if _is_frame1:
		var global_forward: Vector3 = user.global_transform.basis * _starting_sprite_position_vector
		_velocity = global_forward.normalized() * speed
		_is_frame1 = false

	if lifetime > 0.0:
		_time_alive += delta
		if _time_alive >= lifetime:
			user.queue_free()
			return

	if gravity > 0.0:
		_velocity.y -= gravity * delta

	user.global_position += _velocity * delta

	if rotate_based_on_velocity and _velocity.length_squared() > 0.01:

		if starting_sprite_position == STARTING_POS.FRONT:
			user.look_at(user.global_position + _velocity, Vector3.UP)
		else:
			var target_basis = Basis.looking_at(_velocity, Vector3.UP)
			var offset_basis = Basis.looking_at(_starting_sprite_position_vector, Vector3.UP).inverse()
			user.global_transform.basis = target_basis * offset_basis

func _position(vector: STARTING_POS) -> Vector3:
	match vector:
		STARTING_POS.RIGHT: return Vector3.RIGHT
		STARTING_POS.LEFT: return Vector3.LEFT
		STARTING_POS.UP: return Vector3.UP
		STARTING_POS.DOWN: return Vector3.DOWN
		STARTING_POS.FRONT: return Vector3.FORWARD
		STARTING_POS.BACK: return Vector3.BACK
	return Vector3.ZERO
