class_name LoadingSystem
extends Node

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

var _tip_change_timeout: float = 0.0


onready var _tip = $LoadingScreen/Tip

func _ready() -> void:
	FileUtils.ensure_user_path_exists(MAPS_PATH)
	
	_tip_change_timeout = tip_change_interval
	_set_random_tip()


func _process(delta: float) -> void:
	_tip_change_timeout -= delta
	
	if _tip_change_timeout < 0:
		_tip_change_timeout = tip_change_interval
		_set_random_tip()


func start_loading(map_index: int) ->  MapInstance:
	var map_instance: MapInstance
	var map_path := "%s/%d" % [MAPS_PATH, map_index]
	
	if FileUtils.exists(map_path):
		var loading_map_instance := LoadingMapInstance.new()
		loading_map_instance.load_path = map_path
		
		map_instance = yield(loading_map_instance.run(), "completed")
	else:
		map_instance = yield(
			Systems.channel.download_channel_data(map_index), 
			"completed"
		)

		var loading_map_generator := LoadingMapGenerator.new()
		loading_map_generator.save_path = map_path
		loading_map_generator.map_instance = map_instance
		
		yield(loading_map_generator.run(), "completed")

	self.queue_free()
	
	return map_instance


func _set_random_tip() -> void:
	var tip_text = TIPS[rand_range(0, TIPS.size())]
	_tip.text = tip_text


class LoadingMapGenerator:
	extends SafeYieldThread

	var map_instance: MapInstance
	var save_path: String
	
	func _t_do_work(_args: Array) -> void:
		var generator := LowPolyGenerator.new()
		generator.settings.height_colors = map_instance.map_component.height_pallet

		var voxel_map := LowPolyMap.new(MapComponent.SIZE)
		voxel_map._buffer = map_instance.map_component.height_map

		var result := generator.generate_terrain_mesh(voxel_map)
		map_instance.map_component.mesh = result[0]
		map_instance.map_component.collisions = result[1]
		
		map_instance.save_to(save_path)

		done(map_instance)


class LoadingMapInstance:
	extends SafeYieldThread
	
	var load_path: String

	func _t_do_work(_args: Array) -> void:
		var map_instance := MapInstance.new()
		map_instance.load_from(load_path)
		
		done(map_instance)
