class_name AtlasSystem
extends Node

# This class does a bit of heavy CPU task.
# Consider moving it to another server later on

const ATLAS_PATH = "user://atlas/"
const ATLAS_AXIS_SIZE = 46_340 # sqrt(2_147_395_600)
const ATLAS_AXIS_OFFSET = 23169 #-

func _ready():
	FileUtils.ensure_user_path_exists(ATLAS_PATH)
	

func calc_map_pos_index(map_pos: Vector2) -> int:
	return int(map_pos.x + ATLAS_AXIS_OFFSET) * ATLAS_AXIS_SIZE + int(map_pos.y + ATLAS_AXIS_OFFSET)


func calc_map_pos(index: int) -> Vector2:
# warning-ignore:integer_division
	var x := index / ATLAS_AXIS_SIZE
	var y := index % ATLAS_AXIS_SIZE
	return Vector2(x - ATLAS_AXIS_OFFSET, y - ATLAS_AXIS_OFFSET)


func get_map_deferred(map_pos: Vector2, object: Object, method: String, 
		args: Array = [], generation_settings: TerrainGeneratorSettings = null) -> void:
	var thread := Thread.new()
	var atlas_map_generator := AtlasMapGenerator.new()
	atlas_map_generator.deferred_object = self
	atlas_map_generator.deferred_method = "_finish_map_loading"
	atlas_map_generator.deferred_args = [thread, object, method, args]
	
	var thread_args = [
		map_pos,
		calc_map_pos_index(map_pos),
		_get_map_path(map_pos),
		generation_settings,
	]
	
	Log.ok(thread.start(atlas_map_generator, "_t_load_or_generate_map", thread_args))
#	atlas_map_generator._t_load_or_generate_map(thread_args)


func _finish_map_loading(map: MapComponent, args: Array) -> void:
	var thread := args[0] as Thread
	if thread:
		var _res = thread.wait_to_finish()
	
	var deferred_object := args[1] as Object
	
	if is_instance_valid(deferred_object):
		var deferred_method := args[2] as String
		var deferred_args := args[3] as Array
		
		if not deferred_args or deferred_args.empty():
			deferred_object.call_deferred(deferred_method, map)
		else:
			deferred_object.call_deferred(deferred_method, map, deferred_args)


func _get_map_path(map_pos: Vector2) -> String:
	return "%s/%d" % [ATLAS_PATH, calc_map_pos_index(map_pos)]


func map_exists(map_pos: Vector2) -> bool:
	return FileUtils.exists(_get_map_path(map_pos))


class AtlasMapGenerator:
	extends Node
	
	var deferred_object: Object
	var deferred_method: String
	var deferred_args: Array
	
	# _t_ means this function is executed in a thread
	func _t_load_or_generate_map(args: Array) -> void:
		var map_pos = args[0] as Vector2
		var map_index = args[1] as int
		var map_path = args[2] as String
		var generation_settings = args[3] as TerrainGeneratorSettings
		
		var map: MapComponent
		
		if not (generation_settings and generation_settings.is_force_generation) \
				and FileUtils.exists(map_path):
			Log.d("Map %s already exists, loading it" % map_pos)
			map = MapComponent.new()
			map.load_from(map_path)
		else:
			Log.d("Map %s doesn't exists, generating it" % map_pos)
			map = MapComponent.new()
			map.position = map_pos
			
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
			
			var generator := TerrainGenerator.new()
			
			if not generation_settings:
				generation_settings = TerrainGeneratorSettings.new()
				generation_settings.size = MapComponent.SIZE
				
				# TODO: Load biome settings
				generation_settings.octaves = int(rand_range(2, 7))
				generation_settings.persistance = rand_range(0.1, 0.9)
				generation_settings.period = rand_range(10.0, 20.0)
				generation_settings.border_size = int(rand_range(30, 60))
				generation_settings.height_colors = map.height_pallet
			
			generation_settings.surrounding_connections = _t_get_surrounding_connections(map_pos)
			generation_settings.height_map_seed = map_index
			generator.settings = generation_settings
			
			Log.d("[Map %s] Generating height map" % map_pos)
			var packed_height_map := generator.generate_height_map()
			
			map.height_map = packed_height_map.buffer()
			map.connections = packed_height_map._connections
			Log.d("[Map %s] Generating collisions map" % map_pos)
			map.collisions = generator.generate_collisions_mesh(packed_height_map)
			Log.d("[Map %s] Generating saving to disk" % map_pos)
			map.save_to(map_path)
		
		Log.d("[Map %s] Generation completed" % map_pos)
		
		if is_instance_valid(deferred_object):
			deferred_object.call_deferred(deferred_method, map, deferred_args)


	func _t_get_surrounding_connections(map_pos: Vector2) -> PoolVector2Array:
		var connections = PoolVector2Array([
			Vector2.ZERO,
			Vector2.ZERO,
			Vector2.ZERO,
			Vector2.ZERO,
		])
		
		for i in Consts.DIRS.size():
			var dir := Consts.DIRS[i] as Vector2
			var neighbor_pos := map_pos + dir
			
			if Systems.atlas.map_exists(neighbor_pos):
				var neighbor_path = Systems.atlas._get_map_path(neighbor_pos)
				var neighbor_map = MapComponent.new()
				
				neighbor_map.load_from(neighbor_path)
				
				match dir:
					Vector2.RIGHT:
						connections[i] = neighbor_map.connections[Consts.Direction.LEFT]
					Vector2.UP:
						connections[i] = neighbor_map.connections[Consts.Direction.DOWN]
					Vector2.LEFT:
						connections[i] = neighbor_map.connections[Consts.Direction.RIGHT]
					Vector2.DOWN:
						connections[i] = neighbor_map.connections[Consts.Direction.UP]
					_:
						Log.e("Invalid direction: %s" % dir)

		return connections
