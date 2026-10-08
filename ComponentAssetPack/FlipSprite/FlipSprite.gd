@tool
@icon("mirror_xy.svg")
extends Node
class_name FlipSprite2D

enum H_DIRECTION\
{LEFT,## The default face direction of the sprite is [b]LEFT[/b]
## The default face direction of the sprite is [b]RIGHT[/b]
RIGHT}

enum V_DIRECTION\
{UP,## The default face direction of the sprite is [b]UP[/b]
## The default face direction of the sprite is [b]DOWN[/b]
DOWN}

## Flips a [Sprite2D] or an [AnimatedSprite2D] towards the direction of a [Vector2] position.

## The Sprite node that will be flipped.
## [br][br]
## Note: it is defined as a [Node2D] but it needs to be
## either a [Sprite2D] or an [AnimatedSprite2D].
@export var sprite: Node2D:
	set(node_2d):
		sprite = node_2d
		update_configuration_warnings()

## If [code]true[/code], the [member FlipSprite2D.sprite] can be flipped horizontally.
@export var flip_h: bool = true
## If [code]true[/code], the [member FlipSprite2D.sprite] can be flipped vertically.
@export var flip_v: bool = false
## The default Horizontal face direction.[br]
@export var default_h_direction:H_DIRECTION = H_DIRECTION.RIGHT
## The default Vertical face direction.[br]
@export var default_v_direction:V_DIRECTION = V_DIRECTION.DOWN

func _get_configuration_warnings() -> PackedStringArray:
	if not sprite:
		return ["FlipSprite2D needs to have a sprite target set to work!"]
	elif not sprite is Sprite2D and not sprite is AnimatedSprite2D:
		return ["The set sprite target is neither a Sprite2D nor an AnimatedSprite2D!"]
	else:
		return []

## Flips the [member FlipSprite2D.sprite] towards the direction of an [param other_position].
## [br]
## This method should be called by the owner whenever the
## [member FlipSprite2D.sprite] might needs to be flipped.
func flip_sprite_towards(other_position: Vector2) -> void:
	var new_dir: Vector2 = sprite.global_position.direction_to(other_position)
	
	if flip_h and sign(new_dir.x) != 0:
		if default_h_direction == H_DIRECTION.RIGHT:
			sprite.flip_h = sign(new_dir.x) == -1
		else:
			sprite.flip_h = sign(new_dir.x) == 1
			
	if flip_v and sign(new_dir.y) != 0:
		if default_v_direction == V_DIRECTION.DOWN:
			sprite.flip_v = sign(new_dir.y) == -1
		else:
			sprite.flip_v = sign(new_dir.y) == 1
