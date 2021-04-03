class_name ChannelSystem
extends Node

var _channel_instance_res = preload("res://scenes/channel_instance.tscn")


func _ready():
	Log.d("Initializing Channel System")
	
	load_channel(1234)


func load_channel(channel_id: int) -> void:
	Log.d("Loading channel %d" % channel_id)
	
	var channel = _channel_instance_res.instance()
	
	channel.name = str(1234)
	
	self.add_child(channel)


func unload_channel(channel_id: int) -> void:
	Log.d("Unloading channel %d" % channel_id)
	
	get_node(str(channel_id)).queue_free()
