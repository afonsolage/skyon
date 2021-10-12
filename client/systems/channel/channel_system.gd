class_name ChannelSystem
extends Node

signal channel_data_downloaded(map_instance)

var channel_id: int = -1

onready var _channel_instance_res := preload("res://systems/channel/channel_instance.tscn")
onready var _loading_res := preload("res://systems/channel/nodes/loading.tscn")

func download_channel_data(download_channel_id: int) -> MapInstance:
	rpc_id(1, "__get_channel_data", download_channel_id)
	return yield(self, "channel_data_downloaded")


func _load_world(map_instance: MapInstance, map_index: int) -> void:
	channel_id = map_index
	
	var channel_instance = _channel_instance_res.instance() as ChannelInstance
	channel_instance.name = str(channel_id)
	
	self.add_child(channel_instance)
	
	channel_instance.world.set_map_instance(map_instance)
	
	Systems.update_channel_systems(channel_instance)


remote func __wait_to_join_channel() -> void:
	Log.d("Waiting for channel to be ready")
	
	if get_child_count() > 0:
		for i in get_child_count():
			get_child(i).queue_free()
	
	channel_id = -1
	Systems.update_channel_systems(null)
	
	var loading_system = _loading_res.instance() as LoadingScreen
	loading_system.name = "LoadingScreen"

	Systems.add_child(loading_system)


remote func __join_channel(joined_channel_id: int) -> void:
	Log.d("Joined channel: %d" % joined_channel_id)
	
	if get_child_count() > 0:
		for i in get_child_count():
			get_child(i).queue_free()
	
	channel_id = -1
	Systems.update_channel_systems(null)
	
	var loading_system: LoadingScreen
	
	if Systems.has_node("LoadingScreen"):
		loading_system = Systems.get_node("LoadingScreen")
	else:
		loading_system = _loading_res.instance() as LoadingScreen
		Systems.add_child(loading_system)
	
	var map_instance: MapInstance = yield(loading_system.start_loading(joined_channel_id), "completed")
	_load_world(map_instance, joined_channel_id)


remote func __save_channel_data(_c_id: int, channel_data: Dictionary) -> void:
	var map_instance = MapInstance.new()
	map_instance.deserialize(channel_data.map)
	
	self.emit_signal("channel_data_downloaded", map_instance)
