@icon("OneTimeAnimationIcon.svg")
extends AnimatedSprite2D
## An [AnimatedSprite2D] that will be removed if an animation is complete.
class_name OneTimeAnimatedSprite2D

## Which [Node] to be deleted. If empty it will delete itself.
@export var node_to_delete: Node = self


func _ready() -> void:
	animation_finished.connect\
	(
		node_to_delete.queue_free,
		CONNECT_ONE_SHOT
	)
