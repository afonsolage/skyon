class_name NPCSystem
extends Node


func interact(name: String) -> void:
	rpc_id(1, "interact", name)


func _on_InputSystem_selected_target(target: Node, _follow) -> void:
	if not target.name.left(1) == "N":
		return
	
	interact(target.name)
