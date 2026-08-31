@icon("swords.svg")
extends Area2D
class_name HitBox2D

@export var damage:float = 10.0

func _ready() -> void:
	monitorable = false
	
	area_entered.connect(_on_damage_dealt)

func _on_damage_dealt(area: Area2D) -> void:
	if area is not HurtBox2D or not area.has_method('take_damage'):
		return
	
	area.take_damage(damage)
