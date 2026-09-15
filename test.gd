extends Node2D
class_name TEST

signal iii(a,s,d,f)
#@export var res:Keys
#
#func _ready() -> void:
	#res._create()

#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("drag"):
		#print_rich("[i]drag")
	#if event.is_action_pressed("new"):
		#print_rich("[i]new")

var well:int = 1

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		iii.emit('a','b','c','d')
	if event.is_action_pressed("drag"):
		script_changed.emit()
	if event.is_action_pressed("ui_up"):
		well+=1
