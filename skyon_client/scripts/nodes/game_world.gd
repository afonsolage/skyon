class_name GameWorld
extends Node

signal selected_target(target, follow)
signal selected_path(position)
signal cleared_target()
signal cleared_path()

var main_player : Spatial

var _select_target_node : SelectTarget
var _select_target_path : SelectTarget
var _current_target : Spatial
var _follow_target : bool
var _current_path : Vector3 = Vector3.ZERO

onready var monsters : Node = $Monsters
onready var camera : Camera = $Camera
onready var terrain : Terrain = $Terrain
onready var _select_target_gizmo_res := preload("res://scenes/misc/select_target.tscn")
onready var _select_path_gizmo_res := preload("res://scenes/misc/select_target_path.tscn")

func _ready() -> void:
	_select_target_node = _select_target_gizmo_res.instance() as SelectTarget
	_select_target_node.name = "SelectionNodeTarget"
	_select_target_node.visible = false
	
	_select_target_path = _select_path_gizmo_res.instance() as SelectTarget
	_select_target_path.name = "SelectionNodePath"
	_select_target_path.visible = false
	


func spawn_main_player(position: Vector3) -> void:
	main_player = load("res://scenes/characters/player.tscn").instance() as Spatial
	main_player.name = "Main Player"
	main_player.translate(position)
	
	self.add_child(main_player)


func select_target(target: Node, follow_target: bool = false) -> void:
	if target and not target == _current_target:
		clear_selection(true, follow_target)
		
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


# STATIC HELPER FUNCTIONS

static func is_on_world() -> bool:
	var root := _get_root()
	return root.has_node("/root/GameWorld")


static func get_instance() -> GameWorld:
	if not is_on_world():
		Log.e("The game world isn't loaded. You can't call it from here.")
		return null
	else:
		return _get_root().get_node("/root/GameWorld") as GameWorld


static func _get_root() -> Viewport:
	var scene_tree := Engine.get_main_loop() as SceneTree
	return scene_tree.root
