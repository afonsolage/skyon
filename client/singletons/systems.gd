extends Node

var net: NetSystem
var channel: ChannelSystem

var world: WorldSystem
var combat: CombatSystem
var input: InputSystem
var player: PlayerSystem
var ui: UISystem

func init_systems() -> void:
	Log.d("Initializing systems")
	
	_init_net_system()
	_init_channel_system()

func update_channel_systems(channel_instance: ChannelInstance) -> void:
	if not channel_instance:
		world = null
		combat = null
		input = null
		player = null
	else:
		world = channel_instance.world
		combat = channel_instance.combat
		input = channel_instance.input
		player = channel_instance.player
		ui = channel_instance.ui
	

# System-wide...systems

func _init_net_system() -> void:
	net = NetSystem.new()
	net.name = "NetSystem"
	self.add_child(net)


func _init_channel_system() -> void:
	channel = ChannelSystem.new()
	channel.name = "ChannelSystem"
	self.add_child(channel)


