class_name LoadingSystem
extends Node

signal loading_ended
signal terrain_loaded(terrain)

const TIPS = [
	"Dose anyone actually read these?",
	"Imagine something really funny here",
	"You cannot die if you health is always above 0",
	"Preparing something really special here",
	"Did you read all those tips? Really?",
	"Remember to sleep at least once a day",
]

export(int) var tip_change_interval: float = 5.0

var terrain_file_name: String = "user://terrain.tmp"

var _tip_change_timeout: float = 0.0
var _loading_thread: Thread

onready var _tip = $LoadingScreen/Tip
onready var _game_world_scene = preload("res://scenes/game_world.tscn")

func _init() -> void:
	Log.ok(self.connect("terrain_loaded", self, "_on_terrain_loaded"))


func _ready() -> void:
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


func _start_loading() -> void:
	_loading_thread = Thread.new()
	Log.ok(_loading_thread.start(self, "_load_terrain", "user://terrain.tmp"))


func _on_terrain_loaded(terrain: Terrain) -> void:
	_loading_thread.wait_to_finish()
	_loading_thread = null
	
	var game_world_scene = _game_world_scene.instance()
	var world_system = game_world_scene.get_node("WorldSystem") as WorldSystem
	world_system.add_child(terrain)
	
	get_node("/root").call_deferred("add_child", game_world_scene)
	self.queue_free()
	self.emit_signal("loading_ended")


func _load_terrain(path: String) ->  void:
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
	self.call_deferred("_emit_terrain_loaded", terrain)


func _emit_terrain_loaded(terrain: Terrain) -> void:
	self.emit_signal("terrain_loaded", terrain)
