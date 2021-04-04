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
var _loading_thread: Thread

onready var _tip = $LoadingScreen/Tip
onready var _game_world_scene = preload("res://scenes/game_world.tscn")

func _ready() -> void:
	FileUtils.ensure_user_path_exists(MAPS_PATH)
	
	_tip_change_timeout = tip_change_interval
	_set_random_tip()
	_start_loading()


func _process(delta: float) -> void:
	_tip_change_timeout -= delta
	
	if _tip_change_timeout < 0:
		_tip_change_timeout = tip_change_interval
		_set_random_tip()


func _set_random_tip() -> void:
	var tip_text = TIPS[rand_range(0, TIPS.size())]
	_tip.text = tip_text


func _get_load_map_path() -> String:
	return "%s/%d" % [MAPS_PATH, load_map_index]


func _start_loading() ->  void:
	var file = File.new()
	if file.file_exists(_get_load_map_path()):
		_start_terrain_loading()
	else:
		Systems.channel.download_channel_data()
		Log.ok(Systems.channel.connect("channel_data_downloaded", self, "_start_terrain_loading"))


func _start_terrain_loading() -> void:
	_loading_thread = Thread.new()
	Log.ok(_loading_thread.start(self, "_t_load_terrain", load_map_index))

# _t_ means this function is called inside a thread
func _t_load_terrain(path: String) -> void:
	var height_map := PackedHeightMap.new(0)
	height_map.load_from_resource(path)
	
	var terrain_generator = TerrainGenerator.new()
	terrain_generator.size = height_map.size()
	
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
	
	var terrain := terrain_generator.generate_mesh_instance_node(height_map) as Terrain
	self.call_deferred("_load_ended", terrain)


func _load_ended(terrain: Terrain) -> void:
	_loading_thread.wait_to_finish()
	_loading_thread = null
	
	self.emit_signal("loading_ended", {
		"terrain": terrain
	})
	
	self.queue_free()
