class_name AtlasSystem
extends Node

# This class does a bit of heavy CPU task.
# Consider moving it to another server later on

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
	var atlas_map_generator := AtlasMapGenerator.new()
	Log.ok(thread.start(atlas_map_generator, "_t_load_or_generate_map", [
			map_pos,
			calc_map_pos_index(map_pos),
			_get_map_path(map_pos),
			self,
			]))
	
	_generation_threads[map_pos] = thread


func _finish_map_loading(map: MapComponent) -> void:
	var map_pos = map.position
	
	if _generation_threads.has(map_pos):
		var thread := _generation_threads[map_pos] as Thread
		var _res = thread.wait_to_finish()
		var _erased = _generation_threads.erase(map_pos)
	
	var dict := _deferred_calls[map_pos] as Dictionary
	
	if is_instance_valid(dict.object):
		if dict.args.empty():
			dict.object.call_deferred(dict.method, map)
		else:
			dict.object.call_deferred(dict.method, map, dict.args)
	
	var _erased = _deferred_calls.erase(map_pos)

func _get_map_path(map_pos: Vector2) -> String:
	return "%s/%d" % [ATLAS_PATH, calc_map_pos_index(map_pos)]


func _map_exists(map_pos: Vector2) -> bool:
	return FileUtils.exists(_get_map_path(map_pos))


class AtlasMapGenerator:
	extends Node
	# _t_ means this function is executed in a thread
	func _t_load_or_generate_map(args: Array) -> void:
		var map_pos = args[0] as Vector2
		var map_index = args[1] as int
		var map_path = args[2] as String
		var deffered_obj = args[3] as Object
		
		var map: MapComponent
		
		if FileUtils.exists(map_path):
			Log.d("Map %s already exists, loading it" % map_pos)
			map = MapComponent.new()
			map.load_from(map_path)
		else:
			Log.d("Map %s doesn't exists, generating it" % map_pos)
			map = MapComponent.new()
			map.position = map_pos
			
			var generator := TerrainGenerator.new()
			generator.height_map_seed = map_index
			generator.size = MapComponent.SIZE
			
			# TODO: Load biome settings
			generator.octaves = int(rand_range(2, 7))
			generator.persistance = rand_range(0.1, 0.9)
			generator.period = rand_range(10.0, 20.0)
			generator.border_size = int(rand_range(30, 100))
			
			Log.d("[Map %s] Generating height map" % map_pos)
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
			Log.d("[Map %s] Generating collisions map" % map_pos)
			map.collisions = generator.generate_collisions_mesh(packed_height_map)
			Log.d("[Map %s] Generating saving to disk" % map_pos)
			map.save_to(map_path)
		
		Log.d("[Map %s] Generation completed" % map_pos)
		
		if is_instance_valid(deffered_obj):
			deffered_obj.call_deferred("_finish_map_loading", map)
