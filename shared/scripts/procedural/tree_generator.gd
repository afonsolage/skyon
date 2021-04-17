class_name TreeGenerator

const VERTEX_PER_SQUARE = 4
const VERTEX_PER_SEGMENT = 16

export(float) var trunk_height_base := 5.0
export(float) var trunk_height_variation := 1.0
export(int) var trunk_segments := 5
export(float) var trunk_width := 0.5
export(Color) var trunk_color := Color.brown
export(float) var trunk_base_scale := 1.0
export(float) var trunk_thickness := 5

export(Color) var leaves_color := Color.green
export(Vector3) var leaves_noise := Vector3(0.2, 0.2, 0.2)
export(float) var leaves_scale_base := 3
export(float) var leaves_scale_variation := 0.5
export(int) var leaves_subdivide_level := 1

var _rnd := RandomNumberGenerator.new()
var trunk_height := 0.0
var leaves_scale := 0.0


func generate_tree(is_collision_only: bool = false ) -> Array:
	trunk_height = trunk_height_base + _rnd.randf_range(-trunk_height_variation, trunk_height_variation)
	leaves_scale = leaves_scale_base + _rnd.randf_range(-leaves_scale_variation, leaves_scale_variation)
	trunk_base_scale = trunk_height * 0.1
	trunk_thickness = _rnd.randf_range(2, 4)
	
	var trunk = _generate_trunk(is_collision_only)
	var leaves: Mesh
	if not is_collision_only:
		leaves = _generate_leaves()
	
	return [trunk[0], trunk[1], leaves]


