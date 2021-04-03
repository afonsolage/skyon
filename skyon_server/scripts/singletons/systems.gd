extends Node

var net : NetSystem
var channel: ChannelSystem

func _ready() -> void:
	Log.d("Initializing Core Systems")
	randomize()
	
	_init_net_system()
	_init_channel_system()

# System-wide...systems

func _init_net_system() -> void:
	net = NetSystem.new()
	net.name = "NetSystem"
	add_child(net)


func _init_channel_system() -> void:
	channel = ChannelSystem.new()
	channel.name = "ChannelSystem"
	add_child(channel)


# Channel-wide functions

func get_current_channel_id(channel_node: Node) -> int:
	var path := channel_node.get_path()
	
	# /root/Systems/ChannelSystem/<ChannelNumber>
	if path.get_name_count() < 4 or not path.get_name(2) == "ChannelSystem":
		Log.d("Invalid channel path: %s" % path)
	
	return int(path.get_name(3))


func get_world(channel_id: int) -> WorldSystem:
	return get_node("ChannelSystem/%d/WorldSystem" % channel_id) as WorldSystem


func get_combat(channel_id: int) -> CombatSystem:
	return get_node("ChannelSystem/%d/CombatSystem" % channel_id) as CombatSystem
