class_name NodeSystem
extends Node

static func is_on_world() -> bool:
	var root := _get_root()
	return root.has_node("/root/Main")


static func _get_root() -> Viewport:
	var scene_tree := Engine.get_main_loop() as SceneTree
	return scene_tree.root


static func _get_system_name() -> String:
	return ""
