@icon("chess_pawn.svg")
extends Node
## Adds drag-and-drop functionality to a 2D node. 
class_name DragAndDrop

## Emitted when drag is starting.
signal drag_started
## Emitted when drag is canceled or an invalid drag completed.
signal drag_canceled
## Emitted when drag completed successfully.
signal drag_completed

enum DropBehavior\
 { 
	## Stays exactly where you let go.
	DROP_ANYWHERE,
	## Snaps to a specific zone if dropped on it, otherwise stays where you let go.
	SNAP_TO_ZONE,
	## Snaps to a specific area, but returns back to start if missed.
	RETURN_IF_NO_ZONE
}

## The Node who uses the component, must be a [CollisionObject2D] to receive mouse events. If empty the parent will be placed, assuming the parent is [CollisionObject2D].
@export var user: CollisionObject2D
## The Area2D responsible for detecting drop zones. If empty, assumes the user itself is the Area2D.
@export var drop_sensor: Area2D
## Defines how the parent node behaves when the drag has ended.[br]
@export var behavior: DropBehavior = DropBehavior.DROP_ANYWHERE
## The name of the [b]group[/b] that zones will be. If empty the placeholder will be placed.
@export_placeholder("drop_zone") var drop_zone_group: String
## The action name that will be used to start draging. If empty the placeholder will be placed.
@export_placeholder("drag") var input_start_action:String
## The action name that will be used to cancel draging. If empty the placeholder will be placed.
@export_placeholder("end_drag") var input_end_action:String
## The trans type of the tween animation that will be played when drag is canceled or invalid.
@export var tween_trans:Tween.TransitionType = Tween.TRANS_SINE

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var start_position: Vector2


func _ready() -> void:
	if not user:
		user = get_parent() as CollisionObject2D
		if user:
			push_warning('You forgot to place the "user" to the DragDropComponent2D (',self,'). Automatically added the parent (',user,'), KOSSAINIS')
		else:
			push_error("You forgot to place the user to the DragDropComponent2D (",self,"). Automatically tried to add the parent (",get_parent(),") but it wasn't a CollisionObject2D, KOSSAINIS")
			set_process(false)
			return
	
	if drop_zone_group == "":
		drop_zone_group = "drop_zone"
	
	if input_end_action == "":
		input_end_action = "end_drag"
	
	if input_start_action == "":
		input_start_action = "drag"
	
	# Fallback for the sensor
	if behavior != DropBehavior.DROP_ANYWHERE and not drop_sensor:
		drop_sensor = user as Area2D
		if not drop_sensor:
			push_error("DragDropComponent2D: Snap behaviors require a valid 'drop_sensor' Area2D if the user is a CharacterBody2D.")
	
	user.input_pickable = true
	user.input_event.connect(_on_parent_input_event)
	set_process(false)

func _on_parent_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed(input_start_action):
		start_dragging()

func _input(event: InputEvent) -> void:
	if not is_dragging: return
	
	# Properly route cancel logic through a unified cleanup function
	if event.is_action_pressed(input_end_action):
		_end_drag_sequence(true)
	elif event.is_action_released(input_start_action):
		_end_drag_sequence(false)

func start_dragging() -> void:
	is_dragging = true
	start_position = user.global_position
	drag_offset = user.global_position - user.get_global_mouse_position()
	user.z_index += 100 
	set_process(true)
	drag_started.emit()

func _process(_delta: float) -> void:
	user.global_position = user.get_global_mouse_position() + drag_offset

func _end_drag_sequence(was_canceled: bool) -> void:
	# Clean up state globally first
	is_dragging = false
	user.z_index -= 100
	set_process(false)
	
	if was_canceled:
		_return_to_start()
		return
		
	match behavior:
		DropBehavior.DROP_ANYWHERE:
			drag_completed.emit()
		DropBehavior.SNAP_TO_ZONE:
			_try_snap_to_zone(false)
		DropBehavior.RETURN_IF_NO_ZONE:
			_try_snap_to_zone(true)

func _try_snap_to_zone(return_on_fail: bool) -> void:
	if not drop_sensor:
		if return_on_fail:
			_return_to_start()
		return
		
	var overlapping = drop_sensor.get_overlapping_areas()
	for area in overlapping:
		if area.is_in_group(drop_zone_group):
			user.global_position = area.global_position
			drag_completed.emit()
			return 
			
	if return_on_fail:
		_return_to_start()

func _return_to_start() -> void:
	drag_canceled.emit()
	var tween = get_tree().create_tween()
	tween.tween_property(user, "global_position", start_position, 0.2).set_trans(tween_trans)
