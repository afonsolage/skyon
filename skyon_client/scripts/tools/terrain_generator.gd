tool
extends Spatial

export(bool) var update := false setget set_update

export(bool) var is_generate_terrain := true
export(bool) var is_generate_border := true
export(bool) var is_generate_places := true
export(bool) var is_connect_places := true
export(bool) var is_smooth_connection_border := true
export(bool) var is_normalize_height := true

export(float) var map_scale := 100.0;
export(int) var size := 256
export(int) var octaves := 2
export(float) var persistance := 0.3
export(float) var period := 20.0
export(int) var border_size := 30
export(float) var border_thickness := 0.05
export(bool) var border_montains := false
export(int) var border_connection_size := 8
export(int) var places_count := 5
export(int) var places_path_noise_rate := 40
export(int) var places_path_thickness := 5

export(bool) var disable_randomness := false


func set_update(value):
	update = false
	self.remove_child(self.get_child(0))
	
	var result := _generate_terrain_mesh()
	var mesh : Mesh = result[0]
	var height_map : HeightMap = result[1]
	
	var meshInstance := Terrain.new()
	meshInstance.mesh = mesh
	meshInstance.name = "Terrain"
	meshInstance.set_script(load("res://scripts/nodes/terrain.gd"))
	meshInstance.height_map = height_map
	
	height_map.save_to_resource("user://terrain.tmp")
	
	self.add_child(meshInstance)
	meshInstance.owner = get_tree().get_edited_scene_root()
	
	meshInstance.create_trimesh_collision()
	meshInstance.get_child(0).name = "StaticBody"
	
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
	height_map.scale(map_scale)
	
	var new_mesh = Mesh.new()
	var planes := _create_planes(height_map)
	
	_create_colors(planes)
	var indexes := _create_indexes(planes)
	
	var mat := SpatialMaterial.new()
	mat.albedo_color = Color.white;
	mat.vertex_color_use_as_albedo = true
	
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	st.set_material(mat)

	for side in planes:
		var planes_side : Dictionary = planes[side]
		for plane in planes_side.values():
			var normal := _get_side_normal(side)
			st.add_normal(normal)
			st.add_color(plane.c)
			st.add_vertex(plane.v1)
			
			st.add_normal(normal)
			st.add_color(plane.c)
			st.add_vertex(plane.v2)
			
			st.add_normal(normal)
			st.add_color(plane.c)
			st.add_vertex(plane.v3)
			
			st.add_normal(normal)
			st.add_color(plane.c)
			st.add_vertex(plane.v4)

	for i in indexes:
		st.add_index(i)

	st.commit(new_mesh)
	
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
	var planes := {}

	planes.top = _create_top_planes(height_map)
	planes.right = _create_right_planes(height_map)
	planes.left = _create_left_planes(height_map)
	planes.front = _create_front_planes(height_map)
	planes.back = _create_back_planes(height_map)

	return planes


func _create_top_planes(height_map: HeightMap) -> Dictionary:
	var planes := {}
	
	for x in size:
		for z in size:
			var h := height_map.get_at(x, z) + 1
			planes[Vector2(x, z)] = {
				"v1": Vector3(x, h, z),
				"v2": Vector3(x + 1, h, z),
				"v3": Vector3(x + 1, h, z + 1),
				"v4": Vector3(x, h, z + 1),
			}
	
	return planes


func _create_right_planes(height_map: HeightMap) -> Dictionary:
	var planes := {}
	
	for x in size:
		for z in size - 1:
			var h1 := height_map.get_at(x, z)
			var h2 := height_map.get_at(x, z + 1)
			
			if (h1 > h2):
				var h := h1 - h2
				h1 += 1
				planes[Vector2(x, z)] = {
					"v1": Vector3(x, h1, z + 1),
					"v2": Vector3(x + 1, h1, z + 1),
					"v3": Vector3(x + 1, h1 - h, z + 1),
					"v4": Vector3(x, h1 - h, z + 1),
				}
	
	return planes


func _create_left_planes(height_map: HeightMap) -> Dictionary:
	var planes := {}
	
	for x in size:
		for z in range(size - 1, 0, - 1):
			var h1 := height_map.get_at(x, z)
			var h2 := height_map.get_at(x, z - 1)
			
			if (h1 > h2):
				var h := h1 - h2
				h1 += 1
				planes[Vector2(x, z)] = {
					"v1": Vector3(x, h1, z),
					"v2": Vector3(x, h1 - h, z),
					"v3": Vector3(x + 1, h1 - h, z),
					"v4": Vector3(x + 1, h1, z),
				}
	
	return planes


func _create_front_planes(height_map: HeightMap) -> Dictionary:
	var planes := {}
	
	for x in size - 1:
		for z in size:
			var h1 := height_map.get_at(x, z)
			var h2 := height_map.get_at(x + 1, z)
			
			if (h1 > h2):
				var h := h1 - h2
				h1 += 1
				planes[Vector2(x, z)] = {
					"v1": Vector3(x + 1, h1, z),
					"v2": Vector3(x + 1, h1 - h, z),
					"v3": Vector3(x + 1, h1 - h, z + 1),
					"v4": Vector3(x + 1, h1, z + 1),
				}
	
	return planes


func _create_back_planes(height_map: HeightMap) -> Dictionary:
	var planes := {}
	
	for x in range(size - 1 , 0, -1):
		for z in size:
			var h1 := height_map.get_at(x, z)
			var h2 := height_map.get_at(x - 1, z)
			
			if (h1 > h2):
				var h := h1 - h2
				h1 += 1
				planes[Vector2(x, z)] = {
					"v1": Vector3(x, h1, z),
					"v2": Vector3(x, h1, z + 1),
					"v3": Vector3(x, h1 - h, z + 1),
					"v4": Vector3(x, h1 - h, z),
				}
	
	return planes


func _create_vertex(height_map: HeightMap, x: int, z: int) -> Vector3:
	var v := Vector3(x, 0, z)
	v.y = height_map.get_at(x, z)
	return v


func _create_colors(tiles: Dictionary) -> void:
	for tiles_side in tiles.values():
		for tile in tiles_side.values():
			var height = tile.v1.y
			
			if height >= 0.9 * map_scale:
				tile.c = Color.darkgray
			elif height >= 0.6 * map_scale:
				tile.c = Color.darkgray
			elif height >= 0.5 * map_scale:
				tile.c = Color.chocolate
			elif height >= 0.4 * map_scale:
				tile.c = Color.green
			elif height >= 0.2 * map_scale:
				tile.c = Color.yellow
			elif height >= 0.1 * map_scale:
				tile.c = Color.blue
			else:
				tile.c = Color.deepskyblue


func _create_uvs() -> PoolVector2Array:
	var uvs := PoolVector2Array()
	
	var factor := 1.0 / float(size)
	
	for u in size:
		for v in size:
			uvs.push_back(Vector2(u * factor, v * factor))
	
	return uvs


func _create_indexes(planes: Dictionary) -> PoolIntArray:
	var indexes := PoolIntArray()

	var i := 0
	for planes_sides in planes.values():
		for plane in planes_sides.values():
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
	for i in height_map.size():
		var h := height_map.get_at_index(i)
		
		h = int(h * 10) / 10.0
		
		height_map.set_at_index(i, h)


func _get_at(arr: PoolVector3Array, x: int, z: int) -> Vector3:
	var sz := int(sqrt(arr.size()))
	
	return arr[x * sz + z]


func _calc_idx(sz: int, x: int, z: int) -> int:
	return x * sz + z
