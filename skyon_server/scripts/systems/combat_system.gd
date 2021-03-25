class_name CombatSystem
extends Node

remote func attack() -> void:
	var session_id := self.get_tree().get_rpc_sender_id()
	var player = Systems.world.get_player(session_id)
	var target = player.get_attack_target()
	
	if target:
		var result := _attack_target(player, target)
		
		if not result.empty():
			result.target = target.name
			_broadcast_damage(result)
	else:
		Log.d("No target!")

func _attack_target(attacker_node: Spatial, attacked_node: Spatial) -> Dictionary:
	if not "combat" in attacker_node or not "combat" in attacked_node:
		Log.e("%s can't attack %s" % [attacker_node.name, attacked_node.name])
		return {}
	
	var attacker: CombatComponent = attacker_node.combat
	var attacked: CombatComponent = attacked_node.combat

	return _attack_combat(attacker, attacked)


func _attack_combat(attacker: CombatComponent, attacked: CombatComponent) -> Dictionary:
	var dmg := max(attacker.attack - attacked.defense, 0)
	attacked.health -= dmg
	
	if attacked.health < 0:
		#Trigger death
		pass

	return {
		"dmg" : dmg,
	}


func _broadcast_damage(damage_info: Dictionary) -> void:
	for session_id in Systems.net.get_sessions():
		rpc_id(session_id, "damage_received", damage_info)
