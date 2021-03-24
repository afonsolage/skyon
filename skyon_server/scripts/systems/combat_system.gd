class_name CombatSystem
extends Node

remote func attack() -> void:
	var session_id := self.get_tree().get_rpc_sender_id()
	Systems.world.get_player(session_id)
	
