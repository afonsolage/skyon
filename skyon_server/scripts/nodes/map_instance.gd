class_name MapInstance
extends MeshInstance

signal connection_area_entered(player, area_id)

const SCALE = 0.5
const SCALE_VECTOR = Vector3(SCALE, SCALE, SCALE)

var map_component: MapComponent

onready var _connection_area_res := preload("res://scenes/connection_area.tscn")

func _ready() -> void:
	self.scale = SCALE_VECTOR
	
	_setup_terrain()
	_setup_connections()


func _setup_connections() -> void:
	var connections := Spatial.new()
	connections.name = "Connections"
	
	for side in map_component.connections.size():
		var connection := map_component.connections[side]
		if connection == Vector2.ZERO or connection == Vector2(-1, -1):
			continue
		
		var shape_size := 8 * 1.2
		var area_position := Vector3(connection.x + shape_size / 2, shape_size, connection.y + shape_size / 2)
		var area := _connection_area_res.instance() as ConnectionArea
		area.name = "ConnectionArea%d" % side
		area.translation = area_position
		area.scale = SCALE_VECTOR
		area.scale *= shape_size
		
		match side:
			Consts.Direction.RIGHT:
				area.rotation_degrees = Vector3(0, 180, 0)
			Consts.Direction.DOWN:
				area.rotation_degrees = Vector3(0, 90, 0)
			Consts.Direction.UP:
				area.rotation_degrees = Vector3(0, -90, 0)
			
		
#		var shape := BoxShape.new()
#		shape.extents = Vector3(shape_size, shape_size, shape_size)
#
#		var collision = CollisionShape.new()
#		collision.shape = shape
#
#		var area_position := Vector3(connection.x, shape_size / 2, connection.y) + shape.extents / 2
#		var area := Area.new()
#		area.name = "ConnectionArea%d" % i
#		area.translation = area_position
#		area.scale = SCALE_VECTOR
#		area.collision_layer = 0
#		area.collision_mask = 0
#		area.set_collision_mask_bit(2, true)
#		Log.ok(area.connect("body_entered", self, "_on_connection_area_entered", [i]))
#		
#		area.add_child(collision)
		
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
