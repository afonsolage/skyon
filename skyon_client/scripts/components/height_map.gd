class_name HeightMap

var _buffer: PoolRealArray
var _size := 0

func init(size: int) -> void:
	_size = size
	_buffer.resize(size * size)
#	for i in size * size:
#		_buffer[i] = 0


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


func size() -> int:
	return _size


func buffer_size() -> int:
	return _buffer.size()


func scale(value: float) -> void:
	for i in _buffer.size():
		_buffer[i] = _buffer[i] * value


func save_to_resource(path: String) -> void:
	var file := File.new()
	file.open(path, File.WRITE)
	file.store_var(_size)
	file.store_var(_buffer)
	file.close()


func load_from_resource(path: String) -> void:
	var file := File.new()
	file.open(path, File.READ)
	_size = file.get_var() as int
	_buffer = file.get_var() as PoolRealArray
	file.close()
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
