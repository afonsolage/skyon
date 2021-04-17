tool
extends Spatial

export(bool) var update := false setget _update
export(bool) var enabled := false

export(int) var extent := 128
export(float) var height_scale := 20.0
export(float) var unit_size := 1.0
export(float) var height_detail := 20.0

func _update(_v: bool) -> void:
	update = false

	if not enabled:
		return
	
	_generate()


func _ready() -> void:
	_generate()


func _generate() -> void:
	
	for i in get_child_count():
		var child := get_child(i)
		if not child or child.name == "Env":
			continue
		else:
			child.free()
	
	var height_map_generator = HeightMapGenerator.new()
	height_map_generator.size = extent
	height_map_generator.border_montains = true
	var height_map := height_map_generator.generate(0) as HeightMap
	
	var voxel_map := VoxelMap.new(height_map.size())
	
	for i in height_map.buffer_size():
		var h := height_map.get_at_index(i)
		
		var packed_h = int(h * height_detail) / height_detail
		
		if packed_h < 0 or packed_h > 1.0:
			Log.e("Invalid height: %d" % packed_h)
		
		height_map.set_at_index(i, packed_h)
		
	height_map.scale(height_scale)
	
	var vertices := _calc_height_map_vertices(height_map)
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
	
	var mesh_instance = MeshInstance.new()
	mesh_instance.name = "MeshInstance"
	mesh_instance.mesh = new_mesh
	mesh_instance.scale = Vector3(0.5, 0.5, 0.5)
	
	add_child(mesh_instance)
	if Engine.editor_hint:
		mesh_instance.owner = get_tree().edited_scene_root


func _calc_height_map_vertices(height_map: HeightMap) -> PoolVector3Array:
	var valid_rect := Rect2(0, 0, extent, extent)
	var planes := {}
	var vertices := PoolVector3Array()
	
	for i in height_map.buffer_size():
		var pos0 := height_map.calc_pos(i)
		if not valid_rect.has_point(pos0 + Vector2.ONE):
			continue
			
		var pos1 := Vector2(pos0.x + 1, pos0.y)
		var pos2 := Vector2(pos0.x + 1, pos0.y + 1)
		var pos3 := Vector2(pos0.x, pos0.y + 1)
		
		var h0 := height_map.get_at(pos0.x, pos0.y)
		var h1 := height_map.get_at(pos1.x, pos1.y)
		var h2 := height_map.get_at(pos2.x, pos2.y)
		var h3 := height_map.get_at(pos3.x, pos3.y)
		
		var plane = LowPolyPlane.new()
		plane.v0 = Vector3(pos0.x, h0, pos0.y)
		plane.v1 = Vector3(pos1.x, h1, pos1.y)
		plane.v2 = Vector3(pos2.x, h2, pos2.y)
		plane.v3 = Vector3(pos3.x, h3, pos3.y)
		
		planes[pos0] = plane
	
	var joined := {}
	for x in extent - 1:
		for z in extent - 1:
			var pos := Vector2(x, z)
			
			if joined.has(pos):
				continue

			var plane := planes[pos] as LowPolyPlane
			var end_z: int = z + 1

			while end_z < extent - 1:
				var next_pos := Vector2(x, end_z)
				var next_plane := planes[next_pos] as LowPolyPlane

				if not joined.has(next_pos) and next_plane.is_same_height(plane):
					end_z += 1
				else:
					break

			end_z -= 1

			var end_x = x
			var is_done := false
			while end_x < extent and not is_done:
				end_x += 1

				if end_x >= extent - 1:
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
	
	var factor := height_scale * float(color_pallet.size() - 1)
	var n := 0
	for _k in range(0, vertices.size(), 4):
		var v0 := vertices[n]
		var v1 := vertices[n + 1]
		var v2 := vertices[n + 2]
		var v3 := vertices[n + 3]
		
		var min_height := max(max(v0.y, v1.y), max(v2.y, v3.y))
		
		var color = color_pallet[int(float(min_height / height_scale) * (color_pallet.size() - 1))]
		
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
