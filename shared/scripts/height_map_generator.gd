class_name HeightMapGenerator

const DIRS := [Vector2(1,0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1)]

export(bool) var is_generate_terrain := true
export(bool) var is_generate_border := true
export(bool) var is_generate_places := true
export(bool) var is_connect_places := true
export(bool) var is_smooth_connection_border := true
export(bool) var is_normalize_height := true


export(int) var size := 256
export(int) var octaves := 2
export(float) var persistance := 0.3
export(float) var period := 20.0
export(int) var border_size := 30
export(float) var border_thickness := 0.05
export(bool) var border_montains := false
export(int) var border_connection_size := 8
export(int) var places_count := 5
export(int) var places_path_noise_rate := 40
export(int) var places_path_thickness := 5

export(bool) var disable_randomness := false

func generate(some_seed: int = 0) -> HeightMap:
	print("Generating a new map with seed %d" % some_seed)
	if some_seed == 0:
		randomize()
	else:
		seed(some_seed)
	
	var map = HeightMap.new()
	map.init(size)
	
	if is_generate_terrain:
		generate_terrain(map)
	
	if is_generate_border:
		generate_border(map)
	
	if is_generate_places:
		generate_places(map)
	
	if is_normalize_height:
		normalize_height(map)
	
	return map


func generate_terrain(map: HeightMap) -> void:
	var noise = OpenSimplexNoise.new()
	
	if disable_randomness:
		seed(1)
		
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
	var border_right := size - border_size
	var border_down := size - border_size
	
	for x in range(size):
		for y in range(size):
			if x > border_left && x < border_right && y > border_up && y < border_down:
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


func generate_places(map: HeightMap) -> void:
# warning-ignore:integer_division
	var offset := int(size / 15)
	var places := []
	
	var first_connection_generated := false
	
	var dir_idx = randi() % 4
	var dir:Vector2 = DIRS[dir_idx]
	var connections := []
	
	for _i in range(DIRS.size()):
		if not first_connection_generated or randi() % 100 > 30:
			first_connection_generated = true
			connections.push_back(dir)
			dir_idx = (dir_idx + 1) % DIRS.size()
			dir = DIRS[dir_idx]
		
	
	for connection_dir in connections:
		var max_offset := size - (border_connection_size * 3)
		var rnd := (randi() % max_offset) + border_connection_size
		
		var x = rnd if connection_dir.x == 0 else 0 if connection_dir.x == -1 else size - border_connection_size - 1
		var y = rnd if connection_dir.y == 0 else 0 if connection_dir.y == -1 else size - border_connection_size - 1
		
		create_square(x, y, border_connection_size, border_connection_size, map, true)
# warning-ignore:integer_division
# warning-ignore:integer_division
		var center = Vector2(int(x + border_connection_size / 2), int(y + border_connection_size / 2))
		places.push_back(center)
	
	for _i in range(places_count):
		var x = randi() % (size - offset * 3) + offset
		var y = randi() % (size - offset * 3) + offset
		var w = randi() % offset * 2 + offset
		var h = randi() % offset * 2 + offset
		
		create_square(x, y, w, h, map)
		places.push_back(Vector2(int(x + w / 2), int(y + h / 2)))

	if is_connect_places:
		connect_places(places, map)


func create_square(sx: int, sy: int, swidth: int, sheight: int, map: HeightMap, connection := false) -> void:
	var rect := Rect2(sx, sy, swidth, sheight)
	var map_rect = Rect2(0, 0, size, size)
	var half_size:Vector2 = (rect.end - rect.position) / 2
	var center := Vector2(rect.position.x + int(half_size.x), rect.position.y + int(half_size.y))
		
	if not map_rect.encloses(rect):
		return
	
# warning-ignore:integer_division
	var sborder_thickness := int(float((swidth + sheight) / 2 / 5.0))
	var border_rect = Rect2(rect.position.x - sborder_thickness, 
		rect.position.y - sborder_thickness,  
		rect.end.x + (sborder_thickness * 2) - 1, 
		rect.end.y + (sborder_thickness * 2) - 1)
		
# warning-ignore:integer_division
	var connection_rect :Rect2 = map_rect.grow(-border_connection_size/2)
	
	for pixel_x in range(rect.position.x, rect.end.x):
		for pixel_y in range(rect.position.y, rect.end.y):
			var pixel_point = Vector2(pixel_x, pixel_y)
			
			if not map_rect.has_point(pixel_point):
				continue
			
			var h := 0.5 #TODO Find a better way to place this const
			
			if not connection or connection_rect.has_point(pixel_point):
				h = map.get_at(pixel_x, pixel_y)
				var dist :float = (pixel_point - center).length()
				var diff :float = (half_size.length() - dist) / half_size.length()
				var diff_h = h - 0.5
				h -= diff_h * diff 
			
			map.set_at(pixel_x, pixel_y, h)

	if is_smooth_connection_border:
		var point := center
		var walk_left := 1
		
		var dir_cnt := 0
		var dir: Vector2 = DIRS[dir_cnt]
		var dir_mod := 0
		
		while border_rect.has_point(point):
			if map_rect.has_point(point) && not rect.has_point(point):
				smooth_pixel(int(point.x), int(point.y), map)
			
			walk_left -= 1
			
			if walk_left <= 0:
				dir_mod += 1
				dir = DIRS[dir_mod % 4]
				
				dir_cnt += (1 if dir_mod % 2 == 1 else 0)
				walk_left = dir_cnt
			
			point += dir


func smooth_pixel(x: int, y: int, map: HeightMap) -> void:
	var map_rect = Rect2(0, 0, size, size)
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


func connect_places(places, map: HeightMap) -> void:
	while not places.empty():
		var point = places.pop_back();
		
		if places.empty():
			return
		
		var sorter := DistanceSorter.new()
		sorter.target = point
		places.sort_custom(sorter, "sort")
		generate_path(point, places.front(), map)


static func sort_by_distance(a, b) -> bool:
	if a[1] < b[1]:
		return true
	else:
		return false


func generate_path(origin: Vector2, dest: Vector2, map: HeightMap) -> void:
	var queue = []
	var walked = []
	queue.push_back([origin, calc_distance_length(origin, dest)])
	
	var sanity_check := 1000
	
	while not queue.empty():
		sanity_check -= 1
		if sanity_check < 0:
			print("Sanity failed. Queue size: %d" % queue.size())
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
	var map_rect = Rect2(0, 0, size, size)
	
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
