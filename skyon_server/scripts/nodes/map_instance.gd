class_name MapInstance
extends MeshInstance

const SCALE = 0.5


var map_component: MapComponent
func _ready():
	self.scale = Vector3(SCALE, SCALE, SCALE)
	
	var static_body = StaticBody.new()
	static_body.add_to_group("Terrain")
	
	var concave_shape = ConcavePolygonShape.new()
	concave_shape.set_faces(map_component.collisions)
	
	var collision_shape = CollisionShape.new()
	collision_shape.shape = concave_shape
	
	static_body.add_child(collision_shape)

	self.add_child(static_body)


func serialize() -> Array:
	return [
		map_component.serialize()
	]


func deserialize(buffer: Array):
	map_component = MapComponent.new()
	map_component.deserialize(buffer[0])
