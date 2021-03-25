class_name CombatSystem
extends Node

signal damage_received(dmg_info)

func attack() -> void:
	rpc_id(1, "attack")


remote func damage_received(dmg_info: Dictionary) -> void:
	var target = Systems.world.get_spatial(dmg_info.target)
	
	target.apply_damage(dmg_info.dmg)
	
	self.emit_signal("damage_received", dmg_info)
