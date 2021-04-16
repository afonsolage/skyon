class_name VoxelGenerator
extends Spatial

export(Resource) var settings := VoxelTerrainSettings.new() as Resource

onready var add_map_x := $Control/HBoxContainer/VBoxContainer/HBoxContainer/AddMapX
onready var add_map_y := $Control/HBoxContainer/VBoxContainer/HBoxContainer/AddMapY

func generate_collisions_mesh(voxel_map: VoxelMap) -> PoolVector3Array:
	var planes := _create_planes(voxel_map)
	var indexes := _create_indexes(planes)
	
	var vertices := PoolVector3Array()
	for side in planes:
		vertices.append_array(planes[side])
	
	var collisions := PoolVector3Array()
	collisions.resize(indexes.size())
	
	for i in indexes:
		collisions.push_back(vertices[i])
	
	return collisions


func generate_connections_area(connections: PoolVector2Array) -> Array:
	var connections_areas := []
	
	for i in connections:
		var connection := connections[i] as Vector2
		
		if connection == Vector2.ZERO or connection == Vector2(-1, -1):
			continue
		
		var box_size := settings.border_connection_size as float
		var box_shape = BoxShape.new()
		box_shape.extents = Vector3(box_size, box_size, box_size)
		
		var shape = CollisionShape.new()
		shape.shape = box_shape
		
		var area := Area.new()
		area.name = "connection %i" % i
	
	return connections_areas


func generate_terrain_mesh(voxel_map: VoxelMap, collisions: bool = true) -> Array:
	Log.d("Generating a new terrain mesh!")
	
	var planes := _create_planes(voxel_map)
	var indices := _create_indexes(planes)
	
	var mat := SpatialMaterial.new()
	mat.albedo_color = Color.white;
	mat.vertex_color_use_as_albedo = true
	
	var vertices = PoolVector3Array()
	var normals = PoolVector3Array()
	var colors = PoolColorArray()

	for side in planes:
		var side_vertices: PoolVector3Array = planes[side]
		var normal := _get_side_normal(side)
		for i in range(0, side_vertices.size(), 4):
			var h = side_vertices[i].y - 1
			var c = settings.height_colors[h]
			
			vertices.push_back(side_vertices[i])
			normals.push_back(normal)
			colors.push_back(c)
			
			vertices.push_back(side_vertices[i + 1])
			normals.push_back(normal)
			colors.push_back(c)
			
			vertices.push_back(side_vertices[i + 2])
			normals.push_back(normal)
			colors.push_back(c)
			
			vertices.push_back(side_vertices[i + 3])
			normals.push_back(normal)
			colors.push_back(c)

	var collision_shape_faces := PoolVector3Array()
	
	if collisions:
		collision_shape_faces.resize(indices.size())
		for i in indices:
			collision_shape_faces.push_back(vertices[i])

	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = vertices
	arrays[ArrayMesh.ARRAY_NORMAL] = normals
	arrays[ArrayMesh.ARRAY_INDEX] = indices
	arrays[ArrayMesh.ARRAY_COLOR] = colors
	
	var new_mesh = ArrayMesh.new()
	new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	new_mesh.surface_set_material(0, mat)
	
	return [new_mesh, collision_shape_faces]


func _get_side_normal(side: String) -> Vector3:
	if side == "front":
		return Vector3.BACK
	elif side == "back":
		return Vector3.FORWARD
	elif side == "right":
		return Vector3.RIGHT
	elif side == "left":
		return Vector3.LEFT
	else:
		return Vector3.UP
	


func _create_planes(voxel_map: VoxelMap) -> Dictionary:
	var right := PoolVector3Array()
	var left := PoolVector3Array()
	var front := PoolVector3Array()
	var back := PoolVector3Array()

	for i in voxel_map.buffer_size():
		var h := int(voxel_map.get_at_index(i))
		var x = int(i / voxel_map.size())
		var z = int(i % voxel_map.size())
		
		right.append_array(_right_vertices(voxel_map, x, h, z))
		left.append_array(_left_vertices(voxel_map, x, h, z))
		front.append_array(_front_vertices(voxel_map, x, h, z))
		back.append_array(_back_vertices(voxel_map, x, h, z))
	
	var planes = {
		"right": right,
		"front": front,
		"left": left,
		"back": back,
	}
	
	_merge_faces(planes, voxel_map)
		
	return planes


