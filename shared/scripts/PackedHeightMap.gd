class_name PackedHeightMap
extends Node

var _buffer: PoolByteArray
var _size: int

func _init(size: int) -> void:
	_size = size
	_buffer = PoolByteArray()
	_buffer.resize(size * size)


func set_at(x: int, y: int, value: int) -> void:
	_buffer[calc_index(x, y)] = value


func get_at(x: int, y: int) -> int:
	return _buffer[calc_index(x, y)]


func get_at_index(i: int) -> int:
	return _buffer[i]


func set_at_index(i: int, value: int) -> void:
	_buffer[i] = value


func calc_index(x: int, y: int) -> int:
	return x * _size + y


func calc_pos(index: int) -> Vector2:
# warning-ignore:integer_division
	return Vector2(index / _size, index % _size)


func is_pos_valid(pos: Vector2) -> bool:
	var idx := calc_index(int(pos.x), int(pos.y))
	return idx > 0 and idx < _buffer.size()


func size() -> int:
	return _size


func buffer_size() -> int:
	return _buffer.size()


func scale(value: int) -> void:
	for i in _buffer.size():
		_buffer[i] = _buffer[i] * value


func save_to_resource(path: String) -> void:
	var file := File.new()
	Log.ok(file.open(path, File.WRITE))
	file.store_var(_size)
	file.store_var(_buffer.compress(File.COMPRESSION_ZSTD))
	file.close()


func load_from_resource(path: String) -> void:
	var file := File.new()
	Log.ok(file.open(path, File.READ))
	_size = file.get_var() as int
	var tmp := file.get_var() as PoolByteArray
	_buffer = tmp.decompress(_size * _size, File.COMPRESSION_ZSTD)
	file.close()

