@icon("heart.svg")
extends Node
class_name Health3D

enum PostDeath{RESTART_SCENE,DESTROY_NODE}

## Emitted when damage is taken.
signal damage_taken
## Emitted when health is gained.
signal health_gained
## Emitted when health reaches 0.
signal died
## Emitted when health is changed
signal health_changed(current:float,max:float)

## Who is using the component.
@export var user:Node3D

## Max Health.
@export var max_health:float = 100.0
## The percentage of max_health the component starts with. 
@export_range(0.0, 100.0, 0.1, "prefer_slider", "suffix:%") var starting_health_per:float = 100.0
## What happens after death.[br]
@export var post_death_action:PostDeath = PostDeath.DESTROY_NODE
## What to drop when dead, if null it isn't dropping anything
@export var drop_on_death: PackedScene
## How far from the ground will it spawn.
@export_range(0.0, 100.0, 0.01, "or_greater", "suffix:m") var distance_above_the_floor:float = 0.5

var health:float = max_health

func _ready() -> void:
	if user == null:
		user = get_parent() as Node3D
		if user == null:
			push_error('You forgot to place the "user" to the health component (',self,'). Automatically tried to add the parent but wasnt valid type, KOSSAINIS')
			return
		push_warning('You forgot to place the "user" to the health component (',self,'). Automatically added the parent (',user,'), KOSSAINIS')
	
	if starting_health_per == 100.0:
		return
	health = max_health * (starting_health_per / 100.0)

## Call it to give damage.
func take_damage(amount:float)->void:
	health -= amount
	
	health_changed.emit(health,max_health)
	damage_taken.emit()
	
	if health <= 0:
		_death()

func _death()->void:
	died.emit()
	
	if drop_on_death != null:
		var drop := drop_on_death.instantiate()
		drop.global_position = user.global_position + Vector3(0.0, distance_above_the_floor, 0.0)
		get_tree().current_scene.call_deferred("add_child", drop)
	
	if post_death_action == PostDeath.DESTROY_NODE:
		# Defer the deletion of the single node
		user.call_deferred("queue_free")
		
	elif post_death_action == PostDeath.RESTART_SCENE:
		# Defer the deletion of the entire scene
		get_tree().call_deferred("reload_current_scene")

## Call it to heal.
func heal(amount:float)->void:
	health += amount
	
	if health > max_health:
		health = max_health
	
	health_gained.emit()
	health_changed.emit(health,max_health)
