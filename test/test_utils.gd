class_name TestUtils

static func create_static_body_cube(position: Vector3, masks: Array = [], \
		layers: Array = []) -> MeshInstance:
	var cube := MeshInstance.new()
	cube.mesh = CubeMesh.new()
	cube.create_trimesh_collision()
	cube.translation = position
	
	var static_body := cube.get_child(0) as StaticBody
	static_body.collision_layer = 0
	static_body.collision_mask = 0
	
	for mask in masks:
		static_body.set_collision_mask_bit(mask, true)
	
	for layer in layers:
		static_body.set_collision_layer_bit(layer, true)
	
	return cube
