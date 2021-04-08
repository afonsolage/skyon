class_name ChannelSystem
extends Node

var channel_id: int = -1

onready var _channel_instance_res := preload("res://scenes/channel_instance.tscn")
onready var _loading_res := preload("res://scenes/loading.tscn")

func download_channel_data() -> void:
	rpc_id(1, "__get_channel_data", channel_id)


func _on_loading_ended(loaded_assets: Dictionary) -> void:
	_load_world(loaded_assets)


func _load_world(loaded_assets: Dictionary) -> void:
	channel_id = loaded_assets.map_index
	
	var channel_instance = _channel_instance_res.instance() as ChannelInstance
	channel_instance.name = str(channel_id)
	
	self.add_child(channel_instance)
	
	channel_instance.world.set_map_instance(loaded_assets.map_instance)
	
	Systems.update_channel_systems(channel_instance)


remote func __wait_for_join_channel() -> void:
	Log.d("Waiting for channel to be ready")
	
	if get_child_count() > 0:
		for i in get_child_count():
			get_child(i).queue_free()
	
	channel_id = -1
	Systems.update_channel_systems(null)
	
	var loading_system = _loading_res.instance() as LoadingSystem
	loading_system.name = "LoadingSystem"
	
	loading_system.load_map_index = -1
	loading_system.connect("loading_ended", self, "_on_loading_ended")
	
	Systems.add_child(loading_system)


remote func __join_channel(joined_channel_id: int) -> void:
	Log.d("Joined channel: %d" % joined_channel_id)
	
	if get_child_count() > 0:
		for i in get_child_count():
			get_child(i).queue_free()
	
	channel_id = -1
	Systems.update_channel_systems(null)
	
	var loading_system: LoadingSystem
	if Systems.has_node("LoadingSystem"):
		loading_system = Systems.get_node("LoadingSystem")
		loading_system.load_map_index = joined_channel_id
		loading_system.start_loading()
	else:
		loading_system = _loading_res.instance() as LoadingSystem

		loading_system.load_map_index = joined_channel_id
		loading_system.connect("loading_ended", self, "_on_loading_ended")
		
		Systems.add_child(loading_system)


remote func __save_channel_data(_c_id: int, channel_data: Dictionary) -> void:
	var map_instance = MapInstance.new()
	map_instance.deserialize(channel_data.map)
	
	self.emit_signal("channel_data_downloaded", map_instance)
