extends Camera

export(NodePath) var _follow_target_path : NodePath
export(Vector3) var offset : Vector3
export(int) var ray_cast_length := 1000

var _follow_target : Spatial
var _click_target : Vector2
var _click_path : Vector2

func _physics_process(_delta):
	if not _follow_target:
		if not Systems.world:
			return
			
		_follow_target = Systems.world.main_player
	else:
		self.transform.origin = _follow_target.transform.origin - offset
	
	if _click_target.length() > 0:
		_select_object()
		_click_target = Vector2.ZERO
		
	if _click_path.length() > 0:
		_select_path()
		_click_path = Vector2.ZERO


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var input_mouse := event as InputEventMouseButton
		if input_mouse.pressed:
			if input_mouse.button_index == BUTTON_LEFT:
				_click_target = event.position
			elif input_mouse.button_index == BUTTON_RIGHT:
				_click_path = event.position


func _select_object() -> void:
	var result = _do_ray_cast(_click_target)
	
	if result.collider and result.collider is Spatial \
			and (result.collider as Spatial).is_in_group("Targetable"):
		Systems.world.select_target(result.collider)
	else:
		Systems.world.clear_selection(true, false)


func _select_path() -> void:
	var result = _do_ray_cast(_click_path)
	
	if result.collider and result.collider is Spatial \
			and (result.collider as Spatial).is_in_group("Terrain"):
		Systems.world.select_path(result.position)
	elif result.collider and result.collider is Spatial \
			and (result.collider as Spatial).is_in_group("Targetable"):
		Systems.world.select_target(result.collider, true)
	else:
		Log.d(result)
		Systems.world.clear_selection(false, true)


func _do_ray_cast(target: Vector2) -> Dictionary:
	var from := self.project_ray_origin(target)
	var to := from + self.project_ray_normal(target) * ray_cast_length
	var space_state := get_world().direct_space_state
	return space_state.intersect_ray(from, to)
