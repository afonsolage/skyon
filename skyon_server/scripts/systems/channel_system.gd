class_name ChannelSystem
extends Node

signal channel_loaded(channel_id)

const DATA_FOLDER = "user://channel/"

var _channel_instance_res = preload("res://scenes/channel_instance.tscn")
var _pending_channel_data: Dictionary
var _loading_threads: Dictionary

func _init() -> void:
	connect("channel_loaded", self, "_on_channel_loaded")

	var directory := Directory.new()
	if not directory.dir_exists(DATA_FOLDER):
		directory.open("user://channel")
		directory.make_dir_recursive(DATA_FOLDER)


func _ready() -> void:
	Log.d("Initializing Channel System")
	
	Systems.net.connect("session_connected", self, "_on_session_connected")


func is_channel_loaded(channel_id: int) -> bool:
	return self.has_node(str(channel_id))


func request_load_channel(channel_id: int) -> void:
	if _is_already_loading(channel_id):
		Log.d("Already loading channel %d. Nothing to do." % channel_id)
		return
	
	var thread = Thread.new()
	Log.ok(thread.start(self, "_t_load_channel", channel_id))
	_loading_threads[channel_id] = thread
	Log.d("Loading thread started!")
#	_t_load_channel(channel_id)


func unload_channel(channel_id: int) -> void:
	Log.d("Unloading channel %d" % channel_id)
	
	self.get_node(str(channel_id)).queue_free()


func send_channel_data(channel_id: int, session_id: int) -> void:
	var data := _get_channel_data(channel_id)
	rpc_id(session_id, "__set_channel_data", channel_id, data)


# _t_ means this function is called inside a thread
func _t_load_channel(channel_id: int) -> void:
	Log.d("Loading channel %d" % channel_id)
	
	var height_map := PackedHeightMap.new(0)
	var file_path := "%s/%d.hm" % [DATA_FOLDER, channel_id]
	if File.new().file_exists(file_path):
		height_map.load_from_resource(file_path)
	else:
		var terrain_generator := TerrainGenerator.new()
		terrain_generator.height_map_seed = channel_id
		
		height_map = terrain_generator.generate_height_map()
		
		height_map.save_to_resource(file_path)
	
	var terrain_generator := TerrainGenerator.new()
	# TODO: Load from biome pallet
	terrain_generator.height_colors = [
		Color.blue,
		Color.blue,
		Color.blue,
		Color.blue,
		Color.blue,
		Color.yellow,
		Color.yellowgreen,
		Color.green,
		Color.saddlebrown,
		Color.saddlebrown,
		Color.darkgray,
	]
	
	var terrain := terrain_generator.generate_mesh_instance_node(height_map)
	self.call_deferred("_finish_channel_load", channel_id, terrain)


func _finish_channel_load(channel_id: int, terrain: Terrain) -> void:
	var channel = _channel_instance_res.instance()
	
	channel.get_node("WorldSystem").add_child(terrain)
	channel.name = str(channel_id)
	
	self.add_child(channel)
	if _loading_threads.has(channel_id):
		_loading_threads[channel_id].wait_to_finish()
		_loading_threads.erase(channel_id)
		
	self.emit_signal("channel_loaded", channel_id)


func _is_already_loading(channel_id: int) -> bool:
	return _loading_threads.has(channel_id)


func _get_channel_data(channel_id: int) -> Dictionary:
	var terrain = Systems.get_world(channel_id).terrain as Terrain
	return {
		"height_map": {
			"size": terrain.height_map.size(),
			"buffer": terrain.height_map.buffer()
		}
	}


func _on_session_connected(session_id: int) -> void:
	# TODO change this to be called from a DB result or something like that
	rpc_id(session_id, "__join_channel", 1)


func _on_channel_loaded(channel_id: int) -> void:
	if not _pending_channel_data.has(channel_id):
		return

	var sessions := _pending_channel_data[channel_id] as PoolIntArray
	_pending_channel_data.erase(channel_id)

	for session_id in sessions:
		send_channel_data(channel_id, session_id)


remote func __get_channel_data(channel_id: int) -> void:
	var session_id := get_tree().get_rpc_sender_id()
	if is_channel_loaded(channel_id):
		send_channel_data(channel_id, session_id)
	else:
		if not _pending_channel_data.has(channel_id):
			_pending_channel_data[channel_id] = PoolIntArray()
		
		_pending_channel_data[channel_id].push_back(session_id)
		
		request_load_channel(channel_id)
