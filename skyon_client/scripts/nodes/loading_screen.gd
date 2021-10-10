class_name LoadingScreen
extends Node

const MAPS_PATH = "user://maps/"

const TIPS = [
	"Dose anyone actually read these?",
	"Imagine something really funny here",
	"You cannot die if you health is always above 0",
	"Preparing something really special here",
	"Did you read all those tips? Really?",
	"Remember to sleep at least once a day",
]

export(int) var tip_change_interval: float = 5.0

var _tip_change_timeout: float = 0.0

onready var _tip = $LoadingScreen/Tip

func _ready() -> void:
	FileUtils.ensure_user_path_exists(MAPS_PATH)
	
	_tip_change_timeout = tip_change_interval
	_set_random_tip()


func _process(delta: float) -> void:
	_tip_change_timeout -= delta
	
	if _tip_change_timeout < 0:
		_tip_change_timeout = tip_change_interval
		_set_random_tip()


func start_loading(map_index: int) ->  MapInstance:
	var map_instance: MapInstance
	var map_path := "%s/%d" % [MAPS_PATH, map_index]
	
	if FileUtils.exists(map_path):
		var loading_map_instance := LoadingMapInstance.new()
		loading_map_instance.load_path = map_path
		
		map_instance = yield(loading_map_instance.run(), "completed")
	else:
		map_instance = yield(
			Systems.channel.download_channel_data(map_index), 
			"completed"
		)

		var loading_map_generator := LoadingMapGenerator.new()
		loading_map_generator.save_path = map_path
		loading_map_generator.map_instance = map_instance
		loading_map_generator.map_index = map_index
		
		loading_map_generator.run_local = true
		
		yield(loading_map_generator.run(), "completed")

	self.queue_free()
	
	return map_instance


func _set_random_tip() -> void:
	var tip_text = TIPS[rand_range(0, TIPS.size())]
	_tip.text = tip_text



class LoadingMapGenerator:
	extends SafeYieldThread
	
	var map_instance: MapInstance
	var map_index: int
	var save_path: String
	
	var _rnd := RandomNumberGenerator.new()
	
	func _t_do_work(_args: Array) -> void:
		_rnd.seed = map_index
		
		var generator := LowPolyGenerator.new()
		generator.settings.height_colors = map_instance.map_component.height_pallet
		
		var voxel_map := LowPolyMap.new(MapComponent.SIZE)
		voxel_map._buffer = map_instance.map_component.height_map
		
		var result := generator.generate_terrain_mesh(voxel_map)
		map_instance.map_component.terrain_mesh = result[0]
		map_instance.map_component.terrain_collision = result[1]
		
		var resources_scene = _t_generate_resources(map_instance.map_component.resources)
		map_instance.map_component.resources_scene = resources_scene
		
		map_instance.save_to(save_path)
		
		done(map_instance)
	
	
	func _t_generate_resources(resources: Dictionary) -> PackedScene:
		var resources_scene := Spatial.new()
		resources_scene.name = "Resources"
		
		for resource_position in resources:
			var resource := resources[resource_position] as Dictionary
			match resource.type:
				MapComponent.ResourceType.TREE:
					_t_generate_tree(resource_position, resources_scene)
				_:
					Log.e("Unespected resource type: %d on position: %d on map: %d"
							% [resource.type, resource_position, map_instance])
					continue
		
		var packed_resources := PackedScene.new()
		Log.ok(packed_resources.pack(resources_scene))
		
		return packed_resources
	
	
	func _t_generate_tree(position: Vector3, owner: Node) -> void:
		var tree := Spatial.new()
		tree.name = "Tree %s" % position
		tree.translation = position
		
		var tree_generator := TreeGenerator.new()
		tree_generator.set_seed(map_index)
		
		var result = tree_generator.generate_tree()
		
		var trunk_shape := ConvexPolygonShape.new()
		trunk_shape.points = result[0] as PoolVector3Array
		
		var trunk_collision := CollisionShape.new()
		trunk_collision.shape = trunk_shape
		trunk_collision.name = "TrunkTrunkCollision %s" % position
		
		var body := StaticBody.new()
		body.name = "TreeTrunk %s" % position
		
		var trunk_mesh := MeshInstance.new()
		trunk_mesh.mesh = result[1] as Mesh
		trunk_mesh.name = "TrunkMesh %s" % position
		trunk_mesh.rotation_degrees.y = _rnd.randf_range(-180, 180)
		
		var leaves_mesh := MeshInstance.new()
		leaves_mesh.mesh = result[2] as Mesh
		leaves_mesh.name = "LeavesMesh %s" % position
		leaves_mesh.translation.y = tree_generator.trunk_height + tree_generator.leaves_scale / 4.0
		trunk_mesh.rotation_degrees.y = _rnd.randf_range(-180, 180)
		
		body.add_child(trunk_collision)
		
		tree.add_child(body)
		tree.add_child(trunk_mesh)
		tree.add_child(leaves_mesh)
		
		owner.add_child(tree)
		
		trunk_collision.owner = owner
		body.owner = owner
		trunk_mesh.owner = owner
		leaves_mesh.owner = owner
		tree.owner = owner



class LoadingMapInstance:
	extends SafeYieldThread
	
	var load_path: String

	func _t_do_work(_args: Array) -> void:
		var map_instance := MapInstance.new()
		map_instance.load_from(load_path)
		
		done(map_instance)
