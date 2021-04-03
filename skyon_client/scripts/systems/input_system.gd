class_name InputSystem
extends Node

signal selected_target(target, follow)
signal selected_path(position)
signal cleared_target
signal cleared_path

signal attack_pressed

export(int) var ray_cast_length := 1000

onready var _select_target_gizmo_res := preload("res://scenes/misc/select_target.tscn")
onready var _select_path_gizmo_res := preload("res://scenes/misc/select_target_path.tscn")

var _click_target : Vector2
var _click_path : Vector2
var _select_target_node : SelectTarget
var _select_target_path : SelectTarget
var _current_target_ref := WeakRef.new()
var _follow_target : bool
var _current_path : Vector3 = Vector3.ZERO

func _ready() -> void:
	Log.d("Initializing Input System")
	
	_select_target_node = _select_target_gizmo_res.instance() as SelectTarget
	_select_target_node.name = "SelectionNodeTarget"
	_select_target_node.visible = false
	
	_select_target_path = _select_path_gizmo_res.instance() as SelectTarget
	_select_target_path.name = "SelectionNodePath"
	_select_target_path.visible = false


func _process(_delta: float) -> void:
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
				
	elif event.is_action_pressed("attack"):
		self.emit_signal("attack_pressed")


func select_target(target: Node, follow_target: bool = false) -> void:
	if follow_target and target == Systems.world.main_player:
		# can't follow it self
		return

	var current_target = _current_target_ref.get_ref()

	if target and not target == current_target:
		clear_selection(true, follow_target)

		if follow_target:
			_select_target_node.reset(SelectTarget.TargetType.FOLLOW)
		else:
			_select_target_node.reset(SelectTarget.TargetType.TARGET)

		target.add_child(_select_target_node)
		_current_target_ref = weakref(target)
		_follow_target = follow_target

		self.emit_signal("selected_target", target, _follow_target)


func select_path(position: Vector3) -> void:
	clear_selection(_follow_target, true)
	
	_select_target_path.reset(SelectTarget.TargetType.PATH, position)
	self.add_child(_select_target_path)
	_current_path = position
	
	self.emit_signal("selected_path", position)


func clear_selection(target: bool = true, path: bool = true) -> void:
	if target and has_target():
		var current_target = _current_target_ref.get_ref()
		if current_target:
			current_target.remove_child(_select_target_node)
			
		_select_target_node.visible = false
		_current_target_ref = WeakRef.new()
		
		self.emit_signal("cleared_target")
		
	if path and has_position():
		self.remove_child(_select_target_path)
		_select_target_path.visible = false
		_current_path = Vector3.ZERO
		
		self.emit_signal("cleared_path")


func has_target() -> bool:
	return _current_target_ref.get_ref()


func has_position() -> bool:
	return _current_path.length() > 0


func _select_object() -> void:
	var result = _do_ray_cast(_click_target)
	
	if result.collider and result.collider is Spatial \
			and (result.collider as Spatial).is_in_group("Targetable"):
		select_target(result.collider)
	else:
		clear_selection(true, false)


func _select_path() -> void:
	var result = _do_ray_cast(_click_path)
	
	if result.collider and result.collider is Spatial \
			and (result.collider as Spatial).is_in_group("Terrain"):
		select_path(result.position)
	elif result.collider and result.collider is Spatial \
			and (result.collider as Spatial).is_in_group("Targetable"):
		select_target(result.collider, true)
	else:
		clear_selection(false, true)


func _do_ray_cast(target: Vector2) -> Dictionary:
	var camera := Systems.world.get_camera() as Camera
	
	var from = camera.project_ray_origin(target)
	var to = from + camera.project_ray_normal(target) * ray_cast_length
	var space_state := camera.get_world().direct_space_state
	return space_state.intersect_ray(from, to)