func _generate_trunk(is_collision_only: bool) -> Array:
	var new_mesh = ArrayMesh.new()
	var vertices := PoolVector3Array()
	
	if not is_collision_only:
		var normals := PoolVector3Array()
		var indices := PoolIntArray()
		
		var segments_offset := PoolVector3Array()
		for _i in range(0, trunk_segments + 1, 1):
			var x := _rnd.randf_range(-trunk_width / 4.0, trunk_width / 4.0);
			var y := _rnd.randf_range(-trunk_width / 4.0, trunk_width / 4.0);
			var z := _rnd.randf_range(-trunk_width / 4.0, trunk_width / 4.0);

			segments_offset.push_back(Vector3(x, y, z))
		
		var origin := -trunk_width / 2.0
		var segment_size := trunk_height / float(trunk_segments)
		for i in trunk_segments:
			var y = segment_size * i
			var y1 = y + segment_size
			
			var y_offset = segments_offset[i] if i > 0 else Vector3.ZERO
			var y1_offset = segments_offset[i + 1]
			
			# Back
			vertices.push_back(Vector3(origin, y, origin) + y_offset)
			vertices.push_back(Vector3(trunk_width, y, origin) + y_offset)
			vertices.push_back(Vector3(trunk_width, y1, origin) + y1_offset)
			vertices.push_back(Vector3(origin, y1, origin) + y1_offset)
			
			normals.push_back(Vector3.BACK)
			normals.push_back(Vector3.BACK)
			normals.push_back(Vector3.BACK)
			normals.push_back(Vector3.BACK)
			
			# Front
			vertices.push_back(Vector3(trunk_width, y, trunk_width) + y_offset)
			vertices.push_back(Vector3(origin, y, trunk_width) + y_offset)
			vertices.push_back(Vector3(origin, y1, trunk_width) + y1_offset)
			vertices.push_back(Vector3(trunk_width, y1, trunk_width) + y1_offset)

			normals.push_back(Vector3.FORWARD)
			normals.push_back(Vector3.FORWARD)
			normals.push_back(Vector3.FORWARD)
			normals.push_back(Vector3.FORWARD)

			# Right
			vertices.push_back(Vector3(trunk_width, y, origin) + y_offset)
			vertices.push_back(Vector3(trunk_width, y, trunk_width) + y_offset)
			vertices.push_back(Vector3(trunk_width, y1, trunk_width) + y1_offset)
			vertices.push_back(Vector3(trunk_width, y1, origin) + y1_offset)

			normals.push_back(Vector3.RIGHT)
			normals.push_back(Vector3.RIGHT)
			normals.push_back(Vector3.RIGHT)
			normals.push_back(Vector3.RIGHT)

			# Left
			vertices.push_back(Vector3(origin, y, trunk_width) + y_offset)
			vertices.push_back(Vector3(origin, y, origin) + y_offset)
			vertices.push_back(Vector3(origin, y1, origin) + y1_offset)
			vertices.push_back(Vector3(origin, y1, trunk_width) + y1_offset)

			normals.push_back(Vector3.LEFT)
			normals.push_back(Vector3.LEFT)
			normals.push_back(Vector3.LEFT)
			normals.push_back(Vector3.LEFT)
		
		var center := Vector3(-origin / 2.0, 0, -origin / 2.0)
		for i in range(0, vertices.size(), VERTEX_PER_SQUARE):
	# warning-ignore:integer_division
			var current_segment := i / VERTEX_PER_SEGMENT
			var rate := clamp((trunk_segments - (current_segment * trunk_thickness)) / float(trunk_segments), 0.0, 1.0)
			var segment_center := Vector3(center.x, vertices[i].y, center.z)
			
			vertices[i] = vertices[i] + ((vertices[i] - segment_center).normalized() * rate * trunk_base_scale)
			vertices[i + 1] = vertices[i + 1] + ((vertices[i + 1] - segment_center).normalized() * rate* trunk_base_scale)
			
			if i + VERTEX_PER_SEGMENT < vertices.size():
				var next_segment := current_segment + 1
				var next_rate := clamp((trunk_segments - (next_segment * trunk_thickness)) / float(trunk_segments), 0.0, 1.0)
				var next_segment_center := Vector3(center.x, vertices[i + 16].y, center.z)
				vertices[i + 2] = vertices[i + 2] + ((vertices[i + 2] - next_segment_center).normalized() * next_rate * trunk_base_scale)
				vertices[i + 3] = vertices[i + 3] + ((vertices[i + 3] - next_segment_center).normalized() * next_rate * trunk_base_scale)
		
		var n := 0
		for _k in range(0, vertices.size(), 4):
			indices.push_back(n)
			indices.push_back(n + 1)
			indices.push_back(n + 3)

			indices.push_back(n + 1)
			indices.push_back(n + 2)
			indices.push_back(n + 3)
			
			n += 4
		
		var arrays = []
		arrays.resize(ArrayMesh.ARRAY_MAX)
		arrays[ArrayMesh.ARRAY_VERTEX] = vertices
		arrays[ArrayMesh.ARRAY_NORMAL] = normals
		arrays[ArrayMesh.ARRAY_INDEX] = indices
		
		var mat := SpatialMaterial.new()
		mat.albedo_color = trunk_color;
		mat.vertex_color_use_as_albedo = true
		
		new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		new_mesh.surface_set_material(0, mat)
	
	var collision := PoolVector3Array()
	collision = vertices
	
	return [collision, new_mesh]


func _generate_leaves() -> Mesh:
	var new_mesh = ArrayMesh.new()
	var vertices := _create_icosphere()
	
	var indices := PoolIntArray()
	var normals := PoolVector3Array()
	
	for i in vertices.size():
		indices.push_back(i)
	
	for i in range(0, indices.size(), 3):
		var a := vertices[indices[i]]
		var b := vertices[indices[i + 1]]
		var c := vertices[indices[i + 2]]
		var normal := (c - a).cross(b - a).normalized()
		
		normals.push_back(normal)
		normals.push_back(normal)
		normals.push_back(normal)
		
	
	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = vertices
	arrays[ArrayMesh.ARRAY_NORMAL] = normals
	arrays[ArrayMesh.ARRAY_INDEX] = indices
	
	var mat := SpatialMaterial.new()
	mat.albedo_color = leaves_color;
	mat.vertex_color_use_as_albedo = true
	
	new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	new_mesh.surface_set_material(0, mat)
	
	return new_mesh


