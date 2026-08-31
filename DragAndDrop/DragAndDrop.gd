@icon("chess_pawn.svg")
extends Node
class_name DragDropComponent2D


enum DropBehavior\
 { 
	## Stays exactly where you let go.
	DROP_ANYWHERE,
	## Snaps to a specific area if dropped on it, otherwise stays where you let go.
	SNAP_TO_ZONE,
	## Snaps to a specific area, but rubber-bands back to start if missed.
	RETURN_IF_NO_ZONE
}

## The parent must be a [CollisionObject2D] to receive mouse events. If empty the parent will be placed, assuming the parent is [CollisionObject2D].
@export var user: CollisionObject2D
## Defines how the parent node behaves when the mouse is released.
@export var behavior: DropBehavior = DropBehavior.DROP_ANYWHERE
## The [b]group[/b] that zones will be. If empty the placeholder will be placed.
@export_placeholder("drop_zone") var drop_zone_group: String
## The action name that will be used to start drag. If empty the placeholder will be placed.
@export_placeholder("drag") var input_start_action:String
## The action name that will be used to stop drag. If empty the placeholder will be placed.
@export_placeholder("end_drag") var input_end_action:String

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var start_position: Vector2


func _ready() -> void:
	if not user:
		user = get_parent() as CollisionObject2D
		if user:
			push_warning('You forgot to place the "user" to the DragDropComponent2D (',self,'). Automatically added the parent (',user,'), KOSSAINIS')
		else:
			push_error("You forgot to place the user to the DragDropComponent2D (",self,"). Automatically tried to add the parent (",get_parent(),") but it wasn't a Node2D Node, KOSSAINIS")
		
			set_process(false)
			return
	
	if input_end_action == "":
		input_end_action = "end_drag"
	
	if input_start_action == "":
		input_start_action = "drag"
	
	if drop_zone_group == "":
		drop_zone_group = "drop_zone"
	
	# Force the parent to be pickable just in case you forgot to check the box
	user.input_pickable = true
	user.input_event.connect(_on_parent_input_event)
	set_process(false) # Don't waste CPU cycles processing when not dragging

func _on_parent_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed(input_start_action):
		start_dragging()

func _input(event: InputEvent) -> void:
	# CRITICAL: We catch the release in _input, not _input_event. 
	# If the user drags the mouse very fast, the cursor leaves the object, 
	# and the parent won't register the mouse release.
	if is_dragging and event.is_action_pressed(input_end_action):
		set_process(false)
		_return_to_start()
	if is_dragging and event.is_action_released(input_start_action):
		stop_dragging()

func start_dragging() -> void:
	is_dragging = true
	start_position = user.global_position
	# Calculate offset so the object doesn't snap its center to the cursor instantly
	drag_offset = user.global_position - user.get_global_mouse_position()
	
	# Optional but good UX: bump z-index so it drags OVER other items
	user.z_index += 100 
	set_process(true)

func _process(_delta: float) -> void:
	user.global_position = user.get_global_mouse_position() + drag_offset

func stop_dragging() -> void:
	is_dragging = false
	user.z_index -= 100
	set_process(false)
	
	match behavior:
		DropBehavior.DROP_ANYWHERE:
			pass 
		DropBehavior.SNAP_TO_ZONE:
			_try_snap_to_zone(false)
		DropBehavior.RETURN_IF_NO_ZONE:
			_try_snap_to_zone(true)

func _try_snap_to_zone(return_on_fail: bool) -> void:
	if not user is Area2D:
		push_error("DragDropComponent2D: Snap behavior requires the parent to be an Area2D to detect drop zones.")
		if return_on_fail:
			_return_to_start()
		return
		
	# Check what areas the parent is currently touching
	var overlapping = user.get_overlapping_areas()
	for area in overlapping:
		if area.is_in_group(drop_zone_group):
			# Found a valid drop zone! Snap to its center.
			user.global_position = area.global_position
			return 
			
	# We didn't find a drop zone.
	if return_on_fail:
		_return_to_start()

func _return_to_start() -> void:
	# Never just teleport objects back instantly, it looks terrible. Use a Tween.
	var tween = get_tree().create_tween()
	tween.tween_property(user, "global_position", start_position, 0.2).set_trans(Tween.TRANS_SINE)
