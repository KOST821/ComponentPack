@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_autoload_singleton("DropManager", "res://addons/ComponentAssetPack/DropRate/DropManagerAutoloadScene.tscn")

func _exit_tree() -> void:
	remove_autoload_singleton("DropManager")
