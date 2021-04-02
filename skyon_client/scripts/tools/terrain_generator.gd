tool
extends Spatial

export(bool) var update := false setget set_update

export(bool) var is_generate_terrain := false
export(bool) var is_generate_border := true
export(bool) var is_generate_places := true
export(bool) var is_connect_places := true
export(bool) var is_smooth_connection_border := true
export(bool) var is_normalize_height := true

export(float) var map_scale := 10.0;
export(int) var size := 256
export(int) var octaves := 5
export(float) var persistance := 0.2
export(float) var period := 20.0
export(int) var border_size := 30
export(float) var border_thickness := 0.05
export(bool) var border_montains := true
export(int) var border_connection_size := 8
export(int) var places_count := 5
export(int) var places_path_noise_rate := 40
export(int) var places_path_thickness := 5
export(Array, Color) var height_colors := []

export(bool) var disable_randomness := false


func set_update(_value):
	update = false
	
	if not is_generate_terrain:
		return
	
	if self.get_child_count() > 0:
		self.get_child(0).queue_free()
	
	var result := _generate_terrain_mesh()
	var mesh : Mesh = result[0]
	var height_map : HeightMap = result[1]
	
	var meshInstance := Terrain.new()
	meshInstance.mesh = mesh
	meshInstance.name = "Terrain"
	meshInstance.set_script(load("res://scripts/nodes/terrain.gd"))
	meshInstance.height_map = height_map
	
#	height_map.save_to_resource("user://terrain.tmp")
	
	self.add_child(meshInstance)
	meshInstance.owner = get_tree().get_edited_scene_root()
#
#	meshInstance.create_trimesh_collision()
#	meshInstance.get_child(0).name = "StaticBody"
	
#	var navigation = Navigation.new()
#
#	var mesh = _generate_terrain_mesh()
#
#	var meshInstance := MeshInstance.new()
#	meshInstance.mesh = mesh
#
#	var navMesh := NavigationMesh.new()
#
#	var navMeshInstance := NavigationMeshInstance.new()
#	navMeshInstance.navmesh = navMesh
#
#	self.add_child(navigation)
#	navigation.owner = get_tree().get_edited_scene_root()
#
#	navigation.add_child(navMeshInstance)
#	navMeshInstance.owner = get_tree().get_edited_scene_root()
#
#	navMeshInstance.add_child(meshInstance)
#	meshInstance.owner = get_tree().get_edited_scene_root()
#
#	meshInstance.create_trimesh_collision()
#
#	navMesh.create_from_mesh(mesh)
	

func _generate_terrain_mesh() -> Array:
	print("Generating a new terrain mesh!")
	
	var height_map := _create_height_map()
	_normalize_height_map(height_map)
	
	var new_mesh = Mesh.new()
	var planes := _create_planes(height_map)
	var indexes := _create_indexes(planes)
	
	var mat := SpatialMaterial.new()
	mat.albedo_color = Color.white;
	mat.vertex_color_use_as_albedo = true
	
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	st.set_material(mat)

	for side in planes.vertices:
		var vertices: Dictionary = planes.vertices[side]
		for pos in vertices:
			var c = planes.colors[pos]
			var vertices_arr = vertices[pos]
			
			var normal := _get_side_normal(side)
			st.add_normal(normal)
			st.add_color(c)
			st.add_vertex(vertices_arr[0])
			
			st.add_normal(normal)
			st.add_color(c)
			st.add_vertex(vertices_arr[1])
			
			st.add_normal(normal)
			st.add_color(c)
			st.add_vertex(vertices_arr[2])
			
			st.add_normal(normal)
			st.add_color(c)
			st.add_vertex(vertices_arr[3])

	for i in indexes:
		st.add_index(i)

	var _res = st.commit(new_mesh)
	
	return [new_mesh, height_map]


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
	


func _create_planes(height_map: HeightMap) -> Dictionary:
	var planes := {
		"vertices": {
			"top": {},
			"right": {},
			"front": {},
			"left": {},
			"back": {}
		},
		"colors": {},
	}

	for x in size:
		for z in size:
			var h := int(height_map.get_at(x, z))
			var pos = Vector2(x, z)
			planes.vertices.top[pos] = _top_vertices(x, h, z)
			planes.vertices.right[pos] = _right_vertices(height_map, x, h, z)
			planes.vertices.front[pos] = _front_vertices(height_map, x, h, z)
			planes.vertices.left[pos] = _left_vertices(height_map, x, h, z)
			planes.vertices.back[pos] = _back_vertices(height_map, x, h, z)
			
			planes.colors[pos] = height_colors[h] as Color
			
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


