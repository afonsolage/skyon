class_name HeightMapGenerator

const MIN_MAP_MARGIN := 2
const DIRS := [Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN]
const REV_DIRS := [Vector2.LEFT, Vector2.DOWN, Vector2.RIGHT, Vector2.UP]

var is_generate_terrain := true
var is_generate_border := true
var is_generate_connections := true
var is_normalize_height := true

var size := 256
var octaves := 2
var persistance := 0.3
var period := 20.0
var border_size := 30
var border_thickness := 0.05
var border_montains := false
var border_connection_size := 8
var places_count := 5
var places_path_noise_rate := 40
var places_path_thickness := 5
var existing_connections := PoolVector2Array([
	Vector2.ZERO,
	Vector2.ZERO,
	Vector2.ZERO,
	Vector2.ZERO,
])


func generate(some_seed: int = 0) -> HeightMap:
	Log.d("Generating a new map with seed %d" % some_seed)
	
	seed(some_seed)
		
	var map = HeightMap.new()
	map.init(size)
	
	if is_generate_terrain:
		generate_terrain(map)
	
	if is_generate_border:
		generate_border(map)
	 
	if is_generate_connections:
		generate_connections(map)
	
#	if is_generate_places:
#		generate_places(map)
	
	if is_normalize_height:
		normalize_height(map)
	
	return map


func generate_terrain(map: HeightMap) -> void:
	var noise = OpenSimplexNoise.new()
		
	noise.seed = randi()
	noise.octaves = octaves
	noise.period = period
	noise.persistence = persistance

	for x in range(size):
		for y in range(size):
			var h = (noise.get_noise_3d(x, 0.0, y) + 1.0) / 2.0
			map.set_at(x, y, h)


func generate_border(map: HeightMap) -> void:
	var border_left := border_size
	var border_up := border_size
	var border_right := size - 1 - border_size
	var border_down := size - 1 - border_size
	
	var map_rect = Rect2(MIN_MAP_MARGIN, MIN_MAP_MARGIN, size - MIN_MAP_MARGIN * 2, size - MIN_MAP_MARGIN * 2)
	var inner_rect := Rect2(
			border_left, 
			border_up, 
			border_right - border_left,
			border_down - border_up)
	
	for x in range(size):
		for y in range(size):
			if inner_rect.has_point(Vector2(x, y)):
				continue
			
			var border_thickness_x := 0
			
			if x < border_left:
				border_thickness_x = border_left - x
			elif x > border_right:
				border_thickness_x = x - border_right

			var border_thickness_y := 0

			if y < border_up:
				border_thickness_y = border_up - y
			elif y > border_down:
				border_thickness_y = y - border_down
			
			var h = map.get_at(x, y)
			h += max(border_thickness_x, border_thickness_y) * (border_thickness * (1 if border_montains else -1))
			map.set_at(x, y, h)


func generate_connections(map: HeightMap) -> void:
	var min_offset := 2
	var max_offset := size - border_connection_size - min_offset
	var connection_count := 0
	
	for connection in existing_connections:
		if not connection == Vector2.ZERO:
			connection_count += 1
		
	for i in DIRS.size():
		var existing_connection := existing_connections[i]
		
		var dir := DIRS[i] as Vector2
		
		if existing_connection == Vector2.ZERO:
			var rnd := randi() % 100
			var rate := 100 if connection_count == 0 else 100 - (connection_count * 20)
			
			if rnd < rate:
				map._connections[i] = generate_connection(map, dir)
				connection_count += 1
			else:
				map._connections[i] = Vector2(-1, -1)
		elif existing_connection == Vector2(-1, -1):
			continue
		else:
			if existing_connection.x == min_offset:
				existing_connection.x = max_offset
			elif existing_connection.x == max_offset:
				existing_connection.x = min_offset
				
			if existing_connection.y == min_offset:
				existing_connection.y = max_offset
			elif existing_connection.y == max_offset:
				existing_connection.y = min_offset

			var rev_dir := REV_DIRS[i] as Vector2
			existing_connection += MIN_MAP_MARGIN * rev_dir

			create_square(int(existing_connection.x),
					int(existing_connection.y), 
					border_connection_size, 
					border_connection_size, 
					map)
			
			map._connections[i] = existing_connection
	
	connect_connections(map)

func generate_connection(map: HeightMap, dir: Vector2) -> Vector2:
	var max_offset := size - border_connection_size
	
	var rnd := randi() % size
	
	rnd = int(clamp(rnd, border_connection_size * 2, size - border_connection_size * 2))
	
	var connection_x := rnd if dir.x == 0 else 0 if dir.x == -1 else max_offset
	var connection_y := rnd if dir.y == 0 else 0 if dir.y == -1 else max_offset
	
	var rev_dir := dir * -1
	var offset := rev_dir * MIN_MAP_MARGIN
	connection_x += offset.x
	connection_y += offset.y
	
	create_square(connection_x,
		connection_y, 
		border_connection_size, 
		border_connection_size, 
		map)
	
	return Vector2(connection_x, connection_y)


