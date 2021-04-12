class_name AtlasSystem
extends Node

# This class does a bit of heavy CPU task.
# Consider moving it to another server later on

const ATLAS_PATH = "user://atlas/"
const ATLAS_AXIS_SIZE = 46_340 # sqrt(2_147_395_600)
const ATLAS_AXIS_OFFSET = 23169 #-

onready var ProceduralGeneratorSettings = preload("res://scripts/shared/procedural/ProceduralGeneratorSettings.cs")

func _ready():
	FileUtils.ensure_user_path_exists(ATLAS_PATH)
	

func calc_map_pos_index(map_pos: Vector2) -> int:
	return int(map_pos.x + ATLAS_AXIS_OFFSET) * ATLAS_AXIS_SIZE + int(map_pos.y + ATLAS_AXIS_OFFSET)


func calc_map_pos(index: int) -> Vector2:
# warning-ignore:integer_division
	var x := index / ATLAS_AXIS_SIZE
	var y := index % ATLAS_AXIS_SIZE
	return Vector2(x - ATLAS_AXIS_OFFSET, y - ATLAS_AXIS_OFFSET)


func load_map_async(map_pos: Vector2, settings: TerrainGeneratorSettings = null) -> MapComponent:
	var atlas_map_generator := AtlasMapGeneratorCS.new()
	atlas_map_generator.map_index = calc_map_pos_index(map_pos)
	atlas_map_generator.map_pos = map_pos
	atlas_map_generator.map_path = _get_map_path(map_pos)
#	atlas_map_generator._debug = true
#	atlas_map_generator.settings = settings
	
	var map := yield(atlas_map_generator.run(), "completed") as MapComponent
#	var map = atlas_map_generator.run()
#	yield(get_tree(), "idle_frame")
	
	return map


func _get_map_path(map_pos: Vector2) -> String:
	return "%s/%d" % [ATLAS_PATH, calc_map_pos_index(map_pos)]


func map_exists(map_pos: Vector2) -> bool:
	return FileUtils.exists(_get_map_path(map_pos))


class AtlasMapGenerator:
	extends SafeYieldThread
	
	var map_pos: Vector2
	var map_index: int
	var map_path: String
	var settings: TerrainGeneratorSettings
	
	func _t_do_work(_args: Array) -> void:
		var map: MapComponent
		
		if not (settings and settings.is_force_generation) and FileUtils.exists(map_path):
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
			
			if not settings:
				settings = TerrainGeneratorSettings.new()
				settings.size = MapComponent.SIZE
				
				# TODO: Load biome settings
				settings.octaves = int(rand_range(2, 7))
				settings.persistance = rand_range(0.1, 0.9)
				settings.period = rand_range(10.0, 20.0)
				settings.border_size = int(rand_range(30, 60))
				settings.height_colors = map.height_pallet
			
			settings.surrounding_connections = _t_get_surrounding_connections()
			settings.height_map_seed = map_index
			generator.settings = settings
			
			Log.d("[Map %s] Generating map" % map_pos)
			var packed_height_map := generator.generate_height_map()

			map.height_map = packed_height_map.buffer()
			map.connections = packed_height_map._connections
			Log.d("[Map %s] Generating collisions map" % map_pos)
			map.collisions = generator.generate_collisions_mesh(packed_height_map)
			Log.d("[Map %s] Generating saving to disk" % map_pos)
			map.save_to(map_path)
		
		Log.d("[Map %s] Generation completed" % map_pos)
		
		done(map)

	func _t_get_surrounding_connections() -> PoolVector2Array:
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


class AtlasMapGeneratorCS:
	extends SafeYieldThread
	
	var map_pos: Vector2
	var map_index: int
	var map_path: String
	
	func _t_do_work(_args: Array):
		var map: MapComponent
		
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
		
		
		var settings = load("res://scripts/shared/procedural/ProceduralGeneratorSettings.cs").new()
		settings.Size = MapComponent.SIZE
		
		seed(map_index)
		
		# TODO: Load biome settings
		settings.Octaves = int(rand_range(2, 7))
		settings.Persistance = rand_range(0.1, 0.9)
		settings.Period = rand_range(10.0, 20.0)
		settings.BorderSize = int(rand_range(30, 60))
		settings.HeightColors = map.height_pallet
		
		settings.ExistingConnections = _t_get_surrounding_connections()
		settings.Seed = map_index
		
		var generator = load("res://scripts/shared/procedural/ProceduralGenerator.cs").new(settings)
		generator.Settings = settings
		
#		Log.d("[Map %s] Generating height map" % map_pos)
		Log.d("[Map %s] Generating map" % map_pos)
		var map_2d = generator.GenerateMap2D()
		map.height_map = map_2d.HeightMapBuffer
		map.connections = map_2d.Connections
		Log.d("[Map %s] Generating collisions map" % map_pos)
		generator.GenerateCollisions(map_2d)
		map.collisions = map_2d.Collisions
		Log.d("[Map %s] Generating saving to disk" % map_pos)
#		map.save_to(map_path)

		Log.d("[Map %s] Generation completed" % map_pos)
		
		done(map)

	func _t_get_surrounding_connections() -> PoolVector2Array:
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
