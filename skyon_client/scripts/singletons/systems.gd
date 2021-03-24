extends Node

var world : WorldSystem setget ,_get_world
var net : NetSystem setget ,_get_net
var combat : CombatSystem setget ,_get_combat


func _get_world() -> WorldSystem:
	if not world:
		world = get_node("/root/Main/WorldSystem") as WorldSystem
	
	return world


func _get_net() -> NetSystem:
	if not net:
		net = get_node("/root/Main/NetSystem") as NetSystem
	
	return net


func _get_combat() -> CombatSystem:
	if not combat:
		combat = get_node("/root/Main/CombatSystem") as CombatSystem
	
	return combat