#    
#   v1         v2
#    +---------+
#    |\ v3     |\ v4
#    | +---------+
#    | |     v6| |
# v5 +-|-------+ |
#     \|        \|
#    v7+---------+ v8
#
#   Y
#   |
#   +-- X
#  /
# Z

func _top_vertices(x: int, y: int, z: int) -> Array:
	return [
		_v1(x, y, z),
		_v2(x, y, z),
		_v4(x, y, z),
		_v3(x, y, z),
	]


func _left_vertices(voxel_map: VoxelMap, x: int, y: int, z: int) -> PoolVector3Array:
	var height_difference := _calc_height_difference("left", voxel_map, x, y, z)
	
	if height_difference > 0:
		return PoolVector3Array([
			_v1(x, y, z),
			_v3(x, y, z),
			_v7(x, y - height_difference + 1, z),
			_v5(x, y - height_difference + 1, z),
		])
	else:
		return PoolVector3Array()

func _right_vertices(voxel_map: VoxelMap, x: int, y: int, z: int) -> PoolVector3Array:
	var height_difference := _calc_height_difference("right", voxel_map, x, y, z)
	
	if height_difference > 0:
		return PoolVector3Array([
			_v4(x, y, z),
			_v2(x, y, z),
			_v6(x, y - height_difference + 1, z),
			_v8(x, y - height_difference + 1, z),
		])
	else:
		return PoolVector3Array()

func _front_vertices(voxel_map: VoxelMap, x: int, y: int, z: int) -> PoolVector3Array:
	var height_difference := _calc_height_difference("front", voxel_map, x, y, z)
	
	if height_difference > 0:
		return PoolVector3Array([
			_v3(x, y, z),
			_v4(x, y, z),
			_v8(x, y - height_difference + 1, z),
			_v7(x, y - height_difference + 1, z),
		])
	else:
		return PoolVector3Array()

func _back_vertices(voxel_map: VoxelMap, x: int, y: int, z: int) -> PoolVector3Array:
	var height_difference := _calc_height_difference("back", voxel_map, x, y, z)
	
	if height_difference > 0:
		return PoolVector3Array([
			_v1(x, y, z),
			_v5(x, y - height_difference + 1, z),
			_v6(x, y - height_difference + 1, z),
			_v2(x, y, z),
		])
	else:
		return PoolVector3Array()


func _v1(x: int, y: int, z: int) -> Vector3:
	return Vector3(x, y + 1, z)


func _v2(x: int, y: int, z: int) -> Vector3:
	return Vector3(x + 1, y + 1, z)


func _v3(x: int, y: int, z: int) -> Vector3:
	return Vector3(x, y + 1, z + 1)


func _v4(x: int, y: int, z: int) -> Vector3:
	return Vector3(x + 1, y + 1, z + 1)


func _v5(x: int, y: int, z: int) -> Vector3:
	return Vector3(x, y, z)


func _v6(x: int, y: int, z: int) -> Vector3:
	return Vector3(x + 1, y, z)


func _v7(x: int, y: int, z: int) -> Vector3:
	return Vector3(x, y, z + 1)


func _v8(x: int, y: int, z: int) -> Vector3:
	return Vector3(x + 1, y, z + 1)


func _calc_height_difference(side: String, voxel_map: VoxelMap, x: int, y: int, z: int) -> int:
	var normal := _get_side_normal(side)
	var next_idx := voxel_map.calc_index(int(normal.x) + x, int(normal.z) + z)
	
	if next_idx > 0 and next_idx < voxel_map.buffer_size():
		var previous_height := int(voxel_map.get_at_index(next_idx))
		if y > previous_height:
			return y - previous_height
			
	return 0


