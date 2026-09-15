@tool
@icon("bug.svg")
extends Node
## Attach this to a [Node] to debug it without writing any [b]prints[/b]!
class_name Debug

enum DisplayMode\
{
	## The Debug can only appear in the [member Debug.label] and in the Output.
	CONSOLE_ONLY,
	## The Debug will be created above the debugging entity.
	FLOATING_TEXT,
	## The Debug will be created and able to move.
	DRAGGABLE_UI
}


@export_category("Data")
## If [b]true[/b], the Debug is [b][color=RED]enabled[/color][/b].
@export var is_enabled: bool = true
## The Node that will be debugged.
@export var target: Node
## The first thing the Debug will write.
@export_placeholder("[DEBUG]") var debug_indicator: String = "[DEBUG]"
## If [b]true[/b], the Debug will print the time when it happened.
@export var timestamped: bool = true
## Drop a ColorPalette resource here to auto-theme the debug text, the Colors outside of the Palette are [b][color=RED]overitten[/color][/b]. 
## Element 0 = Time, Element 1 = Signal, Element 2 = Property.
@export var theme_palette: DebugPalette

## The color of the [member Debug.timestamped].
@export_color_no_alpha var time_debug_color: Color = Color.HOT_PINK:
	set(value):
		time_debug_color = value
		_time_debug_color = value.to_html(false)

var _time_debug_color: String = "ff69b4"



@export_category("Visuals")
## How the debug information should be displayed in-game.
@export var display_mode: DisplayMode = DisplayMode.CONSOLE_ONLY
## If a [RichTextLabel] is placed, the debug will ALSO be written in that label.
@export var label: RichTextLabel

@export_group("In-Game HUD (Floating)")
## How many recent debug messages to show floating above the node.
@export_custom(PROPERTY_HINT_NONE, "suffix:lines") var floating_history_lines: int = 3
## Offset for the floating text (Y is usually negative to go UP in 2D, positive in 3D).
@export var floating_offset: Vector2 = Vector2(0, -50)
## A factor that will divide the Y floating offset when the label size is created.
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var divided_number:float = 50.0

var _floating_node: Node = null
var _floating_history: Array[String] = []

@export_group("Draggable UI")
## How many recent debug messages to keep in the panel.
@export_custom(PROPERTY_HINT_NONE, "suffix:lines") var draggable_history_lines: int = 5
## Starting position of the draggable panel on your screen.
@export var draggable_offset: Vector2 = Vector2(50, 50)
## The least size your Debug can take.
@export var draggable_minimum_size:Vector2 = Vector2(400, 200)

var _draggable_panel: Panel = null
var _draggable_rtl: RichTextLabel = null
var _draggable_history: Array[String] = []
var _is_dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO



@export_category("Signals")
## Signals you want to ignore. Those will not appear in the Debug.
@export var ignored_signals: Array[StringName] = [&"ready", &"draw"]
## If [b]true[/b], the Debug will track only the [Script] Signals
@export var only_script_signals: bool = false
## If [b]true[/b], the Debug will ignore the variables that are passed through this signal.
@export var only_name:bool = true
## The color of the [member Debug.debug_indicator] when Debug is writing about signals.
@export_color_no_alpha var signal_debug_color: Color = Color.RED:
	set(value):
		signal_debug_color = value
		_signal_color_hex = value.to_html(false)

var _signal_color_hex: String = "ff0000"



@export_category("Properties")
## Type the exact names of the variables on the target node you want to track.
@export var properties_to_watch: Array[StringName] = []
var _previous_values: Dictionary = {}

## The color of the [member Debug.debug_indicator] when Debug is writing about Properties.
@export_color_no_alpha var property_debug_color: Color = Color.CYAN:
	set(value):
		property_debug_color = value
		_property_color_hex = value.to_html(false)

var _property_color_hex: String = "00ffff"


