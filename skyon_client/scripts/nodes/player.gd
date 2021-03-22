extends KinematicBody

export(float) var move_speed := 3.0
export(float) var jump_force := 4.0

var is_busy : bool

var _gravity_body: GravityBody
var _state: Dictionary
var _terrain: Terrain
var _target_path: Vector3
var _moving_to_path : bool = false

onready var animation_tree: AnimationTree = $AnimationTree
onready var anim_player : AnimationPlayer = $AnimationPlayer
onready var rh_weapon_res := preload("res://scenes/weapons/1h_weapon.tscn")
onready var wall_ray_cast : RayCast = $WallRayCast

func _ready() -> void:

	_gravity_body = GravityBody.new(self)
	var game_world := GameWorld.get_instance()
	if game_world:
		game_world.connect("cleared_path", self, "_on_path_cleared")
		game_world.connect("selected_path", self, "_on_path_selected")
		_terrain = game_world.terrain



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack") and not is_busy:
		_do_attack()


func _physics_process(delta: float) -> void:
	_gravity_body.apply(delta)
	
	if not is_busy:
		_move_to_target()
		
	_send_state()


func _do_attack() -> void:
	
	
	animation_tree.set("parameters/attack/active", true)
	
	pass


func _move_to_target() -> void:
	if _target_path.length() > 0:
		if not _moving_to_path:
			_moving_to_path = true
			animation_tree.set("parameters/speed/blend_amount", 1.0)
		
		var look_at := Vector3(_target_path.x, self.translation.y, _target_path.z)
		self.look_at(look_at, Vector3.UP)
		
		self.move_and_slide(-self.transform.basis.z * move_speed)

		var next_node_2d := Vector2(_target_path.x, _target_path.z)
		var transaltion_2d := Vector2(self.translation.x, self.translation.z)
		var dist := transaltion_2d.distance_to(next_node_2d)

		# TODO: Prevent player from climbing higher than 0.5
		if wall_ray_cast.is_colliding() and _gravity_body.is_grounded():
			_gravity_body.jump(jump_force)

		if dist < 0.1:
			_target_path = Vector3.ZERO
	
	if _moving_to_path and _target_path.length() < 0.01:
		_moving_to_path = false
		animation_tree.set("parameters/speed/blend_amount", 0.0)
		GameWorld.get_instance().clear_selection(false, true)


func _send_state() -> void:
	_state = {
		"T": OS.get_system_time_msecs(),
		"P": self.global_transform.origin
	}
	GameServer.send_state(_state)


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