func _merge_faces(planes: Dictionary, voxel_map: VoxelMap) -> void:
	var merged := PoolByteArray()
	merged.resize(settings.size * settings.size)
	var merged_faces := PoolVector3Array()

	for i in merged.size():
		merged[i] = 0

	for x in settings.size:
		for z in settings.size:
			var pos := Vector2(x, z)

			if merged[voxel_map.calc_index(int(pos.x), int(pos.y))] == 1:
				continue

			var h := int(voxel_map.get_at(x, z))
			var origin_x = x
			var origin_z = z

			var end_z = z + 1
			while end_z < settings.size:
				var npos := Vector2(origin_x, end_z)

				var nh := int(voxel_map.get_at(origin_x, end_z))

				if nh == h and merged[voxel_map.calc_index(int(npos.x), int(npos.y))] == 0:
					end_z += 1
				else:
					break

			end_z -= 1

			var end_x = origin_x
			var done := false
			while end_x < settings.size and not done:
				end_x += 1
				
				if end_x >= settings.size:
					break
				
				for tmp_z in range(origin_z, end_z + 1):
					var npos := Vector2(end_x, tmp_z)
					var nh := int(voxel_map.get_at(end_x, tmp_z))
					
					if nh == h and merged[voxel_map.calc_index(int(npos.x), int(npos.y))] == 0:
						tmp_z += 1
					else:
						done = true
						break

			end_x -= 1

			for wx in range(origin_x, end_x + 1):
				for wz in range(origin_z, end_z + 1):
					merged[voxel_map.calc_index(wx, wz)] = 1

			merged_faces.push_back(_v1(origin_x, h, origin_z))
			merged_faces.push_back(_v2(end_x, h, origin_z))
			merged_faces.push_back(_v4(end_x, h, end_z))
			merged_faces.push_back(_v3(origin_x, h, end_z))

	planes.top = merged_faces


func _create_indexes(planes: Dictionary) -> PoolIntArray:
	var indexes := PoolIntArray()

	var n := 0
	for vertices in planes.values():
		
		if not vertices.size() % 4 == 0:
			push_error("Invalid vertices size: %d" % vertices.size())
		
		for _k in range(0, vertices.size(), 4):
			indexes.push_back(n)
			indexes.push_back(n + 1)
			indexes.push_back(n + 3)

			indexes.push_back(n + 1)
			indexes.push_back(n + 2)
			indexes.push_back(n + 3)
			
			n += 4
	
	return indexes


func generate_voxel_height_map() -> Array:
	var height_map_generator := HeightMapGenerator.new()
	
	height_map_generator.is_generate_terrain = settings.is_generate_terrain
	height_map_generator.is_generate_border = settings.is_generate_border
	height_map_generator.is_generate_connections = settings.is_generate_connections
	height_map_generator.is_normalize_height = settings.is_normalize_height

	height_map_generator.size = settings.size
	height_map_generator.octaves = settings.octaves
	height_map_generator.persistance = settings.persistance
	height_map_generator.period = settings.period
	height_map_generator.border_size = settings.border_size
	height_map_generator.border_thickness = settings.border_thickness
	height_map_generator.border_montains = settings.border_montains
	height_map_generator.border_connection_size = settings.border_connection_size
	height_map_generator.places_count = settings.places_count
	height_map_generator.places_path_noise_rate = settings.places_path_noise_rate
	height_map_generator.places_path_thickness = settings.places_path_thickness

	height_map_generator.existing_connections = settings.surrounding_connections
	
	var full_height_map := height_map_generator.generate(settings.height_map_seed)
	return [_pack_height_map(full_height_map), full_height_map.connections()]


func _pack_height_map(height_map: HeightMap) -> VoxelMap:
	var voxel_map := VoxelMap.new(height_map.size())
	
	for i in height_map.buffer_size():
		var h := height_map.get_at_index(i)
		
		var packed_h = int(h * settings.map_scale)
		
		if packed_h < 0 or packed_h > settings.map_scale:
			Log.e("Invalid height: %d" % packed_h)
		
		voxel_map.set_at_index(i, packed_h)
	
	return voxel_map


func _on_AddMapButton_pressed():
	var map_position = Vector2.ZERO
	map_position.x = int(add_map_x.text)
	map_position.y = int(add_map_y.text)
	
	Systems.atlas.get_map_deferred(map_position, self, "_on_map_get")

	