func _calc_height_difference(side: String, height_map: HeightMap, x: int, y: int, z: int) -> int:
	var normal = _get_side_normal(side)
	var previous_pos = Vector2(x + normal.x, z + normal.z)
	
	if height_map.is_pos_valid(previous_pos):
		var previous_height = height_map.get_at(previous_pos.x, previous_pos.y)
		if y > previous_height + 1:
			return int(y - previous_height - 1)
			
	return 0


func _left_vertices(height_map: HeightMap, x: int, y: int, z: int) -> Array:
	var height_difference := _calc_height_difference("left", height_map, x, y, z)
	
	return [
		_v1(x, y, z),
		_v3(x, y, z),
		_v7(x, y - height_difference, z),
		_v5(x, y - height_difference, z),
	]


func _right_vertices(height_map: HeightMap, x: int, y: int, z: int) -> Array:
	var height_difference := _calc_height_difference("right", height_map, x, y, z)
	
	return [
		_v2(x, y, z),
		_v6(x, y - height_difference, z),
		_v8(x, y - height_difference, z),
		_v4(x, y, z),
	]


func _front_vertices(height_map: HeightMap, x: int, y: int, z: int) -> Array:
	var height_difference := _calc_height_difference("front", height_map, x, y, z)
	
	return [
		_v3(x, y, z),
		_v4(x, y, z),
		_v8(x, y - height_difference, z),
		_v7(x, y - height_difference, z),
	]


func _back_vertices(height_map: HeightMap, x: int, y: int, z: int) -> Array:
	var height_difference := _calc_height_difference("back", height_map, x, y, z)
	
	return [
		_v1(x, y, z),
		_v5(x, y - height_difference, z),
		_v6(x, y - height_difference, z),
		_v2(x, y, z),
	]


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


func _create_indexes(planes: Dictionary) -> PoolIntArray:
	var indexes := PoolIntArray()

	var i := 0
	for vertices in planes.vertices.values():
		for _i in vertices.size():
			indexes.push_back(i)
			indexes.push_back(i + 1)
			indexes.push_back(i + 3)

			indexes.push_back(i + 1)
			indexes.push_back(i + 2)
			indexes.push_back(i + 3)
			
			i += 4
	
	return indexes


func _create_height_map() -> HeightMap:
	var height_map_generator := HeightMapGenerator.new()
	
	height_map_generator.is_generate_terrain = is_generate_terrain
	height_map_generator.is_generate_border = is_generate_border
	height_map_generator.is_generate_places = is_generate_places
	height_map_generator.is_connect_places = is_connect_places
	height_map_generator.is_smooth_connection_border = is_smooth_connection_border
	height_map_generator.is_normalize_height = is_normalize_height

	height_map_generator.size = size
	height_map_generator.octaves = octaves
	height_map_generator.persistance = persistance
	height_map_generator.period = period
	height_map_generator.border_size = border_size
	height_map_generator.border_thickness = border_thickness
	height_map_generator.border_montains = border_montains
	height_map_generator.border_connection_size = border_connection_size
	height_map_generator.places_count = places_count
	height_map_generator.places_path_noise_rate = places_path_noise_rate
	height_map_generator.places_path_thickness = places_path_thickness

	height_map_generator.disable_randomness = disable_randomness
	
	
	var height_map := height_map_generator.generate()
	return height_map


func _normalize_height_map(height_map: HeightMap) -> void:
	for i in height_map.buffer_size():
		var h := height_map.get_at_index(i)
		
		h = int(h * map_scale)
		
		if h < 0 or h > map_scale:
			Log.e("Invalid height: %d" % h)
		
		height_map.set_at_index(i, h)
	
	for i in height_map.buffer_size():
		var h := height_map.get_at_index(i)
		
		if h < 0 or h > map_scale:
			push_error("Invalid height: %d" % h)


func _get_at(arr: PoolVector3Array, x: int, z: int) -> Vector3:
	var sz := int(sqrt(arr.size()))
	
	return arr[x * sz + z]


func _calc_idx(sz: int, x: int, z: int) -> int:
	return x * sz + z
