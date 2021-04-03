class_name ChannelSystem
extends Node

var _channel_instance_res = preload("res://scenes/channel_instance.tscn")


func _ready():
	Log.d("Initializing Channel System")
	
	load_channel(1234)
	
	Systems.net.connect("session_connected", self, "_on_session_connected")


func is_channel_loaded(channel_id: int) -> bool:
	return self.has_node(str(channel_id))


func load_channel(channel_id: int) -> void:
	Log.d("Loading channel %d" % channel_id)
	
	var channel = _channel_instance_res.instance()
	
	channel.name = str(1234)
	
	self.add_child(channel)


func unload_channel(channel_id: int) -> void:
	Log.d("Unloading channel %d" % channel_id)
	
	self.get_node(str(channel_id)).queue_free()


func _on_session_connected(session_id: int) -> void:
	# TODO change this to be called from a DB result or something like that
	rpc_id(session_id, "join_channel", 1234)
