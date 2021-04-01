class_name PlayerSystem
extends Node

signal health_changed(health, max_health)

const MOVE_PATH_MIN_DIST := 0.1
const FOLLOW_MIN_DIST := 0.5
const FOLLOW_MAX_DIST := 1.5

var _target_path: Vector3
var _target_follow_ref := WeakRef.new()
var _moving_to_path: bool = false

var _main_player: MainPlayer

func _physics_process(_delta: float) -> void:
	if not _main_player:
		if not Systems.world or not Systems.world.main_player:
			return
		
		_set_main_player(Systems.world.main_player as MainPlayer)
	
	if not _main_player.is_busy:
		_follow_target()
		_move_to_target()
		

func _set_main_player(main_player: MainPlayer) -> void:
	_main_player = main_player
	_main_player.combat.connect("health_changed", self, "_on_main_player_health_changed")


func _follow_target() -> void:
	if not _target_follow_ref.get_ref() or _moving_to_path:
		return

	var target_follow := _target_follow_ref.get_ref() as Spatial
	var look_at := target_follow.translation as Vector3
	look_at.y = _main_player.translation.y
	_main_player.look_at(look_at, Vector3.UP)
	
	if target_follow.translation.distance_to(_main_player.translation) < FOLLOW_MAX_DIST:
		return
	
	_target_path = target_follow.translation


func _move_to_target() -> void:
	if _target_path.length() > 0:
		if not _moving_to_path:
			_moving_to_path = true
			_main_player.set_walking()
		
		var look_at := Vector3(_target_path.x, _main_player.translation.y, _target_path.z)
		_main_player.look_at(look_at, Vector3.UP)
		
		var _velocity := _main_player.move_and_slide(-_main_player.transform.basis.z * _main_player.move_speed)

		var next_node_2d := Vector2(_target_path.x, _target_path.z)
		var transaltion_2d := Vector2(_main_player.translation.x, _main_player.translation.z)
		var dist := transaltion_2d.distance_to(next_node_2d)

		# TODO: Prevent player from climbing higher than 0.5
		if _main_player.is_on_wall() and _main_player.gravity.is_grounded():
			_main_player.gravity.jump()

		var is_following: bool = not _target_follow_ref.get_ref()
		var min_dist := MOVE_PATH_MIN_DIST if not is_following else FOLLOW_MIN_DIST

		if dist < min_dist:
			_target_path = Vector3.ZERO
	
	if _moving_to_path and _target_path == Vector3.ZERO:
		_moving_to_path = false
		_main_player.set_idle()
		Systems.input.clear_selection(false, true)


func _on_main_player_health_changed() -> void:
	self.emit_signal("health_changed", _main_player.combat.health, _main_player.combat.max_health)


func _on_InputSystem_selected_path(position: Vector3) -> void:
	_target_path = position


func _on_InputSystem_selected_target(target: Node, follow: bool):
	if not target or not follow:
		return;

	_target_follow_ref = weakref(target)


func _on_InputSystem_cleared_target():
	_target_follow_ref = WeakRef.new()


func _on_InputSystem_cleared_path():
	_target_path = Vector3.ZERO
