@icon("bot.svg")
extends Node
class_name FiniteStateMachineUB

signal state_changed

## Who is using the component.
@export var user: Node

var current_state: StateUB

func _ready() -> void:
	if user == null:
		user = get_parent()
		push_warning('You forgot to place the "user" to the UserBasedFiniteStateMachine (',self,'). Automatically added the parent (',user,'), KOSSAINIS')

func _process(delta: float) -> void:
	if current_state:
		current_state._update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state._physics_update(delta)


func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.unhandled_input(event)


func change_state(new_state_class: GDScript) -> StateUB:
	if current_state and current_state.get_script() == new_state_class:
		return current_state
	
	if current_state:
		current_state._exit_state()
		current_state = null

	var next = new_state_class.new()
	if not next is StateUB:
		push_error("FSM: Class %s does not extend StateUB." % new_state_class)
		return null
		
	current_state = next
	current_state.user = user
	current_state._enter_state()
	state_changed.emit()

	return current_state
