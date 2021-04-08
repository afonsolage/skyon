class_name ChannelSystem
extends Node

signal channel_loaded(channel_id)
signal channel_unloaded(channel_id)

const DATA_FOLDER = "user://channel/"

var _channel_instance_res = preload("res://scenes/channel_instance.tscn")
var _pending_channel_data: Dictionary
var _pending_channel_join: Dictionary
var _channel_requested: Array

func _init() -> void:
	Log.ok(connect("channel_loaded", self, "_on_channel_loaded"))

#	var _success := request_load_channel(Systems.atlas.calc_map_pos_index(Vector2(0, 0)))
#	_success = request_load_channel(Systems.atlas.calc_map_pos_index(Vector2(1, 0)))
#	_success = request_load_channel(Systems.atlas.calc_map_pos_index(Vector2(0, 1)))
#	_success = request_load_channel(Systems.atlas.calc_map_pos_index(Vector2(1, 1)))


func _ready() -> void:
	Log.d("Initializing Channel System")
	
	Log.ok(Systems.net.connect("session_connected", self, "_on_session_connected"))


func _unhandled_input(event):
	if get_child_count() > 0:
		if Systems.debug_view.selected_channel_id > -1:
			get_node(str(Systems.debug_view.selected_channel_id))._unhandled_input(event)


func is_channel_loaded(channel_id: int) -> bool:
	return self.has_node(str(channel_id))


func request_load_channel(channel_id: int) -> bool:
	if _is_already_loading(channel_id):
		Log.d("Already loading channel %d. Nothing to do." % channel_id)
		return false
	
	_channel_requested.push_back(channel_id)
	var map_pos := Systems.atlas.calc_map_pos(channel_id) as Vector2
	Systems.atlas.get_map_deferred(map_pos, self, "_on_map_component_loaded", [channel_id])
	
	return true


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
	if is_channel_loaded(channel_id):
		send_join_channel(session_id, channel_id)
	else:
		if request_load_channel(channel_id):
			if not _pending_channel_join.has(channel_id):
				_pending_channel_join[channel_id] = []
			
			_pending_channel_join[channel_id].push_back(session_id)


func send_join_channel(session_id: int, channel_id: int) -> void:
	rpc_id(session_id, "__join_channel", channel_id)


func _on_map_connection_area_entered(player: Player, area_id: int, channel_id: int) -> void:
	if area_id < 0 or area_id > HeightMapGenerator.DIRS.size():
		Log.e("Invalid area_id received (%d) for player %s on chanel %d" % [area_id, player, channel_id])
		return
	
	var world := Systems.get_world(channel_id) as WorldSystem
	var position := world.map_instance.map_component.position
	var next_map_dir := HeightMapGenerator.DIRS[area_id] as Vector2
	var next_map_pos := position + next_map_dir
	
	Log.d("Moving player from map %s to map %s" % [position, next_map_pos])
	
	rpc_id(player.session_id, "", Systems.atlas.calc_map_pos_index(next_map_pos))


# Since GDScript can't use varargs, we need to store our custom data in an array
func _on_map_component_loaded(map: MapComponent, data: Array) -> void:
	var channel = _channel_instance_res.instance()
	var world = channel.get_node("WorldSystem") as Node
	var channel_id = data[0] as int
	
	var map_instance = MapInstance.new()
	map_instance.name = "Map"
	map_instance.map_component = map
	map_instance.connect("connection_area_entered", self, "_on_map_connection_area_entered", [channel_id])
	
	world.set_map_instance(map_instance)
	
	channel.name = str(channel_id)
	
	self.add_child(channel)
	if _channel_requested.has(channel_id):
		_channel_requested.erase(channel_id)
	
	Log.d("Channel loaded!")
	self.emit_signal("channel_loaded", channel_id)


func _is_already_loading(channel_id: int) -> bool:
	return _channel_requested.has(channel_id)


func _get_channel_data(channel_id: int) -> Dictionary:
	var map_instance = Systems.get_world(channel_id).map_instance as MapInstance
	
	return {
		"map": map_instance.serialize()
	}


func _on_session_connected(session_id: int) -> void:
	# TODO change this to be called from a DB result or something like that
	join_channel_map(session_id, Vector2(0, 0))



func _on_channel_loaded(channel_id: int) -> void:
	if _pending_channel_data.has(channel_id):
		var sessions := _pending_channel_data[channel_id] as Array
		var _erased = _pending_channel_data.erase(channel_id)

		Log.d("Sessions waiting for channel data %s " % sessions)

		for session_id in sessions:
			send_channel_data(channel_id, session_id)
		
	if _pending_channel_join.has(channel_id):
		var sessions = _pending_channel_join[channel_id] as Array
		var _erased = _pending_channel_join.erase(channel_id)
		
		Log.d("Sessions waiting for channel join %s " % sessions)
		
		for session_id in sessions:
			send_join_channel(session_id, channel_id)


remote func __get_channel_data(channel_id: int) -> void:
	var session_id := get_tree().get_rpc_sender_id()
	
	if channel_id < 0:
		Log.e("Invalid map index (%d) request by session %d" % [channel_id, session_id])
		Systems.net.disconnect_session(session_id)
		return
	
	if is_channel_loaded(channel_id):
		send_channel_data(channel_id, session_id)
	else:
		if request_load_channel(channel_id):
			if not _pending_channel_data.has(channel_id):
				_pending_channel_data[channel_id] = []
			
			_pending_channel_data[channel_id].push_back(session_id)
		
