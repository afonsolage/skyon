class_name ChannelSystem
extends Node

signal channel_data_downloaded(map_instance)

var channel_id: int = 0

onready var _game_world_res := preload("res://scenes/game_world.tscn")
onready var _loading_res := preload("res://scenes/loading.tscn")

func download_channel_data() -> void:
	rpc_id(1, "__get_channel_data", channel_id)


func _on_loading_ended(loaded_assets: Dictionary) -> void:
	_load_world(loaded_assets)


func _load_world(loaded_assets: Dictionary) -> void:
	var game_world = _game_world_res.instance()
	game_world.name = str(channel_id)
	
	Systems.world = game_world.get_node("WorldSystem")
	Systems.combat = game_world.get_node("CombatSystem")
	Systems.input = game_world.get_node("InputSystem")
	Systems.player = game_world.get_node("PlayerSystem")
	
	Systems.world.set_map_instance(loaded_assets.map_instance)
	
	self.add_child(game_world)


remote func __join_channel(joined_channel_id: int) -> void:
	Log.d("Joined channel: %d" % joined_channel_id)
	
	if get_child_count() > 0:
		for i in get_child_count():
			get_child(i).queue_free()
	
	channel_id = joined_channel_id
	
	var loading_system = _loading_res.instance() as LoadingSystem

	loading_system.load_map_index = joined_channel_id
	loading_system.connect("loading_ended", self, "_on_loading_ended")
	
	Systems.add_child(loading_system)


remote func __save_channel_data(_c_id: int, channel_data: Dictionary) -> void:
	var map_instance = MapInstance.new()
	map_instance.deserialize(channel_data.map)
	
	self.emit_signal("channel_data_downloaded", map_instance)
