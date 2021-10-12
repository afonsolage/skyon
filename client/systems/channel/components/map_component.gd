class_name MapComponent
extends Reference

enum ResourceType {
	TREE,
	STONE,
	PLANT,
}

const SIZE = 512

# Server attributes
var position: Vector2
var height_map: PoolByteArray
var connections: PoolVector2Array
var height_pallet: PoolColorArray
var resources: Dictionary

# Client generate attributes
var terrain_collision: PoolVector3Array
var terrain_mesh: Mesh
var resources_scene: Spatial

# TODO: Add resources, mob spawn points, npcs and such


func save_to(path: String) -> void:
	var file := File.new()
	Log.ok(file.open_compressed(path, File.WRITE, File.COMPRESSION_ZSTD))
	
	file.store_var(position)
	file.store_var(height_map)
	file.store_var(connections)
	file.store_var(height_pallet)
	file.store_var(terrain_collision)
	file.close()
	
	Log.ok(ResourceSaver.save("%s.mesh" % path, terrain_mesh, ResourceSaver.FLAG_COMPRESS))
	
	var packed_scene := PackedScene.new()
	Log.ok(packed_scene.pack(resources_scene))
	
	Log.ok(ResourceSaver.save("%s_res.tscn" % path, packed_scene))


func load_from(path: String) -> void:
	var file := File.new()
	Log.ok(file.open_compressed(path, File.READ, File.COMPRESSION_ZSTD))
	
	position = file.get_var() as Vector2
	height_map = file.get_var() as PoolByteArray
	connections = file.get_var() as PoolVector2Array
	height_pallet = file.get_var() as PoolColorArray
	terrain_collision = file.get_var() as PoolVector3Array
	
	file.close()
	
	terrain_mesh = load("%s.mesh" % path)
	var packed_scene := ResourceLoader.load("%s_res.tscn" % path, "PackedScene", false) as PackedScene
	resources_scene = packed_scene.instance()


func deserialize(buffer: Array) -> void:
	# since collisions and mesh are too big, we won't send it over the wire
	
	position = buffer[0] as Vector2
	height_map = buffer[1] as PoolByteArray
	connections = buffer[2] as PoolVector2Array
	height_pallet = buffer[3] as PoolColorArray
	resources = buffer[4] as Dictionary
