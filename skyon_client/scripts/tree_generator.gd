tool
extends Spatial

export(bool) var updated := false setget _generate
export(bool) var enabled := false

export(float) var trunk_size := 2.0
export(int) var trunk_segments := 4
export(float) var trunk_width := 0.5
export(Color) var trunk_color := Color.brown

export(Color) var leaves_color := Color.green
export(float) var leaves_scale := 1.0
export(Vector3) var leaves_noise := Vector3(0.5, 0.5, 0.5)

func _ready() -> void:
	_generate(true)


func _generate(_value) -> void:
	updated = false
	
	if not enabled:
		return
	
	for i in get_child_count():
		var child := get_child(i)
		if child.name.begins_with("Trunk") or child.name.begins_with("Leaves"):
			child.queue_free()
	
	var b4 = OS.get_ticks_usec()
	var mesh_instance := generate_trunk()
	mesh_instance.name = "Trunk"
	
	add_child(mesh_instance)
	mesh_instance.owner = get_tree().edited_scene_root
	
	var after = OS.get_ticks_usec()
	Log.d("Trunk Took: %d" % [after - b4])
	
	b4 = OS.get_ticks_usec()
	
	leaves_scale = rand_range(0.5, 1.5)
	
	mesh_instance = generate_leaves()
	mesh_instance.name = "Leaves"
	mesh_instance.translation.y = trunk_size + leaves_scale
	
	add_child(mesh_instance)
	mesh_instance.owner = get_tree().edited_scene_root
	after = OS.get_ticks_usec()
	Log.d("Leaves Took: %d" % [after - b4])


func generate_trunk() -> MeshInstance:
	var mesh_instance = MeshInstance.new()
	
	var vertices := PoolVector3Array()
	var normals := PoolVector3Array()
	var indices := PoolIntArray()
	
	var segments_offset := PoolVector3Array()
	for i in range(0, trunk_segments + 1, 1):
		var x := rand_range(0, trunk_width) - trunk_width / 2.0;
		var y := rand_range(0, trunk_width) - trunk_width / 2.0;
		var z := rand_range(0, trunk_width) - trunk_width / 2.0;

		segments_offset.push_back(Vector3(x, y, z))
	
	var origin := -trunk_width / 2.0
	var segment_size := trunk_size / float(trunk_segments)
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
	
	var new_mesh = ArrayMesh.new()
	new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	new_mesh.surface_set_material(0, mat)
	
	mesh_instance.mesh = new_mesh
	
	return mesh_instance


func generate_leaves() -> MeshInstance:
	var mesh_instance = MeshInstance.new()
	
	var vertices := _create_iconsphere()
	var indices := PoolIntArray()
	var normals := PoolVector3Array()
	
	for i in vertices.size():
		indices.push_back(i)
	
	for i in range(0, indices.size(), 3):
		var a := vertices[indices[i]]
		var b := vertices[indices[i + 1]]
		var c := vertices[indices[i + 2]]
		var normal := (b - a).cross(c - a)
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
	
	var new_mesh = ArrayMesh.new()
	new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	new_mesh.surface_set_material(0, mat)
	
	mesh_instance.mesh = new_mesh
	
	return mesh_instance


func _get_noise_vector3(bottom: bool = false) -> Vector3:
	return Vector3(
		rand_range(-leaves_noise.x, leaves_noise.x),
		# Forces leaves to grow up
		rand_range(-leaves_noise.y / (1.0 if not bottom else 10.0), leaves_noise.y),
		rand_range(-leaves_noise.z, leaves_noise.z)
	)


func _create_iconsphere() -> PoolVector3Array:
	var vertices := PoolVector3Array()
	var t := (1.0 + sqrt(5.0)) / 2.0
	
	var baseVertices := PoolVector3Array([
		(Vector3(-1, t, 0) + _get_noise_vector3()) * leaves_scale,
		(Vector3(1, t, 0) + _get_noise_vector3()) * leaves_scale,
		(Vector3(-1, -t, 0) + _get_noise_vector3(true)) * leaves_scale,
		(Vector3(1, -t, 0) + _get_noise_vector3(true)) * leaves_scale,
		
		(Vector3(0, -1, t) + _get_noise_vector3(true)) * leaves_scale,
		(Vector3(0, 1, t) + _get_noise_vector3()) * leaves_scale,
		(Vector3(0, -1, -t) + _get_noise_vector3(true)) * leaves_scale,
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
		vertices.push_back(baseVertices[i])
	
	return vertices


func _v0(y: int) -> Vector3:
	return Vector3(0, y, 0)


func _v1(y: int) -> Vector3:
	return Vector3(trunk_width, y, 0)


func _v2(y: int) -> Vector3:
	return Vector3(0, y, trunk_width)


func _v3(y: int) -> Vector3:
	return Vector3(trunk_width, y, trunk_width)
