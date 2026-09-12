@tool
@icon("arrow_projectile.svg")
extends Node
class_name ProjectileMovement2D

enum STARTING_POS \
{
	## The Projectile front is RIGHT.
	RIGHT,
	## The Projectile front is LEFT.
	LEFT,
	## The Projectile front is UP.
	UP,
	## The Projectile front is DOWN.
	DOWN
}

## Who is using this component.
@export var user: Node:
	set(value):
		user = value
		update_configuration_warnings()

@export var sprite:Node2D:
	set(value):
		sprite = value
		update_configuration_warnings()

## The speed (in px/sec) that the user will have.
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s") var speed: float = 500.0
## The gravity this component has.
@export_range(0.0, 1000.0, 0.1, "or_greater", "hide_control", "suffix:px/s²") var gravity: float = 0.0
## If true the front of the Projectile will always match the travel direction.
@export var rotate_based_on_velocity: bool = false
## The facing direction of your sprite.
@export var starting_sprite_position: STARTING_POS = STARTING_POS.RIGHT
## Time in seconds before the projectile is destroyed. 0 means infinite.
@export_range(0.0, 60.0, 0.1, "or_greater", "hide_control", "suffix:s") var lifetime: float = 0.0 

var _velocity: Vector2
var _starting_sprite_position_vector: Vector2
var _time_alive: float = 0.0

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not user:
		warnings.append("No valid user set for the ProjectileMovement2D Component!")
	
	elif not (user is Control or user is Node2D):
		warnings.append("User is not a valid type. It should be a Control or a Node2D.")
	
	if not sprite or not (sprite is Sprite2D or sprite is AnimatedSprite2D):
		warnings.append("No valid sprite set for the ProjectileMovement2D Component or sprite is not a Sprite2D or AnimatedSprite2D!")
	
	return warnings

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if not user:
		user = get_parent() as Node2D
		if not user:
			user = get_parent() as Control
			if not user:
				return
	
	_starting_sprite_position_vector = _position(starting_sprite_position)
	
	_velocity = Vector2.RIGHT.rotated(user.global_rotation) * speed

	if sprite:
		sprite.rotation -= _starting_sprite_position_vector.angle()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(user) or Engine.is_editor_hint():
		return
		
	if lifetime > 0.0:
		_time_alive += delta
		if _time_alive >= lifetime:
			user.queue_free()
			return

	if gravity > 0:
		_velocity.y += gravity * delta
	user.global_position += _velocity * delta
	
	if rotate_based_on_velocity:
		user.rotation = _velocity.angle()

func _position(vector: STARTING_POS) -> Vector2:
	match vector:
		STARTING_POS.RIGHT: return Vector2.RIGHT
		STARTING_POS.LEFT: return Vector2.LEFT
		STARTING_POS.UP: return Vector2.UP
		STARTING_POS.DOWN: return Vector2.DOWN
	return Vector2.ZERO
