class_name AtlasSystem
extends Node

const ATLAS_PATH = "user://atlas/"
const ATLAS_AXIS_SIZE = 46_340 # sqrt(2_147_395_600)

var _deferred_calls: Dictionary
var _generation_threads: Dictionary

func _ready():
	FileUtils.ensure_user_path_exists(ATLAS_PATH)


func calc_map_pos_index(map_pos: Vector2) -> int:
	return int(map_pos.x) * ATLAS_AXIS_SIZE + int(map_pos.y)


func calc_map_pos(index: int) -> Vector2:
# warning-ignore:integer_division
	return Vector2(index / ATLAS_AXIS_SIZE, index % ATLAS_AXIS_SIZE)


func get_map_deferred(map_pos: Vector2, object: Object, method: String, args: Array = []) -> void:

		_deferred_calls[map_pos] = {
			"object": object,
			"method": method,
			"args": args
		}
		_start_map_loading(map_pos)


func _start_map_loading(map_pos: Vector2) -> void:
	var thread := Thread.new()
	Log.ok(thread.start(self, "_t_load_or_generate_map", map_pos))
	_generation_threads[map_pos] = thread


func _finish_map_loading(map: MapComponent) -> void:
	var map_pos = map.position
	
	var thread := _generation_threads[map_pos] as Thread
	var _res = thread.wait_to_finish()
	var _erased = _generation_threads.erase(map_pos)
	
	var dict := _deferred_calls[map_pos] as Dictionary
	
	if is_instance_valid(dict.object):
		if dict.args.empty():
			dict.object.call_deferred(dict.method, map)
		else:
			dict.object.call_deferred(dict.method, map, dict.args)
	
	_erased = _deferred_calls.erase(map_pos)

func _get_map_path(map_pos: Vector2) -> String:
	return "%s/%d" % [ATLAS_PATH, calc_map_pos_index(map_pos)]


func _map_exists(map_pos: Vector2) -> bool:
	return FileUtils.exists(_get_map_path(map_pos))


func _load_map(map_pos: Vector2) -> MapComponent:
	var map := MapComponent.new()
	map.load_from(_get_map_path(map_pos))
	return map

# _t_ means this function is executed in a thread
func _t_load_or_generate_map(map_pos: Vector2) -> void:
	var map: MapComponent
	
	if _map_exists(map_pos):
		map = _load_map(map_pos)
	else:
		map = MapComponent.new()
		map.position = map_pos
		
		var generator := TerrainGenerator.new()
		generator.height_map_seed = calc_map_pos_index(map_pos)
		generator.size = MapComponent.SIZE
		
		# TODO: Load biome settings
		generator.octaves = int(rand_range(2, 7))
		generator.persistance = rand_range(0.1, 0.9)
		generator.period = rand_range(1.0, 20.0)
		generator.border_size = int(rand_range(10, 50))
		
		var packed_height_map := generator.generate_height_map()
		
		map.height_map = packed_height_map.buffer()
		map.connections = packed_height_map._connections
		# TODO: Load from biome pallet
		map.height_pallet = [
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
		map.collisions = generator.generate_collisions_mesh(packed_height_map)
		map.save_to(_get_map_path(map_pos))
	
	self.call_deferred("_finish_map_loading", map)