#func generate_places(map: HeightMap) -> void:
## warning-ignore:integer_division
#	var offset := int(size / 15)
#	var places := []
#
#	var first_connection_generated := false
#
#	var dir_idx = randi() % 4
#	var dir:Vector2 = DIRS[dir_idx]
#
#	for i in range(DIRS.size()):
#		if not first_connection_generated or randi() % 100 > 30:
#			first_connection_generated = true
#			dir_idx = (dir_idx + 1) % DIRS.size()
#			dir = DIRS[dir_idx]
#
#			var max_offset := size - (border_connection_size * 3)
#			var rnd := (randi() % max_offset) + border_connection_size
#
#			var x = rnd if dir.x == 0 else 0 if dir.x == -1 else size - border_connection_size - 1
#			var y = rnd if dir.y == 0 else 0 if dir.y == -1 else size - border_connection_size - 1
#
#			create_square(x, y, border_connection_size, border_connection_size, map, true)
## warning-ignore:integer_division
## warning-ignore:integer_division
#			var center = Vector2(int(x + border_connection_size / 2), int(y + border_connection_size / 2))
#			places.push_back(center)
#			map.set_connections(i, center)
#
#	for _i in range(places_count):
#		var x = randi() % (size - offset * 3) + offset
#		var y = randi() % (size - offset * 3) + offset
#		var w = randi() % offset * 2 + offset
#		var h = randi() % offset * 2 + offset
#
#		create_square(x, y, w, h, map)
#		places.push_back(Vector2(int(x + w / 2), int(y + h / 2)))
#
#	if is_connect_places:
#		connect_places(places, map)


func create_square(sx: int, sy: int, swidth: int, sheight: int, map: HeightMap) -> void:
	var rect := Rect2(sx, sy, swidth, sheight)
	var map_rect = Rect2(MIN_MAP_MARGIN, MIN_MAP_MARGIN, size - MIN_MAP_MARGIN * 2, size - MIN_MAP_MARGIN * 2)
	
	if not map_rect.encloses(rect):
		return
	
	for pixel_x in range(rect.position.x, rect.end.x + 1):
		for pixel_y in range(rect.position.y, rect.end.y + 1):
			var pixel_point = Vector2(pixel_x, pixel_y)
			
			if not map_rect.has_point(pixel_point):
				continue
			
			var h := 0.5 #TODO Find a better way to place this const
			
			map.set_at(pixel_x, pixel_y, h)



func smooth_pixel(x: int, y: int, map: HeightMap) -> void:
	var map_rect = Rect2(MIN_MAP_MARGIN, MIN_MAP_MARGIN, size - MIN_MAP_MARGIN * 2, size - MIN_MAP_MARGIN * 2)
	var h := 0.0
	var count := 0
	
	for i in range (-1, 2):
		for k in range (-1, 2):
			var point = Vector2(x + i, y + k)
			
			if not map_rect.has_point(point):
				continue
			
			h += map.get_at(point.x, point.y)
			count += 1
	
	
	if count > 0 :
		map.set_at(x, y, h / count)


class DistanceSorter:
	var target := Vector2.ZERO
	
	func sort(a, b):
		if (target - a).length() < (target - b).length():
			return true
		else:
			return false


func connect_connections(map: HeightMap) -> void:
	var places := []
	var offset = Vector2(border_connection_size / 2, border_connection_size / 2)
	
	for connection in map._connections:
		if not connection == Vector2.ZERO and not connection == Vector2(-1,-1):
			places.push_back(connection - offset)
	
# warning-ignore:integer_division
# warning-ignore:integer_division
	var center_offset_x := int(rand_range(-20, 20))
	var center_offset_y := int(rand_range(-20, 20))
	var center := Vector2(map.size() / 2 + center_offset_x, map.size() / 2 + center_offset_y)
	
	for i in map._connections.size():
		if map._connections[i] == Vector2.ZERO or map._connections[i] == Vector2(-1, -1):
			continue
		
		generate_path(map._connections[i] + offset, center, map)


static func sort_by_distance(a, b) -> bool:
	if a[1] < b[1]:
		return true
	else:
		return false


func generate_path(origin: Vector2, dest: Vector2, map: HeightMap) -> void:
	var queue = []
	var walked = []
	queue.push_back([origin, calc_distance_length(origin, dest)])
	
	var sanity_check := 10000
	
	while not queue.empty():
		sanity_check -= 1
		if sanity_check < 0:
			Log.e("Sanity failed. Queue size: %d" % queue.size())
			return
		
		var point = queue.pop_front()[0]
		
		walked.push_front(point)
		
		if point == dest:
			draw_path(walked, map)
			return

		var added_noise := false

		for dir in DIRS:
			var next_point :Vector2 = point + dir
			
			if not added_noise && randi() % 100 < places_path_noise_rate:
				added_noise = true
				continue
				
			if not walked.has(next_point):
				queue.push_back([next_point, calc_distance_length(next_point, dest)])
		
		queue.sort_custom(self, "sort_by_distance")


func draw_path(path, map: HeightMap) -> void:
	var map_rect = Rect2(MIN_MAP_MARGIN, MIN_MAP_MARGIN, size - MIN_MAP_MARGIN * 2, size - MIN_MAP_MARGIN * 2)
	
	for p in path:
		for dir in DIRS:
			for i in range(1, places_path_thickness):
				var pixel = p + (dir * i)
				if map_rect.has_point(pixel):
					map.set_at(pixel.x, pixel.y, 0.5)
	
	for p in path:
		for dir in DIRS:
			for i in range(1, int(places_path_thickness * 2)):
				var pixel = p + (dir * i)
				if map_rect.has_point(pixel):
					smooth_pixel(pixel.x, pixel.y, map)


func calc_distance_length(a: Vector2, b: Vector2) -> float:
	return (a-b).length()


func normalize_height(map: HeightMap) -> void:
	for x in size:
		for y in size:
			var height := map.get_at(x, y)
			height = (height + 1.0) / 2.0
			map.set_at(x, y, clamp(height, 0.0, 1.0))
