class_name ChannelSystem
extends Node

signal channel_loaded(channel_id)
signal channel_unloaded(channel_id)

const DATA_FOLDER = "user://channel/"

var _channel_instance_res = preload("res://scenes/channel_instance.tscn")
var _channel_requested: Dictionary = {}

var _connected_sessions: Dictionary = {}

func _init() -> void:
	Log.ok(Systems.net.connect("session_connected", self, "_on_session_connected"))
	Log.ok(Systems.net.connect("session_disconnected", self, "_on_session_disconnected"))


func _ready() -> void:
	Log.d("Initializing Channel System")
	
#	yield(load_channel_async(Systems.atlas.calc_map_pos_index(Vector2(0, 0))), "completed")
#	ensure_channel_is_loaded_async(Systems.atlas.calc_map_pos_index(Vector2(0, 0)))
#	ensure_channel_is_loaded_async(Systems.atlas.calc_map_pos_index(Vector2(0, 0)))


func _unhandled_input(event):
	if get_child_count() > 0:
		if Systems.debug_view.selected_channel_id > -1:
			if is_channel_loaded(Systems.debug_view.selected_channel_id):
				get_node(str(Systems.debug_view.selected_channel_id))._unhandled_input(event)


func is_channel_loaded(channel_id: int) -> bool:
	return self.has_node(str(channel_id))


func load_channel_async(channel_id: int, settings: VoxelTerrainSettings = null) -> void:
	if _channel_requested.has(channel_id):
		Log.d("Already loading channel %d. Waiting for it to complete." % channel_id)
		yield(_channel_requested[channel_id], "done")
	else:
		var waiter = WaitingForChannel.new()
		_channel_requested[channel_id] = waiter
		
		var map_pos := Systems.atlas.calc_map_pos(channel_id) as Vector2

		var map := yield(Systems.atlas.load_map_async(map_pos, settings), "completed") as MapComponent

		var channel = _channel_instance_res.instance()
		channel.name = str(channel_id)
		
		var world = channel.get_node("WorldSystem") as Node
		world.setup_map_instance(map)
		
		self.add_child(channel)
		
		waiter.emit_signal("done")
		var _erased = _channel_requested.erase(channel_id)
		
		Log.d("Channel loaded!")
		self.emit_signal("channel_loaded", channel_id)


func unload_channel(channel_id: int) -> void:
	Log.d("Unloading channel %d" % channel_id)
	
	self.get_node(str(channel_id)).queue_free()
	
	self.emit_signal("channel_unloaded", channel_id)


func send_channel_data(channel_id: int, session_id: int) -> void:
	Log.d("Sending channel data %d to session %d" % [channel_id, session_id])
	
	var data := _get_channel_data(channel_id)
	rpc_id(session_id, "__save_channel_data", channel_id, data)


func join_channel_map(session_id: int, map_pos: Vector2) -> void:
	join_channel(session_id, Systems.atlas.calc_map_pos_index(map_pos))


func join_channel(session_id: int, channel_id: int) -> void:
	if not is_channel_loaded(channel_id):
		rpc_id(session_id, "__wait_to_join_channel")
		yield(load_channel_async(channel_id), "completed")
	
	rpc_id(session_id, "__join_channel", channel_id)


func _is_already_loading(channel_id: int) -> bool:
	return _channel_requested.has(channel_id)


func _get_channel_data(channel_id: int) -> Dictionary:
	var map_instance = Systems.get_world(channel_id).map_instance as MapInstance
	
	return {
		"map": map_instance.serialize()
	}


func _on_session_connected(session_id: int) -> void:
	if _connected_sessions.has(session_id):
		Log.e("Connecting to a session that already exists: %d" % session_id)
	
	_connected_sessions[session_id] = null
	
	# TODO: Find a better place for this
	join_channel_map(session_id, Vector2(0, 0))


func _on_session_disconnected(session_id: int) -> void:
	if not _connected_sessions.erase(session_id):
		Log.e("Removing a session that doesn't exists: %d" % session_id)


remote func __get_channel_data(channel_id: int) -> void:
	var session_id := get_tree().get_rpc_sender_id()
	
	if channel_id < 0:
		Log.e("Invalid map index (%d) request by session %d" % [channel_id, session_id])
		Systems.net.disconnect_session(session_id)
		return
	
	if not is_channel_loaded(channel_id):
		yield(load_channel_async(channel_id), "completed")
	
	Log.d("Sending channel data %d to session %d" % [channel_id, session_id])
	var data := _get_channel_data(channel_id)
	rpc_id(session_id, "__save_channel_data", channel_id, data)


class WaitingForChannel:
# warning-ignore:unused_signal
	signal done
