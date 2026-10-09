@tool
@icon("file_plus.svg")
extends Node
class_name SceneSpawner

## The scene that will be spawned.
@export var scene: PackedScene:
	set(new_scene):
		scene = new_scene
		update_configuration_warnings()

## If true the new Node will be spawned independently from the other Nodes.
@export var spawn_top_level: bool = false
## If true the new Node will have the transform of the parent Node.
@export var match_transform_top_level: bool = false


func _get_configuration_warnings() -> PackedStringArray:
	if not scene or not scene is PackedScene:
		return ["No valid scene assigned to the SceneSpawner!"]
	else:
		return []

## Gets an instance of the Node that will be spawned. That way you may run code before instantiation.
func instantiate() -> Node:
	if not scene:
		return null
		
	return scene.instantiate()

## Spawns the node.
func spawn(parent: Node = get_parent()) -> Node:
	var new_node:Node= instantiate()
	var spawn_source:Node = parent
	
	if spawn_top_level:
		parent = get_tree().current_scene
	
	if new_node is Node3D:
		parent.add_child(new_node)
	else:
		parent.call_deferred("add_child",new_node)
	
	if match_transform_top_level and spawn_top_level:
		if spawn_source is Node3D and new_node is Node3D:
			new_node.global_transform = spawn_source.global_transform
			
			print('3D ',spawn_source.global_transform)
		else:
			if "global_position" in spawn_source and "global_position" in new_node:
				new_node.global_position = spawn_source.global_position
			if "global_rotation" in spawn_source and "global_rotation" in new_node:
				new_node.global_rotation = spawn_source.global_rotation
	
	return new_node