func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	if target == null:
		target = get_parent()
		
	if target == null:
		push_error("Debug node has no target and no parent.")
		return
		
	if debug_indicator.is_empty():
		debug_indicator = "[DEBUG]"
	
	if label:
		label.bbcode_enabled = true
		label.text = ''
		label.scroll_following = true
	
	if theme_palette:
		_enforce_and_apply_palette()
	
	# Initialize hex strings safely on load
	_signal_color_hex = signal_debug_color.to_html(false)
	_property_color_hex = property_debug_color.to_html(false)
	_time_debug_color = time_debug_color.to_html(false)
	
	for prop in properties_to_watch:
		_previous_values[prop] = target.get(prop)
	
	connect_signals()
	
	if not target.is_node_ready():
		await target.ready
	_setup_ui()

func _setup_ui() -> void:
	if not is_enabled:
		return
	
	match display_mode:
		DisplayMode.FLOATING_TEXT:
			if target is Node2D:
				var lbl = Label.new()
				lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				lbl.top_level = true 
				target.add_child(lbl)
				_floating_node = lbl
			elif target is Node3D:
				var lbl_3d = Label3D.new()
				lbl_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED 
				lbl_3d.top_level = true
				target.add_child(lbl_3d)
				_floating_node = lbl_3d
			else:
				push_warning("Debug target is neither Node2D nor Node3D. Floating text disabled.")
				
		DisplayMode.DRAGGABLE_UI:
			var canvas = CanvasLayer.new()
			canvas.layer = 128
			
			_draggable_panel = Panel.new()
			_draggable_panel.position = draggable_offset
			_draggable_panel.custom_minimum_size = draggable_minimum_size
			_draggable_panel.mouse_filter = Control.MOUSE_FILTER_STOP
			_draggable_panel.gui_input.connect(_on_panel_gui_input)
			
			_draggable_rtl = RichTextLabel.new()
			_draggable_rtl.bbcode_enabled = true
			_draggable_rtl.scroll_following = true
			_draggable_rtl.set_anchors_preset(Control.PRESET_FULL_RECT)
			_draggable_rtl.mouse_filter = Control.MOUSE_FILTER_PASS
			
			_draggable_panel.add_child(_draggable_rtl)
			canvas.add_child(_draggable_panel)
			target.add_child(canvas)

func connect_signals() -> void:
	var signals_info: Array[Dictionary] = target.get_signal_list()
	
	if only_script_signals and target.get_script() != null:
		signals_info = target.get_script().get_script_signal_list()
	
	for sig_info in signals_info:
		var sig_name: StringName = sig_info["name"]
		
		if sig_name in ignored_signals:
			continue
		
		var arg_count: int = sig_info["args"].size()
		var callable: Callable
		
		if only_name:
			
			callable = _on_any_signal_emitted.bind(sig_name)
			if arg_count > 0:
				callable = callable.unbind(arg_count)
		
		else:
			# Capture payloads into an array dynamically using lambdas
			match arg_count:
				0: callable = func(): _on_any_signal_emitted_with_name(sig_name, [])
				1: callable = func(a): _on_any_signal_emitted_with_name(sig_name, [a])
				2: callable = func(a, b): _on_any_signal_emitted_with_name(sig_name, [a, b])
				3: callable = func(a, b, c): _on_any_signal_emitted_with_name(sig_name, [a, b, c])
				4: callable = func(a, b, c, d): _on_any_signal_emitted_with_name(sig_name, [a, b, c, d])
				5: callable = func(a, b, c, d, e): _on_any_signal_emitted_with_name(sig_name, [a, b, c, d, e])
				_:
					# Fallback for signals with 6+ arguments (rare)
					push_warning("Debug: Signal '%s' has too many arguments. Dropping payload." % sig_name)
					callable = (func(): _on_any_signal_emitted_with_name(sig_name, [])).unbind(arg_count)
			
		if not target.is_connected(sig_name, callable):
			target.connect(sig_name, callable)

