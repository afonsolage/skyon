class_name ChannelSystem
extends Node

var channel_id: int = 0

onready var _game_world_res := preload("res://scenes/game_world.tscn")
onready var _loading_res := preload("res://scenes/loading.tscn")

remote func join_channel(joined_channel_id: int) -> void:
	Log.d("Joined channel: %d" % joined_channel_id)
	
	if get_child_count() > 0:
		for i in get_child_count():
			get_child(i).queue_free()
	
	channel_id = joined_channel_id
	
	var loading_system = _loading_res.instance() as LoadingSystem

	# TODO: Match the file with the channel_id
	# TODO: Get this file from server if it doesn't exists
	loading_system.terrain_file_name = "user://terrain.tmp"
	loading_system.connect("loading_ended", self, "_on_loading_ended")
	
	Systems.add_child(loading_system)


func _on_loading_ended(loaded_assets: Dictionary) -> void:
	_load_world(loaded_assets)


func _load_world(loaded_assets: Dictionary) -> void:
	var game_world = _game_world_res.instance()
	game_world.name = str(channel_id)
	
	Systems.world = game_world.get_node("WorldSystem")
	Systems.combat = game_world.get_node("CombatSystem")
	Systems.input = game_world.get_node("InputSystem")
	Systems.player = game_world.get_node("PlayerSystem")
	
	Systems.world.add_child(loaded_assets.terrain)
	
	self.add_child(game_world)
