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
	Log.ok(file.open(path, File.WRITE))
	file.store_var(position)
	file.store_var(height_map)
	file.store_var(connections)
	file.store_var(height_pallet)
	file.store_var(collisions)
	file.close()


func load_from(path: String) -> void:
	var file := File.new()
	Log.ok(file.open(path, File.READ))
	
	position = file.get_var() as Vector2
	height_map = file.get_var() as PoolByteArray
	connections = file.get_var() as PoolVector2Array
	height_pallet = file.get_var() as PoolColorArray
	collisions = file.get_var() as PoolVector3Array
	
	file.close()