func _get_noise_vector3() -> Vector3:
	return Vector3(
		_rnd.randf_range(-leaves_noise.x, leaves_noise.x),
		_rnd.randf_range(-leaves_noise.y, leaves_noise.y),
		_rnd.randf_range(-leaves_noise.z, leaves_noise.z)
	)


func _create_icosphere() -> PoolVector3Array:
	var vertices := PoolVector3Array()
	var t := (1.0 + sqrt(5.0)) / 2.0
	
	var base_vertices := PoolVector3Array([
		(Vector3(-1, t, 0) + _get_noise_vector3()) * leaves_scale,
		(Vector3(1, t, 0) + _get_noise_vector3()) * leaves_scale,
		(Vector3(-1, -t, 0) + _get_noise_vector3()) * leaves_scale,
		(Vector3(1, -t, 0) + _get_noise_vector3()) * leaves_scale,
		
		(Vector3(0, -1, t) + _get_noise_vector3()) * leaves_scale,
		(Vector3(0, 1, t) + _get_noise_vector3()) * leaves_scale,
		(Vector3(0, -1, -t) + _get_noise_vector3()) * leaves_scale,
		(Vector3(0, 1, -t) + _get_noise_vector3()) * leaves_scale,
		
		(Vector3(t, 0, -1) + _get_noise_vector3()) * leaves_scale,
		(Vector3(t, 0, 1) + _get_noise_vector3()) * leaves_scale,
		(Vector3(-t, 0, -1) + _get_noise_vector3()) * leaves_scale,
		(Vector3(-t, 0, 1) + _get_noise_vector3()) * leaves_scale,
	])
	
	var indices := PoolIntArray([
		5, 11, 0,
		1, 5, 0,
		7, 1, 0,
		10, 7, 0,
		11, 10, 0,
		
		9, 5, 1,
		4, 11, 5,
		2, 10, 11,
		6, 7, 10,
		8, 1, 7,
		
		4, 9, 3,
		2, 4, 3,
		6, 2, 3,
		8, 6, 3,
		9, 8, 3,
		
		5, 9, 4,
		11, 4, 2,
		10, 2, 6,
		7, 6, 8,
		1, 8, 9,
	])
		
	for i in indices:
		vertices.push_back(base_vertices[i])
	
	for i in leaves_subdivide_level:
		var sub_indices := PoolIntArray()
		var sub_vertices := PoolVector3Array()
		
		var n := 0
		for k in range(0, vertices.size(), 3):
			var v0 := vertices[k]
			var v1 := vertices[k + 1]
			var v2 := vertices[k + 2]
			
			var s0 := (v0 + v1) / 2.0
			var s1 := (v2 + v1) / 2.0
			var s2 := (v0 + v2) / 2.0
			
			sub_vertices.push_back(v0)
			sub_vertices.push_back(s0)
			sub_vertices.push_back(s2)
			
			sub_vertices.push_back(s0)
			sub_vertices.push_back(v1)
			sub_vertices.push_back(s1)
			
			sub_vertices.push_back(s0)
			sub_vertices.push_back(s1)
			sub_vertices.push_back(s2)
			
			sub_vertices.push_back(s2)
			sub_vertices.push_back(s1)
			sub_vertices.push_back(v2)
			
			for j in 12:
				sub_indices.push_back(n)
				n += 1
		
		vertices = sub_vertices
		indices = sub_indices

	for i in vertices.size():
		vertices[i] = vertices[i].normalized()
	
	return vertices


func _v0(y: int) -> Vector3:
	return Vector3(0, y, 0)


func _v1(y: int) -> Vector3:
	return Vector3(trunk_width, y, 0)


func _v2(y: int) -> Vector3:
	return Vector3(0, y, trunk_width)


func _v3(y: int) -> Vector3:
	return Vector3(trunk_width, y, trunk_width)
