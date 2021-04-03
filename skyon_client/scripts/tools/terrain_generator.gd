tool
class_name TerrainGenerator
extends Spatial

export(bool) var update := false setget set_update

export(bool) var is_generate_height_map := false
export(bool) var is_generate_terrain := true
export(bool) var is_merge_faces := true
export(bool) var is_generate_border := true
export(bool) var is_generate_places := true
export(bool) var is_connect_places := true
export(bool) var is_smooth_connection_border := true
export(bool) var is_normalize_height := true
export(bool) var is_generate_mesh_instance := true
export(bool) var is_generate_collisions := true
export(bool) var is_save_height_map := false

export(float) var map_scale := 10.0;
export(int) var size := 512
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

func _ready():
	generate()


func set_update(_value):
	update = false
	generate()

func generate():
	var height_map := PackedHeightMap.new(0)
	if is_generate_height_map:
		height_map = _create_height_map()
	else:
		height_map.load_from_resource("user://terrain.tmp")
	
	if is_save_height_map:
		height_map.save_to_resource("user://terrain.tmp")
	
	if is_generate_mesh_instance:
		var terrain := generate_mesh_instance_node(height_map)
		
		if self.has_node("Terrain"):
			self.get_node("Terrain").free()
			
		self.add_child(terrain)
		
		if Engine.editor_hint:
			terrain.owner = get_tree().get_edited_scene_root()
		

func generate_mesh_instance_node(height_map: PackedHeightMap) -> Terrain:
	var result := _generate_terrain_mesh(height_map)
	var mesh: Mesh = result[0]
	var collision_shape_faces: PoolVector3Array = result[1]
	
	var meshInstance := Terrain.new()
	meshInstance.mesh = mesh
	meshInstance.name = "Terrain"
	meshInstance.set_script(load("res://scripts/nodes/terrain.gd"))
	meshInstance.height_map = height_map

	if is_generate_collisions:
		var static_body = StaticBody.new()
		static_body.add_to_group("Terrain")
		meshInstance.add_child(static_body)
		
		if Engine.editor_hint:
			static_body.owner = get_tree().get_edited_scene_root()
		
		var concave_shape = ConcavePolygonShape.new()
		concave_shape.set_faces(collision_shape_faces)
		
		var collision_shape = CollisionShape.new()
		collision_shape.shape = concave_shape
		
		static_body.add_child(collision_shape)
		
		if Engine.editor_hint:
			collision_shape.owner = get_tree().get_edited_scene_root()
	
	return meshInstance

func _generate_terrain_mesh(height_map: PackedHeightMap) -> Array:
	print("Generating a new terrain mesh!")
	
	var planes := _create_planes(height_map)
	
	if is_merge_faces:
		_merge_faces(planes, height_map)
	
	var indexes := _create_indexes(planes)
	
	var mat := SpatialMaterial.new()
	mat.albedo_color = Color.white;
	mat.vertex_color_use_as_albedo = true
	
	var vertex_list = PoolVector3Array()
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	st.set_material(mat)

	for side in planes:
		var vertices: PoolVector3Array = planes[side]
		for i in range(0, vertices.size(), 4):
			var h = vertices[i].y - 1
			var c = height_colors[h]
			
			var normal := _get_side_normal(side)
			st.add_normal(normal)
			st.add_color(c)
			st.add_vertex(vertices[i])
			vertex_list.push_back(vertices[i])
			
			st.add_normal(normal)
			st.add_color(c)
			st.add_vertex(vertices[i + 1])
			vertex_list.push_back(vertices[i + 1])
			
			st.add_normal(normal)
			st.add_color(c)
			st.add_vertex(vertices[i + 2])
			vertex_list.push_back(vertices[i + 2])
			
			st.add_normal(normal)
			st.add_color(c)
			st.add_vertex(vertices[i + 3])
			vertex_list.push_back(vertices[i + 3])

	var collision_shape_faces := PoolVector3Array()
	for i in indexes:
		st.add_index(i)
		collision_shape_faces.push_back(vertex_list[i])


	var new_mesh = Mesh.new()
	var _res = st.commit(new_mesh)
	
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
	


func _create_planes(height_map: PackedHeightMap) -> Dictionary:
	
	var right := PoolVector3Array()
	var left := PoolVector3Array()
	var front := PoolVector3Array()
	var back := PoolVector3Array()

	for i in height_map.buffer_size():
		var h := int(height_map.get_at_index(i))
		var x = int(i / height_map.size())
		var z = int(i % height_map.size())
		
		right.append_array(_right_vertices(height_map, x, h, z))
		left.append_array(_left_vertices(height_map, x, h, z))
		front.append_array(_front_vertices(height_map, x, h, z))
		back.append_array(_back_vertices(height_map, x, h, z))
			
	return {
		"right": right,
		"front": front,
		"left": left,
		"back": back,
	}

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


