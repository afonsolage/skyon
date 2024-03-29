extends Node

var net : NetSystem
var channel: ChannelSystem
var atlas: AtlasSystem
var item: ItemSystem
var db: DBSystem

var debug_view: DebugView

func init_systems() -> void:
	Log.d("Initializing Core Systems")
	
	_init_db_system()
	_init_net_system()
	_init_atlas_system()
	_init_channel_system()
	_init_item_system()
	_init_debug_view()

# System-wide...systems

func _init_db_system() -> void:
	db = DBSystem.new()
	db.name = "DBSystem"
	add_child(db)


func _init_net_system() -> void:
	net = NetSystem.new()
	net.name = "NetSystem"
	add_child(net)


func _init_channel_system() -> void:
	channel = ChannelSystem.new()
	channel.name = "ChannelSystem"
	add_child(channel)


func _init_atlas_system() -> void:
	atlas = AtlasSystem.new()
	atlas.name = "AtlasSystem"
	add_child(atlas)


func _init_item_system() -> void:
	item = ItemSystem.new()
	item.name = "ItemSystem"
	add_child(item)


func _init_debug_view() -> void:
	debug_view = preload("res://systems/debug/nodes/debug_view.tscn").instance()
	
	add_child(debug_view)


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


func get_mob(channel_id: int) -> MobSystem:
	return get_node("ChannelSystem/%d/MobSystem" % channel_id) as MobSystem
