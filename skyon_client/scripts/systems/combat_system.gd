class_name CombatSystem
extends Node

signal damage_received(dmg_info)

onready var _dmg_text_res = preload("res://scenes/components/FloatingText.tscn")
onready var _floating_damages = $FloatingDamages

func _on_InputSystem_attack_pressed():
	var main_player: MainPlayer = Systems.world.main_player
	
	if main_player.is_busy:
		return
	
	for body in main_player.get_interaction_area_bodies():
		if body.is_in_group("Enemy"):
			main_player.start_attack_animation()
			rpc_id(1, "__attack")


remote func __damage_received(dmg_info: Dictionary) -> void:
	var attacked = Systems.world.get_spatial(dmg_info.attacked)
	var _attacker = Systems.world.get_spatial(dmg_info.attacker)
	
	if not attacked:
		return
	
	attacked.combat.health -= dmg_info.dmg
	attacked.combat.emit_health_changed()
	
	var dmg_text := _dmg_text_res.instance() as FloatingText
	dmg_text.follow_ref = weakref(attacked)
	dmg_text.text = str(dmg_info.dmg)
	
	_floating_damages.add_child(dmg_text)
	
	if attacked.combat.health <= 0:
		attacked.combat.health = 0
	
	self.emit_signal("damage_received", dmg_info)