func _process(_delta: float) -> void:
	if not is_enabled or Engine.is_editor_hint():
		return
		
	if is_instance_valid(target):
		if _floating_node is Label and target is Node2D:
			_floating_node.global_position = target.global_position + floating_offset
		elif _floating_node is Label3D and target is Node3D:
			_floating_node.global_position = target.global_position + Vector3(floating_offset.x, floating_offset.y / divided_number, 0)
	
	if properties_to_watch.is_empty():
		return
		
	for prop in properties_to_watch:
		var current_value: Variant = target.get(prop)
		
		if not _previous_values.has(prop):
			continue
			
		var prev_value: Variant = _previous_values.get(prop)
		
		if current_value != prev_value:
			_on_property_changed(prop, prev_value, current_value)
			_previous_values[prop] = current_value

func _on_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_is_dragging = true
			_drag_offset = get_viewport().get_mouse_position() - _draggable_panel.global_position
		else:
			_is_dragging = false
			
	elif event is InputEventMouseMotion and _is_dragging:
		_draggable_panel.global_position = get_viewport().get_mouse_position() - _drag_offset

func _on_any_signal_emitted(sig_name: StringName) -> void:
	if not is_enabled:
		return
	
	var content: String = "Name: %s" % sig_name
	var bbcode: String = _build_log_string(_signal_color_hex, content)
	var plain: String = "SIG: %s" % sig_name 
	
	_log_message(bbcode, plain)

func _on_any_signal_emitted_with_name(sig_name: StringName, args: Array) -> void:
	if not is_enabled:
		return
	
	var content: String = "Name: %s" % sig_name
	if args.size() > 0:
		content += " | Args: %s" % str(args)
		
	var bbcode: String = _build_log_string(_signal_color_hex, content)
	var plain: String = "SIG: %s" % sig_name 
	if args.size() > 0:
		plain += " %s" % str(args)
	
	_log_message(bbcode, plain)

func _on_property_changed(prop_name: StringName, old_val: Variant, new_val: Variant) -> void:
	var content: String = "Property [b]%s[/b] changed: %s -> %s" % [prop_name, str(old_val), str(new_val)]
	var bbcode: String = _build_log_string(_property_color_hex, content)
	var plain: String = "%s: %s -> %s" % [prop_name, str(old_val), str(new_val)]
	
	_log_message(bbcode, plain)
	
func _build_log_string(hex_color: String, content: String) -> String:
	var time_str: String = ""
	if timestamped:
		time_str = "[color=#%s][%s][/color] " % [_time_debug_color, Time.get_time_string_from_system()]
		
	return "[color=#%s]%s[/color] %s [i]from %s[/i] | %s" %\
	[
		hex_color,
		debug_indicator,
		time_str,
		target.name,
		content
	]

func _log_message(bbcode_text: String, plain_text: String) -> void:
	# Always print to console or targeted label if they exist
	print_rich(bbcode_text)
	if label:
		label.append_text(bbcode_text + "\n")

	# Update specific UI modes
	match display_mode:
		DisplayMode.DRAGGABLE_UI:
			if _draggable_rtl:
				_update_draggable_display(bbcode_text)
		DisplayMode.FLOATING_TEXT:
			if _floating_node:
				_update_floating_display(plain_text)

func _update_floating_display(new_text: String) -> void:
	_floating_history.append(new_text)
	if _floating_history.size() > floating_history_lines:
		_floating_history.pop_front()
		
	var combined_text: String = "\n".join(_floating_history)
	
	if _floating_node is Label:
		_floating_node.text = combined_text
	elif _floating_node is Label3D:
		_floating_node.text = combined_text

func _update_draggable_display(new_bbcode: String) -> void:
	_draggable_history.append(new_bbcode)
	if _draggable_history.size() > draggable_history_lines:
		_draggable_history.pop_front()
		
	_draggable_rtl.text = "\n".join(_draggable_history)

func _enforce_and_apply_palette() -> void:
	if theme_palette == null:
		return
	
	time_debug_color = theme_palette.time_debug_color
	signal_debug_color = theme_palette.signal_debug_color
	property_debug_color = theme_palette.property_debug_color
