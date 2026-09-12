@icon("sign_post.svg")
extends Node
class_name SceneTransition

## Emitted the exact moment the transition animation starts.
signal transition_started
## Emitted the exact moment the transition animation completes.
signal transition_finished

## The [Control] Node that will play the transition, usally a full rect [ColorRect].
@export var target:Control

## The total duration of the transition animation in seconds.
@export var transition_time: float = 1.5

## The ease type of animation.
@export var ease_type: Tween.EaseType = Tween.EASE_IN
## The trans type of animation.
@export var trans_type: Tween.TransitionType = Tween.TRANS_LINEAR

## The [ShaderMaterial] which has the style of the transition you want!
@export var material:ShaderMaterial = null

func _ready() -> void:
	if target == null:
		target = get_parent() as Control
	
		if target:
			push_warning('You forgot to place the "target" to the SceneTransition (',self,'). Automatically added the parent (',target,'), KOSSAINIS')
		else:
			push_error("SceneTransition's parent must be a Control.")
			return
		

## Hides the current scene by spreading the transition over the screen.
func transition_out() -> void:
	_animate_transition(0.0, 1.1)

## Reveals the new scene by clearing the transition off the screen.
func transition_in() -> void:
	_animate_transition(1.1, 0.0)

func _animate_transition(start_val: float, end_val: float) -> void:
	if material: # Add the matireial to the target
		target.material = material
		
	var mat: ShaderMaterial = target.material as ShaderMaterial
	if mat == null:
		push_error("SceneTransition component is missing a ShaderMaterial.")
		return
		
	# CRITICAL: Snap the shader to the starting value instantly.
	# If you don't do this, the first frame might show the old threshold and flicker.
	mat.set_shader_parameter("progress", start_val)
	
	var tween = create_tween().set_ease(ease_type).set_trans(trans_type)
	
	transition_started.emit()
	
	tween.tween_property(mat, "shader_parameter/progress", end_val, transition_time)
	
	# Connect the tween's built-in finished signal to our custom component signal
	tween.finished.connect(func(): transition_finished.emit())
