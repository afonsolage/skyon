class_name WorldSystem
extends Node

signal selected_target(target, follow)
signal selected_path(position)
signal cleared_target()
signal cleared_path()

var main_player : Spatial

var _last_state_time : int = 0

var _select_target_node : SelectTarget
var _select_target_path : SelectTarget
var _current_target : Spatial
var _follow_target : bool
var _current_path : Vector3 = Vector3.ZERO

onready var monsters : Node = $Monsters
onready var camera : Camera = $Camera
onready var terrain : Terrain = $Terrain
onready var _monster_res := preload("res://scenes/monsters/monster.tscn")

onready var _select_target_gizmo_res := preload("res://scenes/misc/select_target.tscn")
onready var _select_path_gizmo_res := preload("res://scenes/misc/select_target_path.tscn")

func _ready() -> void:
	_select_target_node = _select_target_gizmo_res.instance() as SelectTarget
	_select_target_node.name = "SelectionNodeTarget"
	_select_target_node.visible = false
	
	_select_target_path = _select_path_gizmo_res.instance() as SelectTarget
	_select_target_path.name = "SelectionNodePath"
	_select_target_path.visible = false


remote func spawn_main_player(position: Vector3) -> void:
	main_player = load("res://scenes/characters/player.tscn").instance() as Spatial
	main_player.name = "Main Player"
	main_player.translate(position)

	self.add_child(main_player)


func select_target(target: Node, follow_target: bool = false) -> void:
	if follow_target and target == main_player:
		# can't follow it self
		return

	if target and not target == _current_target:
		clear_selection(true, follow_target)

		if follow_target:
			_select_target_node.reset(SelectTarget.TargetType.FOLLOW)
		else:
			_select_target_node.reset(SelectTarget.TargetType.TARGET)

		target.add_child(_select_target_node)
		_current_target = target
		_follow_target = follow_target

		self.emit_signal("selected_target", _current_target, _follow_target)


func select_path(position: Vector3) -> void:
	clear_selection(_follow_target, true)
	
	_select_target_path.reset(SelectTarget.TargetType.PATH, position)
	self.add_child(_select_target_path)
	_current_path = position
	
	self.emit_signal("selected_path", position)


func clear_selection(target: bool = true, path: bool = true) -> void:
	if target and has_target():
		_current_target.remove_child(_select_target_node)
		_select_target_node.visible = false
		_current_target = null
		
		self.emit_signal("cleared_target")
		
	if path and has_position():
		self.remove_child(_select_target_path)
		_select_target_path.visible = false
		_current_path = Vector3.ZERO
		
		self.emit_signal("cleared_path")


func has_target() -> bool:
	return not _current_target == null


func has_position() -> bool:
	return _current_path.length() > 0


func _set_player_state(_id: String, _state: Dictionary):
	# TODO: set other players state
	pass


func _set_monster_state(id: String, state: Dictionary):
	var monster: Spatial = monsters.get_node_or_null("%s" % id)
	
	if not monster:
		monster = _monster_res.instance()
		monster.name = id
		
		monsters.add_child(monster)
	else:
		monster = monster as Spatial
	
	monster.set_state(state)


func send_state(state: Dictionary) -> void:
	rpc_unreliable_id(1, "set_player_state", state)


remote func state_sync(states: Dictionary) -> void:
	if states.T < _last_state_time:
		Log.d("Discarting outdated states: %s" % [states])
	else:
		_last_state_time = states.T
	
	var _erased := states.erase("T")
	
	for state in states:
		var type: String = state.left(1)
		if type == "P":
			_set_player_state(state, states[state])
		elif type == "M":
			_set_monster_state(state, states[state])


func get_spatial(id: String) -> Spatial:
	var type := id.left(1)
	match type:
		"P":
			#Not yet implemented!
			pass
		"M":
			return monsters.get_node(id) as Spatial
		_:
			Log.e("Unknown spatial type on id %s" % id)

	return null
	
func _on_session_started():
	rpc_id(1, "join_world")

