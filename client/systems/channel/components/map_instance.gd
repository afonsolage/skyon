class_name MapInstance
extends MeshInstance

const SCALE = 0.5

var map_component: MapComponent

func _init() -> void:
	self.name = "MapInstance"
	map_component = MapComponent.new()

func _ready() -> void:
	self.scale = Vector3(SCALE, SCALE, SCALE)
	_setup_terrain()
	_setup_resources()


func _setup_resources() -> void:
	var resources := map_component.resources_scene

	Log.d("Loaded %d resources" % resources.get_child_count())
	
	self.add_child(resources)


func _setup_terrain() -> void:
	self.mesh = map_component.terrain_mesh
	
	var static_body = StaticBody.new()
	static_body.name = "StaticBody"
	static_body.add_to_group("Terrain")
	static_body.collision_mask = 0
	
	var concave_shape = ConcavePolygonShape.new()
	concave_shape.set_faces(map_component.terrain_collision)
	
	var collision_shape = CollisionShape.new()
	collision_shape.name = "CollisionShape"
	collision_shape.shape = concave_shape
	
	static_body.add_child(collision_shape)

	self.add_child(static_body)


func serialize() -> Array:
	return [
		map_component.serialize()
	]


func deserialize(buffer: Array) -> void:
	map_component.deserialize(buffer[0])


func save_to(path: String) -> void:
	map_component.save_to(path)


func load_from(path: String) -> void:
	map_component.load_from(path)
