class_name Terrain
extends MeshInstance

var height_map : PackedHeightMap
var height_map_scale : float = 0.5
var _a_star : AStar

func _ready():
	self.scale = Vector3(height_map_scale, height_map_scale, height_map_scale)
#	height_map = HeightMap.new()
#	height_map.load_from_resource("user://terrain.tmp")
#	_setup_a_star()

#func find_path_to(from: Vector3, to: Vector3) -> PoolVector3Array:
#	var res := PoolVector3Array()
#
#	var from_id := _a_star.get_closest_point(from)
#	var to_id := _a_star.get_closest_point(to)
#
#	return _a_star.get_point_path(from_id, to_id);


#func _setup_a_star() -> void:
#	_a_star = AStar.new()
#
#	for x in height_map.size():
#		for z in height_map.size():
#			var idx := height_map.calc_index(x, z)
#			var h := height_map.get_at_index(idx)
#
#			var point = Vector3(x * height_map_scale, h, z * height_map_scale)
#			_a_star.add_point(idx, point)
#
#	for x in height_map.size():
#		for z in height_map.size():	
#			var idx := height_map.calc_index(x, z)
#			var height := height_map.get_at_index(idx)
#			for x1 in range(-1, 2):
#				for z1 in range(-1, 2):
#					if x1 == 0 and z1 == 0:
#						continue # Our selves, we can skip
#
#					var neighbor_idx := height_map.calc_index(x + x1, z + z1)
#					if neighbor_idx < 0 or neighbor_idx >= height_map.buffer_size():
#						continue # Invalid neightbor index
#
#					var neighbor_height := height_map.get_at_index(neighbor_idx)
#					if neighbor_height - height > 1.0:
#						continue # Two blocks higher, we can go there
#
#					# TODO: Add another checks, like water blocks and so on
#
#					_a_star.connect_points(idx, neighbor_idx, false)
