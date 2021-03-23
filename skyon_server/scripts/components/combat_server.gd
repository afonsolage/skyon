class_name CombatServer
extends Node


func _ready():
	pass


remote func combat_test(msg: String) -> void:
	var session_id := get_tree().get_rpc_sender_id()
	rpc_id(session_id, "_combat_test_res", msg)
	
