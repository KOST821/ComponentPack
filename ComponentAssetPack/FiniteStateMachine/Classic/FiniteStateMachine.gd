@icon("cog.svg")
extends Node
class_name FiniteStateMachineNB

## Who is using the component.
@export var user:Node
## Starting State.
@export var initial_state:StateNB

var active_state:StateNB

func _ready() -> void:
	if user == null:
		user = get_parent()
		push_warning('You forgot to place the "user" to the FiniteStateMachine (',self,'). Automatically added the parent (',user,'), KOSSAINIS')
	
	for child:StateNB in get_children():
		child.user = user
		child.switch_state.connect(_change_state)
	
	if initial_state:
		_change_state(initial_state)

func _process(delta: float) -> void:
	if active_state:
		active_state._update(delta)

func _physics_process(delta: float) -> void:
	if active_state:
		active_state._physics_update(delta)

func _unhandled_input(event: InputEvent) -> void:
	if active_state:
		active_state.unhandle_input(event)

func _change_state(new_state:StateNB)->void:
	if new_state == active_state:
		return
	
	if active_state:
		active_state._exit_state()
	
	active_state = new_state
	
	if active_state:
		active_state._enter_state()
