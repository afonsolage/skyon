class_name MapInstance
extends MeshInstance

signal connection_area_entered(player, area_id)

const SCALE = 0.5
const SCALE_VECTOR = Vector3(SCALE, SCALE, SCALE)

var map_component: MapComponent

func _ready() -> void:
	self.scale = SCALE_VECTOR
	
	_setup_terrain()
	_setup_connections()


func _setup_connections() -> void:
	var connections := Spatial.new()
	connections.name = "Connections"
	
	for i in map_component.connections.size():
		var connection := map_component.connections[i]
		if connection == Vector2.ZERO or connection == Vector2(-1, -1):
			continue
		
		
		var shape := BoxShape.new()
		var shape_size := 8 * 1.2
		shape.extents = Vector3(shape_size, shape_size, shape_size)
		
		var collision = CollisionShape.new()
		collision.shape = shape
		
		var area_position := Vector3(connection.x, shape_size / 2, connection.y) + shape.extents / 2
		var area := Area.new()
		area.name = "ConnectionArea%d" % i
		area.translation = area_position
		area.scale = SCALE_VECTOR
		area.collision_layer = 0
		area.collision_mask = 0
		area.set_collision_mask_bit(2, true)
		Log.ok(area.connect("body_entered", self, "_on_connection_area_entered", [i]))
		
		
		area.add_child(collision)
		
		connections.add_child(area)

	self.add_child(connections)


func _setup_terrain() -> void:
	var static_body = StaticBody.new()
	static_body.add_to_group("Terrain")
	static_body.name = "StaticBody"
	
	var concave_shape = ConcavePolygonShape.new()
	concave_shape.set_faces(map_component.collisions)
	
	var collision_shape = CollisionShape.new()
	collision_shape.shape = concave_shape
	collision_shape.name = "CollisionShape"
	
	static_body.add_child(collision_shape)

	self.add_child(static_body)


func serialize() -> Array:
	return [
		map_component.serialize()
	]


func deserialize(buffer: Array) -> void:
	map_component = MapComponent.new()
	map_component.deserialize(buffer[0])


func _on_connection_area_entered(body: PhysicsBody, area_id: int) -> void:
	if not body is Player:
		Log.e("An invalid body (%s) entered on connection of map %s" % [body, map_component.position])
	
	self.emit_signal("connection_area_entered", body, area_id)
