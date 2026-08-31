@icon("heart.svg")
extends Node
class_name Health2D

enum PostDeath{RESTART_SCENE,DESTROY_NODE}

## Emitted when damage is taken.
signal _on_take_damage
## Emitted when health is gained.
signal _on_health_gained
## Emitted when health reaches 0.
signal _died
## Emitted when health is changed
signal _on_change(current:float,max:float)

## Who is using the component.
@export var user:Node

## Max Health.
@export var max_health:float
## The percentage of max_health the component starts with. 
@export_range(0.0,100.0) var starting_health_per:float = 100.0
## What happens after death.
@export var post_death_action:PostDeath = PostDeath.DESTROY_NODE
## What to drop when dead, if null it isn't dropping anything
@export var drop_on_death: PackedScene

var health:float = max_health

func _ready() -> void:
	if user == null:
		user = get_parent()
		push_warning('You forgot to place the "user" to the health component (',self,'). Automatically added the parent (',user,'), KOSSAINIS')
	
	if starting_health_per == 100.0:
		return
	health = max_health * starting_health_per

func take_damage(amount:float)->void:
	health -= amount
	
	_on_change.emit(health,max_health)
	_on_take_damage.emit()
	
	if health <= 0:
		death()

func death()->void:
	_died.emit()
	
	if drop_on_death != null:
		var drop := drop_on_death.instantiate()
		drop.global_position = user.global_position
		get_tree().current_scene.call_deferred("add_child", drop)
	
	if post_death_action == PostDeath.DESTROY_NODE:
		# Defer the deletion of the single node
		user.call_deferred("queue_free")
		
	elif post_death_action == PostDeath.RESTART_SCENE:
		# Defer the deletion of the entire scene
		get_tree().call_deferred("reload_current_scene")

func heal(amount:float)->void:
	health += amount
	
	if health > max_health:
		health = max_health
	
	_on_health_gained.emit()
	_on_change.emit(health,max_health)
