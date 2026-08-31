@icon("lightning_in_clockwise_arrow.svg")
extends Node
class_name InputBuffer

## The name of the jump action. If empty the placeholder will be added.
@export_placeholder("jump") var action_name: String
## The buffer time.
@export var buffer_time: float = 0.15

var _buffer_timer: float = 0.0

func _ready() -> void:
	if action_name == "":
		action_name = "jump"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(action_name):
		_buffer_timer = buffer_time


func _physics_process(delta: float) -> void:
	if _buffer_timer > 0.0:
		_buffer_timer -= delta


func is_buffered() -> bool:
	return _buffer_timer > 0.0


func consume() -> void:
	_buffer_timer = 0.0
