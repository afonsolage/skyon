class_name HeightMap

var _buffer: PoolRealArray
var _connections: PoolVector2Array
var _size := 0

func init(size: int):
	_size = size
	_buffer.resize(size * size)
	
	_connections.push_back(Vector2.ZERO)
	_connections.push_back(Vector2.ZERO)
	_connections.push_back(Vector2.ZERO)
	_connections.push_back(Vector2.ZERO)


func set_at(x: int, y: int, value: float) -> void:
	_buffer[calc_index(x, y)] = value


func get_at(x: int, y: int) -> float:
	return _buffer[calc_index(x, y)]


func get_at_index(i: int) -> float:
	return _buffer[i]


func set_at_index(i: int, value: float) -> void:
	_buffer[i] = value


func calc_index(x: int, y: int) -> int:
	return x * _size + y


func calc_pos(index: int) -> Vector2:
	return Vector2(index / _size, index % _size)

func size() -> int:
	return _size


func buffer_size() -> int:
	return _buffer.size()


func set_connections(idx: int, location: Vector2) -> void:
	_connections[idx] = location


func scale(value: float) -> void:
	for i in _buffer.size():
		_buffer[i] = _buffer[i] * value


func connections() -> PoolVector2Array:
	return _connections
