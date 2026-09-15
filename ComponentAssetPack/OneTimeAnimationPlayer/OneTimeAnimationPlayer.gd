@icon("book_open.svg")
extends AnimationPlayer
## An [AnimationPlayer] that will be removed if an animation is complete.
class_name OneTimeAnimationPlayer

## Which [Node] to be deleted. If empty it will delete itself.
@export var node_to_delete: Node = self


func _ready() -> void:
	animation_finished.connect\
	(
		node_to_delete.queue_free.unbind(1), 
		CONNECT_ONE_SHOT
	)
