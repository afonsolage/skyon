extends Node

var net: NetSystem

var world: WorldSystem setget ,_get_world
var combat: CombatSystem setget ,_get_combat
var input: InputSystem setget, _get_input
var player: PlayerSystem setget, _get_player


func _ready() -> void:
	randomize()
	Log.d("Initializing systems")
	
	_init_net_system()

# System-wide...systems

func _init_net_system() -> void:
	net = NetSystem.new()
	add_child(net)

# Channel-wide systems

func _get_world() -> WorldSystem:
	if not world and has_node("/root/Main/WorldSystem"):
		world = get_node("/root/Main/WorldSystem") as WorldSystem
	
	return world


func _get_combat() -> CombatSystem:
	if not combat and has_node("/root/Main/CombatSystem"):
		combat = get_node("/root/Main/CombatSystem") as CombatSystem
	
	return combat


func _get_input() -> InputSystem:
	if not input and has_node("/root/Main/InputSystem"):
		input = get_node("/root/Main/InputSystem") as InputSystem
	
	return input


func _get_player() -> PlayerSystem:
	if not player and has_node("/root/Main/PlayerSystem"):
		player = get_node("/root/Main/PlayerSystem") as PlayerSystem
	
	return player
