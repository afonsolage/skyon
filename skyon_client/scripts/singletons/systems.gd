extends Node

signal on_channel_data_downloaded

var net: NetSystem
var channel: ChannelSystem

var world: WorldSystem
var combat: CombatSystem
var input: InputSystem
var player: PlayerSystem

func _ready() -> void:
	randomize()
	Log.d("Initializing systems")
	
	_init_net_system()
	_init_channel_system()


# System-wide...systems

func _init_net_system() -> void:
	net = NetSystem.new()
	net.name = "NetSystem"
	self.add_child(net)


func _init_channel_system() -> void:
	channel = ChannelSystem.new()
	channel.name = "ChannelSystem"
	self.add_child(channel)


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
