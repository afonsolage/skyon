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


func load_map_async(map_pos: Vector2, settings: VoxelTerrainSettings = null) -> MapComponent:
	var atlas_map_generator := AtlasMapGenerator.new()
	atlas_map_generator.map_pos = map_pos
	atlas_map_generator.map_index = calc_map_pos_index(map_pos)
	atlas_map_generator.map_path = _get_map_path(map_pos)
	atlas_map_generator.settings = settings
	
#	atlas_map_generator.run_local = true
	
	var map := yield(atlas_map_generator.run(), "completed") as MapComponent
	
	return map


func _get_map_path(map_pos: Vector2) -> String:
	return "%s/%d" % [ATLAS_PATH, calc_map_pos_index(map_pos)]


func map_exists(map_pos: Vector2) -> bool:
	return FileUtils.exists(_get_map_path(map_pos))


func erase_map(map_pos: Vector2) -> void:
	FileUtils.erase(_get_map_path(map_pos))


class AtlasMapGenerator:
	extends SafeYieldThread
	
	var map_pos: Vector2
	var map_index: int
	var map_path: String
	var settings: VoxelTerrainSettings
	
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
				Color.blue,
				Color.dodgerblue,
				Color.darkgreen,
				Color.sienna,
				Color.sienna,
				Color.darkgray,
			]
			
			var generator := VoxelGenerator.new()
			
			if not settings:
				settings = VoxelTerrainSettings.new()
				settings.size = MapComponent.SIZE
				
				# TODO: Load biome settings
				settings.octaves = int(rand_range(2, 7))
				settings.persistance = rand_range(0.1, 0.9)
				settings.period = rand_range(10.0, 20.0)
				settings.border_size = int(rand_range(30, 60))
				settings.height_colors = map.height_pallet
				settings.seed_number = map_index
			
			settings.surrounding_connections = _t_get_surrounding_connections()
			generator.settings = settings
			
			Log.d("[Map %s] Generating height map" % map_pos)
			var result := generator.generate_voxel_height_map()
			var voxel_map := result[0] as VoxelMap
			var connections := result[1] as PoolVector2Array
			
			map.height_map = voxel_map.buffer()
			map.connections = connections
			Log.d("[Map %s] Generating collisions map" % map_pos)
			map.collisions = generator.generate_collisions_mesh(voxel_map)
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
