extends KinematicBody

const MOVE_PATH_MIN_DIST := 0.1
const FOLLOW_MIN_DIST := 0.5
const FOLLOW_MAX_DIST := 1.5

export(float) var move_speed := 3.0
export(float) var jump_force := 4.0

var is_busy : bool

var _gravity_body: GravityBody
var _state: Dictionary
var _terrain: Terrain
var _target_path: Vector3
var _target_follow : Spatial
var _moving_to_path : bool = false

onready var animation_tree: AnimationTree = $AnimationTree
onready var anim_player : AnimationPlayer = $AnimationPlayer
onready var rh_weapon_res := preload("res://scenes/weapons/1h_weapon.tscn")
onready var wall_ray_cast : RayCast = $WallRayCast
onready var attack_area : Area = $AttackArea

func _ready() -> void:

	_gravity_body = GravityBody.new(self)
	Log.ok(Systems.world.connect("cleared_path", self, "_on_path_cleared"))
	Log.ok(Systems.world.connect("selected_path", self, "_on_path_selected"))
	Log.ok(Systems.world.connect("cleared_target", self, "_on_target_cleared"))
	Log.ok(Systems.world.connect("selected_target", self, "_on_target_selected"))
	
	_terrain = Systems.world.terrain
		
	
	# GameServer.combat.combat_test()



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack") and not is_busy:
		_do_attack()


func _physics_process(delta: float) -> void:
	_gravity_body.apply(delta)
	
	if not is_busy:
		_follow_target()
		_move_to_target()
		
	_send_state()


func _do_attack() -> void:
	animation_tree.set("parameters/attack/active", true)
	for body in attack_area.get_overlapping_bodies():
		var pbody := body as PhysicsBody
		if pbody.is_in_group("Enemy"):
			Systems.combat.attack()


func _follow_target() -> void:
	if not _target_follow or _moving_to_path:
		return

	var look_at := _target_follow.translation
	look_at.y = self.translation.y
	self.look_at(look_at, Vector3.UP)
	
	if _target_follow.translation.distance_to(self.translation) < FOLLOW_MAX_DIST:
		return
	
	_target_path = _target_follow.translation


func _move_to_target() -> void:
	if _target_path.length() > 0:
		if not _moving_to_path:
			_moving_to_path = true
			animation_tree.set("parameters/speed/blend_amount", 1.0)
		
		var look_at := Vector3(_target_path.x, self.translation.y, _target_path.z)
		self.look_at(look_at, Vector3.UP)
		
		var _velocity := self.move_and_slide(-self.transform.basis.z * move_speed)

		var next_node_2d := Vector2(_target_path.x, _target_path.z)
		var transaltion_2d := Vector2(self.translation.x, self.translation.z)
		var dist := transaltion_2d.distance_to(next_node_2d)

		# TODO: Prevent player from climbing higher than 0.5
		if wall_ray_cast.is_colliding() and _gravity_body.is_grounded():
			_gravity_body.jump(jump_force)

		var following := not _target_follow == null
		var min_dist := MOVE_PATH_MIN_DIST if not following else FOLLOW_MIN_DIST

		if dist < min_dist:
			_target_path = Vector3.ZERO
	
	if _moving_to_path and _target_path == Vector3.ZERO:
		_moving_to_path = false
		animation_tree.set("parameters/speed/blend_amount", 0.0)
		Systems.world.clear_selection(false, true)


func _send_state() -> void:
	_state = {
		"T": OS.get_system_time_msecs(),
		"P": self.translation,
		"R": self.rotation_degrees
	}
	Systems.world.send_state(_state)


func _attacking_started() -> void:
	is_busy = true


func _attacking_ended() -> void:
	is_busy = false


func _on_path_cleared() -> void:
	_target_path = Vector3.ZERO


func _on_path_selected(position: Vector3) -> void:
	if not _terrain:
		return;
	
	_target_path = position


func _on_target_cleared() -> void:
	_target_follow = null


func _on_target_selected(node: Spatial, follow: bool) -> void:
	if not node or not follow:
		return;

	_target_follow = node
