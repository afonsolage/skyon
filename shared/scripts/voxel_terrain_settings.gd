class_name VoxelTerrainSettings
extends Resource

export(bool) var is_generate_height_map := false
export(bool) var is_generate_terrain := true
export(bool) var is_generate_border := true
export(bool) var is_generate_connections := true
export(bool) var is_smooth_connection_border := true
export(bool) var is_normalize_height := true
export(bool) var is_generate_mesh_instance := true
export(bool) var is_generate_collisions := true
export(bool) var is_save_height_map := false
export(bool) var is_force_generation := false

export(float) var map_scale := 10.0;
export(int) var size := 512
export(int) var octaves := 5
export(float) var persistance := 0.2
export(float) var period := 20.0
export(int) var border_size := 30
export(float) var border_thickness := 0.05
export(bool) var border_montains := true
export(int) var border_connection_size := 8
export(int) var places_count := 5
export(int) var places_path_noise_rate := 40
export(int) var places_path_thickness := 5
export(Array, Color) var height_colors := []

export(int) var seed_number := OS.get_ticks_usec()

var surrounding_connections := PoolVector2Array([
	Vector2.ZERO,
	Vector2.ZERO,
	Vector2.ZERO,
	Vector2.ZERO,
])
