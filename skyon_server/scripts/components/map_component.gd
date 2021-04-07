class_name MapComponent
extends Reference

const SIZE = 512

var position: Vector2
var height_map: PoolByteArray
var connections: PoolVector2Array
var height_pallet: PoolColorArray
var collisions: PoolVector3Array
# TODO: Add resources, mob spawn points, npcs and such


func save_to(path: String) -> void:
	var file := File.new()
	Log.ok(file.open_compressed(path, File.WRITE, File.COMPRESSION_ZSTD))
	
	file.store_var(position)
	file.store_var(height_map)
	file.store_var(connections)
	file.store_var(height_pallet)
	file.store_var(collisions)
	
	file.close()


func load_from(path: String) -> void:
	var file := File.new()
	Log.ok(file.open_compressed(path, File.READ, File.COMPRESSION_ZSTD))
	
	position = file.get_var() as Vector2
	height_map = file.get_var() as PoolByteArray
	connections = file.get_var() as PoolVector2Array
	height_pallet = file.get_var() as PoolColorArray
	collisions = file.get_var() as PoolVector3Array
	
	file.close()

func serialize() -> Array:
	# since collisions are too big, we won't send it over the wire
	return [
		position,
		height_map,
		connections,
		height_pallet,
	]


func deserialize(buffer: Array) -> void:
	# since collisions are too big, we won't send it over the wire
	position = buffer[0] as Vector2
	height_map = buffer[1] as PoolByteArray
	connections = buffer[2] as PoolVector2Array
	height_pallet = buffer[3] as PoolColorArray
	
