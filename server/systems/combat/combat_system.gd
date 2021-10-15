class_name CombatSystem
extends Node

signal died(killed, killer)

var _channel_id: int

func _ready() -> void:
	_channel_id = Systems.get_current_channel_id(self)

func attack(attacker: Spatial, attacked: Spatial) -> Dictionary:
	var result := _attack_target(attacker, attacked)
		
	if not result.empty():
		result.attacked = attacked.name
		result.attacker = attacker.name
		_broadcast_damage(result)
	
	return result


func _attack_target(attacker_node: Spatial, attacked_node: Spatial) -> Dictionary:
	if not "combat" in attacker_node or not "combat" in attacked_node:
		Log.e("%s can't attack %s" % [attacker_node.name, attacked_node.name])
		return {}
	
	var attacker: CombatComponent = attacker_node.combat
	var attacked: CombatComponent = attacked_node.combat

	var result := _attack_combat(attacker, attacked)

	if not result.empty() and attacked.health <= 0:
		self.emit_signal("died", attacked_node, attacker_node)

	return result


func _attack_combat(attacker: CombatComponent, attacked: CombatComponent) -> Dictionary:
	if not attacker.is_alive() or not attacked.is_alive():
		return {}
	
	var dmg := max(attacker.attack - attacked.defense, 0)
	var randomness = rand_range(-2.0, 2.0)
	dmg += randomness
	dmg = int(dmg)
	
	attacker.last_attack = OS.get_ticks_msec()
	attacked.health -= int(dmg)
	
	if attacked.health < 0:
		attacked.health = 0

	return {
		"dmg": dmg,
	}


func _broadcast_damage(damage_info: Dictionary) -> void:
	# TODO: Get sessions only on the current channel
	for session_id in Systems.net.get_sessions():
		rpc_id(session_id, "__damage_received", damage_info)


func is_attack_ready(node: Spatial) -> bool:
	return node.combat.is_attack_ready()


remote func __attack() -> void:
	var session_id := self.get_tree().get_rpc_sender_id()
	var player = Systems.get_world(_channel_id).get_player(session_id)
	var target = null
	
	for body in player.get_interaction_area_bodies():
		if body.is_in_group("Enemy"):
			target = body
	
	if target:
		var _res = attack(player, target)
	else:
		Log.d("No target!")
