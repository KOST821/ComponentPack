@icon("shield.svg")
extends Area3D
class_name HurtBox3D

signal damage_taken(damage:float)

## Who is traking the health.
@export var health_counter:Node
## The name of the method that reduces the health. If empty it keeps the placeholder.
@export_placeholder("take_damage") var method:String

func _ready() -> void:
	if method == "":
		method = "take_damage"
		push_warning('You forgot to place the "method" to the HurtBox3D (',self,'). Automatically added the placeholder (',method,'), KOSSAINIS')
	
	monitoring = false

func take_damage(damage:float)->void:
	if !health_counter:
		push_warning('You forgot to place the "health_counter" to the HurtBox3D (',self,'), KOSSAINIS')
		return
	
	damage_taken.emit(damage)
	
	health_counter.call_deferred(method, damage)
