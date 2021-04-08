class_name LoadingSystem
extends Node

signal loading_ended(loaded_assets)

const MAPS_PATH = "user://maps/"

const TIPS = [
	"Dose anyone actually read these?",
	"Imagine something really funny here",
	"You cannot die if you health is always above 0",
	"Preparing something really special here",
	"Did you read all those tips? Really?",
	"Remember to sleep at least once a day",
]

export(int) var tip_change_interval: float = 5.0

var load_map_index: int

var _tip_change_timeout: float = 0.0


onready var _tip = $LoadingScreen/Tip

func _ready() -> void:
	FileUtils.ensure_user_path_exists(MAPS_PATH)
	
	_tip_change_timeout = tip_change_interval
	_set_random_tip()
	
	if load_map_index != -1:
		start_loading()


func _process(delta: float) -> void:
	_tip_change_timeout -= delta
	
	if _tip_change_timeout < 0:
		_tip_change_timeout = tip_change_interval
		_set_random_tip()


func start_loading() ->  void:
	if FileUtils.exists(_get_load_map_path()):
		_start_map_loading()
	else:
		Systems.channel.download_channel_data()
		Log.ok(Systems.channel.connect("channel_data_downloaded", self, "_on_channel_data_downloaded"))


func _set_random_tip() -> void:
	var tip_text = TIPS[rand_range(0, TIPS.size())]
	_tip.text = tip_text


func _get_load_map_path() -> String:
	return "%s/%d" % [MAPS_PATH, load_map_index]


func _start_map_loading() -> void:
	var thread := Thread.new()
	var loading_map_instance := LoadingMapInstance.new()
	loading_map_instance.deferred_object = self
	loading_map_instance.deferred_method = "_on_map_instance_loaded"
	loading_map_instance.deferred_args = [thread]
	
	Log.ok(thread.start(loading_map_instance, "_t_load_map", _get_load_map_path()))
#	loading_map_instance._t_load_map(_get_load_map_path())


func _on_channel_data_downloaded(map_instance: MapInstance) -> void:
	var thread := Thread.new()
	
	var loading_map_generator := LoadingMapGenerator.new()
	loading_map_generator.save_path = _get_load_map_path()
	loading_map_generator.deferred_object = self
	loading_map_generator.deferred_method = "_on_map_instance_loaded"
	loading_map_generator.deferred_args = [thread]
	
	Log.ok(thread.start(loading_map_generator, "_t_generate_map", map_instance))
#	loading_map_generator._t_generate_map(map_instance)


func _on_map_instance_loaded(map_instance: MapInstance, args: Array) -> void:
	var thread := args[0] as Thread
	var _res = thread.wait_to_finish()
	
	self.emit_signal("loading_ended", {
		"map_instance": map_instance,
		"map_index": load_map_index,
	})
	
	self.queue_free()


class LoadingMapGenerator:
	extends Node

	var save_path: String
	var deferred_object: Object
	var deferred_method: String
	var deferred_args: Array

	func _t_generate_map(map_instance: MapInstance) -> void:
		var generator := TerrainGenerator.new()
		generator.settings.height_colors = map_instance.map_component.height_pallet

		var packed_height_map := PackedHeightMap.new(MapComponent.SIZE)
		packed_height_map._buffer = map_instance.map_component.height_map

		var result := generator.generate_terrain_mesh(packed_height_map)
		map_instance.map_component.mesh = result[0]
		map_instance.map_component.collisions = result[1]

		map_instance.save_to(save_path)

		if is_instance_valid(deferred_object):
			deferred_object.call_deferred(deferred_method, map_instance, deferred_args)


class LoadingMapInstance:
	extends Node
	
	var deferred_object: Object
	var deferred_method: String
	var deferred_args: Array

	func _t_load_map(load_path: String) -> void:
		var map_instance := MapInstance.new()
		map_instance.load_from(load_path)
		
		if is_instance_valid(deferred_object):
			deferred_object.call_deferred(deferred_method, map_instance, deferred_args)
