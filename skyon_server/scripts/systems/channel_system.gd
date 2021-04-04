class_name ChannelSystem
extends Node

signal channel_loaded(channel_id)
signal channel_unloaded(channel_id)

const DATA_FOLDER = "user://channel/"

var _channel_instance_res = preload("res://scenes/channel_instance.tscn")
var _pending_channel_data: Dictionary
var _loading_threads: Dictionary

func _init() -> void:
	Log.ok(connect("channel_loaded", self, "_on_channel_loaded"))

	var directory := Directory.new()
	if not directory.dir_exists(DATA_FOLDER):
		Log.ok(directory.open("user://channel"))
		Log.ok(directory.make_dir_recursive(DATA_FOLDER))


func _ready() -> void:
	Log.d("Initializing Channel System")
	
	request_load_channel(1)
	request_load_channel(2)
	request_load_channel(3)
	request_load_channel(4)
	request_load_channel(5)
	
	Log.ok(Systems.net.connect("session_connected", self, "_on_session_connected"))


func _unhandled_input(event):
	if get_child_count() > 0:
		if Systems.debug_view.selected_channel_id > -1:
			get_node(str(Systems.debug_view.selected_channel_id))._input(event)


func is_channel_loaded(channel_id: int) -> bool:
	return self.has_node(str(channel_id))


func request_load_channel(channel_id: int) -> void:
	if _is_already_loading(channel_id):
		Log.d("Already loading channel %d. Nothing to do." % channel_id)
		return
	
	var map_pos := Systems.atlas.calc_map_pos(channel_id) as Vector2
	Systems.atlas.get_map_deferred(map_pos, self, "_finish_channel_load", [channel_id])


func unload_channel(channel_id: int) -> void:
	Log.d("Unloading channel %d" % channel_id)
	
	self.get_node(str(channel_id)).queue_free()
	
	self.emit_signal("channel_unloaded", channel_id)


func send_channel_data(channel_id: int, session_id: int) -> void:
	Log.d("Sending channel data %d to session %d" % [channel_id, session_id])
	
	var data := _get_channel_data(channel_id)
	rpc_id(session_id, "__set_channel_data", channel_id, data)

#
## _t_ means this function is called inside a thread
#func _t_load_channel(channel_id: int) -> void:
#	Log.d("Loading channel %d" % channel_id)
#
#	var height_map := PackedHeightMap.new(0)
#	var file_path := "%s/%d.hm" % [DATA_FOLDER, channel_id]
#	if File.new().file_exists(file_path):
#		Log.d("Height map %d already exists, loading it" % channel_id)
#		height_map.load_from_resource(file_path)
#	else:
#		Log.d("Height map %d doesn't exists, generating a new one" % channel_id)
#		var terrain_generator := TerrainGenerator.new()
#		terrain_generator.height_map_seed = channel_id
#
#		height_map = terrain_generator.generate_height_map()
#
#		height_map.save_to_resource(file_path)
#
#	var terrain_generator := TerrainGenerator.new()
#	# TODO: Load from biome pallet
#	terrain_generator.height_colors = [
#		Color.blue,
#		Color.blue,
#		Color.blue,
#		Color.blue,
#		Color.blue,
#		Color.yellow,
#		Color.yellowgreen,
#		Color.green,
#		Color.saddlebrown,
#		Color.saddlebrown,
#		Color.darkgray,
#	]
#
#	var terrain := terrain_generator.generate_mesh_instance_node(height_map)
#	self.call_deferred("_finish_channel_load", channel_id, terrain)
#


func _finish_channel_load(map: MapComponent, data: Array) -> void:
	var channel = _channel_instance_res.instance()
	var world = channel.get_node("WorldSystem") as Node
	var channel_id = data[0] as int
	
	var map_instance = MapInstance.new()
	map_instance.map_component = map
	
	world.set_map_instance(map_instance)
	
	channel.name = str(channel_id)
	
	self.add_child(channel)
	if _loading_threads.has(channel_id):
		_loading_threads[channel_id].wait_to_finish()
		var _erased = _loading_threads.erase(channel_id)
	
	Log.d("Channel loaded!")
	self.emit_signal("channel_loaded", channel_id)


func _is_already_loading(channel_id: int) -> bool:
	return _loading_threads.has(channel_id)


func _get_channel_data(channel_id: int) -> Dictionary:
	var map_instance = Systems.get_world(channel_id).map_instance as MapInstance
	
	return {
		"map": map_instance.get_serializable_data()
	}


func _on_session_connected(session_id: int) -> void:
	# TODO change this to be called from a DB result or something like that
	rpc_id(session_id, "__join_channel", 0)


func _on_channel_loaded(channel_id: int) -> void:
	if not _pending_channel_data.has(channel_id):
		Log.d("No one was waiting for channel %d " % channel_id)
		return

	var sessions := _pending_channel_data[channel_id] as Array
	var _erased = _pending_channel_data.erase(channel_id)

	Log.d("Sessions waiting for channel %s " % sessions)

	for session_id in sessions:
		send_channel_data(channel_id, session_id)


remote func __get_channel_data(channel_id: int) -> void:
	var session_id := get_tree().get_rpc_sender_id()
	if is_channel_loaded(channel_id):
		send_channel_data(channel_id, session_id)
	else:
		if not _pending_channel_data.has(channel_id):
			_pending_channel_data[channel_id] = []
		
		_pending_channel_data[channel_id].push_back(session_id)
		
		request_load_channel(channel_id)
