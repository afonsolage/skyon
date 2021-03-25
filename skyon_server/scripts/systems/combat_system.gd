class_name CombatSystem
extends Node

signal died(killed, killer)


func _attack_target(attacker_node: Spatial, attacked_node: Spatial) -> Dictionary:
	if not "combat" in attacker_node or not "combat" in attacked_node:
		Log.e("%s can't attack %s" % [attacker_node.name, attacked_node.name])
		return {}
	
	var attacker: CombatComponent = attacker_node.combat
	var attacked: CombatComponent = attacked_node.combat

	var result := _attack_combat(attacker, attacked)

	if attacked.health <= 0:
		self.emit_signal("died", attacked_node, attacker_node)

	return result


func _attack_combat(attacker: CombatComponent, attacked: CombatComponent) -> Dictionary:
	var dmg := max(attacker.attack - attacked.defense, 0)
	attacked.health -= int(dmg)
	
	if attacked.health < 0:
		attacked.health = 0

	return {
		"dmg": dmg,
	}


func _broadcast_damage(damage_info: Dictionary) -> void:
	for session_id in Systems.net.get_sessions():
		rpc_id(session_id, "__damage_received", damage_info)


remote func __attack() -> void:
	var session_id := self.get_tree().get_rpc_sender_id()
	var player = Systems.world.get_player(session_id)
	var target = null
	
	for body in player.get_interaction_area_bodies():
		if body.is_in_group("Enemy"):
			target = body
	
	if target:
		var result := _attack_target(player, target)
		
		if not result.empty():
			result.attacked = target.name
			result.attacker = player.name
			_broadcast_damage(result)
	else:
		Log.d("No target!")
