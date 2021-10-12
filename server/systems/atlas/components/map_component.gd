class_name MapComponent
extends Reference

enum ResourceType {
	TREE,
	STONE,
	PLANT,
}

const SIZE = 512

# Serializable attributes
var position: Vector2
var height_map: PoolByteArray
var height_pallet: PoolColorArray
var connections: PoolVector2Array
var resources: Dictionary

# Non-serializable attributes
var terrain_collision: PoolVector3Array
var trees_collision: Dictionary

# TODO: Add resources, mob spawn points, npcs and such


func _to_string() -> String:
	return "(%d, %d)" % [position.x, position.y]


func save_to(path: String) -> void:
	var file := File.new()
	Log.ok(file.open_compressed(path, File.WRITE, File.COMPRESSION_ZSTD))
	
	file.store_var(position)
	file.store_var(height_map)
	file.store_var(connections)
	file.store_var(height_pallet)
	file.store_var(resources)
	file.store_var(terrain_collision)
	file.store_var(trees_collision)
	
	file.close()


func load_from(path: String) -> void:
	var file := File.new()
	Log.ok(file.open_compressed(path, File.READ, File.COMPRESSION_ZSTD))
	
	position = file.get_var() as Vector2
	height_map = file.get_var() as PoolByteArray
	connections = file.get_var() as PoolVector2Array
	height_pallet = file.get_var() as PoolColorArray
	resources = file.get_var() as Dictionary
	terrain_collision = file.get_var() as PoolVector3Array
	trees_collision = file.get_var() as Dictionary
	
	file.close()

func serialize() -> Array:
	# since collisions are too big, we won't send it over the wire
	return [
		position,
		height_map,
		connections,
		height_pallet,
		resources,
	]


func deserialize(buffer: Array) -> void:
	# since collisions are too big, we won't send it over the wire
	position = buffer[0] as Vector2
	height_map = buffer[1] as PoolByteArray
	connections = buffer[2] as PoolVector2Array
	height_pallet = buffer[3] as PoolColorArray
	resources = buffer[4] as Dictionary
	

func get_height_at_index(index: int) -> int:
	return height_map[index]
	

func calc_pos(index: int) -> Vector2:
# warning-ignore:integer_division
	return Vector2(index / SIZE, index % SIZE)


func calc_index(pos: Vector2) -> int:
# warning-ignore:integer_division
	return int(pos.x) * SIZE + int(pos.y)
