class_name LowPolyGenerator

export(Resource) var settings := TerrainGenerationSettings.new() as Resource

func generate_height_map() -> Array:
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
	
	var full_height_map := height_map_generator.generate(settings.seed_number)
	return [_pack_height_map(full_height_map), full_height_map.connections()]


func generate_terrain_mesh(low_poly_map: LowPolyMap, collisions: bool = true) -> Array:
	Log.d("Generating a new terrain mesh!")
	
	var vertices := _calc_height_map_vertices(low_poly_map)
	var normals := _calc_normals(vertices)
	var indices := _calc_indices(vertices)
	var colors := _calc_colors(vertices)
	
	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = vertices
	arrays[ArrayMesh.ARRAY_NORMAL] = normals
	arrays[ArrayMesh.ARRAY_INDEX] = indices
	arrays[ArrayMesh.ARRAY_COLOR] = colors
	
	var mat := SpatialMaterial.new()
	mat.vertex_color_use_as_albedo = true
	
	var new_mesh = ArrayMesh.new()
	new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	new_mesh.surface_set_material(0, mat)
	
	var collision_shape_faces := PoolVector3Array()
	if collisions:
		collision_shape_faces.resize(indices.size())
		for i in indices:
			collision_shape_faces.push_back(vertices[i])
	
	return [new_mesh, collision_shape_faces]


func generate_collisions_mesh(low_poly_map: LowPolyMap) -> PoolVector3Array:
	var vertices := _calc_height_map_vertices(low_poly_map)
	var indices := _calc_indices(vertices)
	
	var collision_shape_faces := PoolVector3Array()
	for i in indices:
		collision_shape_faces.push_back(vertices[i])
	
	return collision_shape_faces


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


func _pack_height_map(height_map: HeightMap) -> LowPolyMap:
	var low_poly_map := LowPolyMap.new(height_map.size())
	
	for i in height_map.buffer_size():
		var h := height_map.get_at_index(i)
		
		var packed_h = int(h * settings.map_scale)
		
		if packed_h < 0 or packed_h > settings.map_scale:
			Log.e("Invalid height: %d" % packed_h)
		
		low_poly_map.set_at_index(i, packed_h)
	
	return low_poly_map


func _calc_height_map_vertices(height_map: LowPolyMap) -> PoolVector3Array:
	var valid_rect := Rect2(0, 0, settings.size, settings.size)
	var planes := {}
	var vertices := PoolVector3Array()
	
	for i in height_map.buffer_size():
		var pos0 := height_map.calc_pos(i)
		if not valid_rect.has_point(pos0 + Vector2.ONE):
			continue
			
		var pos1 := Vector2(pos0.x + 1, pos0.y)
		var pos2 := Vector2(pos0.x + 1, pos0.y + 1)
		var pos3 := Vector2(pos0.x, pos0.y + 1)
		
		var h0 := height_map.get_at(int(pos0.x), int(pos0.y))
		var h1 := height_map.get_at(int(pos1.x), int(pos1.y))
		var h2 := height_map.get_at(int(pos2.x), int(pos2.y))
		var h3 := height_map.get_at(int(pos3.x), int(pos3.y))
		
		var plane = LowPolyPlane.new()
		plane.v0 = Vector3(pos0.x, h0, pos0.y)
		plane.v1 = Vector3(pos1.x, h1, pos1.y)
		plane.v2 = Vector3(pos2.x, h2, pos2.y)
		plane.v3 = Vector3(pos3.x, h3, pos3.y)
		
		planes[pos0] = plane
	
	var joined := {}
	for x in settings.size - 1:
		for z in settings.size - 1:
			var pos := Vector2(x, z)
			
			if joined.has(pos):
				continue

			var plane := planes[pos] as LowPolyPlane
			var end_z: int = z + 1

			while end_z < settings.size - 1:
				var next_pos := Vector2(x, end_z)
				var next_plane := planes[next_pos] as LowPolyPlane

				if not joined.has(next_pos) and next_plane.is_same_height(plane):
					end_z += 1
				else:
					break

			end_z -= 1

			var end_x = x
			var is_done := false
			while end_x < settings.size and not is_done:
				end_x += 1

				if end_x >= settings.size - 1:
					break

				for tmp_z in range(z, end_z + 1):
					var next_pos := Vector2(end_x, tmp_z)
					var next_plane := planes[next_pos] as LowPolyPlane

					if not joined.has(next_pos) and next_plane.is_same_height(plane):
						tmp_z += 1
					else:
						is_done = true
						break

			end_x -= 1
			for jx in range(x, end_x + 1):
				for jz in range(z, end_z + 1):
					joined[Vector2(jx, jz)] = null

			plane.v1.x = end_x + 1
			plane.v2.x = end_x + 1
			plane.v2.z = end_z + 1
			plane.v3.z = end_z + 1
			
			vertices.push_back(plane.v0)
			vertices.push_back(plane.v1)
			vertices.push_back(plane.v2)
			vertices.push_back(plane.v3)
	
	return vertices


func _calc_normals(vertices: PoolVector3Array) -> PoolVector3Array:
	var normals := PoolVector3Array()
	
	var n := 0
	for _k in range(0, vertices.size(), 4):
		var v0 := vertices[n]
		var v1 := vertices[n + 1]
		var v3 := vertices[n + 3]
		
		var normal = (v3 - v0).cross(v1 - v0).normalized()
		
		normals.push_back(normal)
		normals.push_back(normal)
		normals.push_back(normal)
		normals.push_back(normal)
		
		n += 4
		
	return normals


func _calc_indices(vertices: PoolVector3Array) -> PoolIntArray:
	var indices := PoolIntArray()
	
	var n := 0
	for _k in range(0, vertices.size(), 4):
		indices.push_back(n)
		indices.push_back(n + 1)
		indices.push_back(n + 2)

		indices.push_back(n)
		indices.push_back(n + 2)
		indices.push_back(n + 3)
		
		n += 4
		
	
	return indices


func _calc_colors(vertices: PoolVector3Array) -> PoolColorArray:
	var colors := PoolColorArray()
	var color_pallet = [
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
	
	var n := 0
	for _k in range(0, vertices.size(), 4):
		var v0 := vertices[n]
		var v1 := vertices[n + 1]
		var v2 := vertices[n + 2]
		var v3 := vertices[n + 3]
		
		var min_height := max(max(v0.y, v1.y), max(v2.y, v3.y))
		
		var color = color_pallet[int(float(min_height / settings.map_scale) * (color_pallet.size() - 1))]
		
		colors.push_back(color)
		colors.push_back(color)
		colors.push_back(color)
		colors.push_back(color)
		
		n += 4
	
	return colors


class LowPolyPlane:
	var v0: Vector3
	var v1: Vector3
	var v2: Vector3
	var v3: Vector3
	
	func is_same_height(other: LowPolyPlane) -> bool:
		return is_equal_approx(v0.y, other.v0.y) \
				and is_equal_approx(v1.y, other.v1.y) \
				and is_equal_approx(v2.y, other.v2.y) \
				and is_equal_approx(v3.y, other.v3.y) \
	
	
	func join(other: LowPolyPlane) -> void:
		if other.v0 < v0:
			v0 = other.v0
		
		if other.v1 < v1:
			v1 = other.v1
		
		if other.v2 > v2:
			v2 = other.v2
		
		if other.v3 > v3:
			v3 = other.v3