func _left_vertices(height_map: PackedHeightMap, x: int, y: int, z: int) -> PoolVector3Array:
	var height_difference := _calc_height_difference("left", height_map, x, y, z)
	
	if height_difference > 0:
		return PoolVector3Array([
			_v1(x, y, z),
			_v3(x, y, z),
			_v7(x, y - height_difference + 1, z),
			_v5(x, y - height_difference + 1, z),
		])
	else:
		return PoolVector3Array()

func _right_vertices(height_map: PackedHeightMap, x: int, y: int, z: int) -> PoolVector3Array:
	var height_difference := _calc_height_difference("right", height_map, x, y, z)
	
	if height_difference > 0:
		return PoolVector3Array([
			_v4(x, y, z),
			_v2(x, y, z),
			_v6(x, y - height_difference + 1, z),
			_v8(x, y - height_difference + 1, z),
		])
	else:
		return PoolVector3Array()

func _front_vertices(height_map: PackedHeightMap, x: int, y: int, z: int) -> PoolVector3Array:
	var height_difference := _calc_height_difference("front", height_map, x, y, z)
	
	if height_difference > 0:
		return PoolVector3Array([
			_v3(x, y, z),
			_v4(x, y, z),
			_v8(x, y - height_difference + 1, z),
			_v7(x, y - height_difference + 1, z),
		])
	else:
		return PoolVector3Array()

func _back_vertices(height_map: PackedHeightMap, x: int, y: int, z: int) -> PoolVector3Array:
	var height_difference := _calc_height_difference("back", height_map, x, y, z)
	
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


func _calc_height_difference(side: String, height_map: PackedHeightMap, x: int, y: int, z: int) -> int:
	var normal := _get_side_normal(side)
	var next_idx := height_map.calc_index(int(normal.x) + x, int(normal.z) + z)
	
	if next_idx > 0 and next_idx < height_map.buffer_size():
		var previous_height := int(height_map.get_at_index(next_idx))
		if y > previous_height:
			return y - previous_height
			
	return 0


func _merge_faces(planes: Dictionary, height_map: PackedHeightMap) -> void:
	var merged := PoolByteArray()
	merged.resize(size * size)
	var merged_faces := PoolVector3Array()

	for i in merged.size():
		merged[i] = 0

	for x in size:
		for z in size:
			var pos := Vector2(x, z)

			if merged[height_map.calc_index(int(pos.x), int(pos.y))] == 1:
				continue

			var h := int(height_map.get_at(x, z))
			var origin_x = x
			var origin_z = z

			var end_z = z + 1
			while end_z < size:
				var npos := Vector2(origin_x, end_z)

				var nh := int(height_map.get_at(origin_x, end_z))

				if nh == h and merged[height_map.calc_index(int(npos.x), int(npos.y))] == 0:
					end_z += 1
				else:
					break

			end_z -= 1

			var end_x = origin_x
			var done := false
			while end_x < size and not done:
				end_x += 1
				
				if end_x >= size:
					break
				
				for tmp_z in range(origin_z, end_z + 1):
					var npos := Vector2(end_x, tmp_z)
					var nh := int(height_map.get_at(end_x, tmp_z))
					
					if nh == h and merged[height_map.calc_index(int(npos.x), int(npos.y))] == 0:
						tmp_z += 1
					else:
						done = true
						break

			end_x -= 1

			for wx in range(origin_x, end_x + 1):
				for wz in range(origin_z, end_z + 1):
					merged[height_map.calc_index(wx, wz)] = 1

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


func _create_height_map() -> PackedHeightMap:
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
	
	
	var full_height_map := height_map_generator.generate()
	return _pack_height_map(full_height_map)


func _pack_height_map(height_map: HeightMap) -> PackedHeightMap:
	var packed_height_map := PackedHeightMap.new(height_map.size())
	
	for i in height_map.buffer_size():
		var h := height_map.get_at_index(i)
		
		var packed_h = int(h * map_scale)
		
		if packed_h < 0 or packed_h > map_scale:
			Log.e("Invalid height: %d" % packed_h)
		
		packed_height_map.set_at_index(i, packed_h)
	
	return packed_height_map
