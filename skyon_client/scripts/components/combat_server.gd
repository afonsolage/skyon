class_name CombatServer
extends Node


func _ready():
	pass


func combat_test() -> void:
	rpc_id(1, "combat_test", "Hello!")
	

remote func _combat_test_res(msg: String) -> void:
	Log.d(msg)
