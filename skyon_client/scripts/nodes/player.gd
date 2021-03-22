extends KinematicBody

export(float) var move_speed := 3.0
#export(float) var boost_speed := 6.0
#export(float) var turn_speed := 3.0
export(float) var jump_force := 4.0

onready var animation_tree: AnimationTree = $AnimationTree
onready var rh_weapon_res := preload("res://scenes/weapons/1h_weapon.tscn")
onready var model_skeleton: Skeleton = $Body/Model/base_character/Armature/Skeleton
onready var wall_ray_cast : RayCast = $WallRayCast

var _gravity_body: GravityBody
var _state: Dictionary
var _terrain: Terrain
var _target_path: Vector3
var _moving_to_path : bool = false
#var _nav_path : PoolVector3Array
#var _next_node : Vector3 = Vector3.ZERO

#var _im := ImmediateGeometry.new()

func _ready() -> void:
#	add_child(_im)
	_gravity_body = GravityBody.new(self)
	var game_world := GameWorld.get_instance()
	if game_world:
		game_world.connect("cleared_path", self, "_on_path_cleared")
		game_world.connect("selected_path", self, "_on_path_selected")
		_terrain = game_world.terrain
		
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and _gravity_body.is_grounded():
		_gravity_body.jump(jump_force)
		
	if event.is_action_pressed("attack"):
		animation_tree.set("parameters/attack/active", true)


#func _process(delta: float) -> void:
#	if _nav_path and not _nav_path.empty():
#		_im.clear()
#		_im.begin(Mesh.PRIMITIVE_LINES)
#		_im.set_color(Color.purple)
#		for p in _nav_path:
#			_im.add_vertex(self.to_local(p))
#		_im.end()

func _physics_process(delta: float) -> void:
	_gravity_body.apply(delta)
#	_move()
#	_rotate()
	#_move_path()
	_move_to_target()
	_send_state()

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

#func _move_path() -> void:
#	if _next_node.length() > 0:
#		self.move_and_slide(-self.transform.basis.z * move_speed)
#
#		var next_node_2d := Vector2(_next_node.x, _next_node.z)
#		var transaltion_2d := Vector2(self.translation.x, self.translation.z)
#		var dist := transaltion_2d.distance_to(next_node_2d)
#
#		if wall_ray_cast.is_colliding() and _gravity_body.is_grounded():
#			_gravity_body.jump(jump_force)
#
#		if dist < 0.1:
#			_next_node = Vector3.ZERO
#			if _nav_path.empty():
#				animation_tree.set("parameters/speed/blend_amount", 0.0)
#
#	if _nav_path and not _nav_path.empty() and _next_node.length() == 0:
#		_next_node = _nav_path[0]
#		_nav_path.remove(0)
#
#		var look_at := Vector3(_next_node.x, self.translation.y, _next_node.z)
#		self.look_at(look_at, Vector3.UP)
#		animation_tree.set("parameters/speed/blend_amount", 1.0)
#
#
#func _move() -> void:
#	var move_vector: Vector3
#
#	if Input.is_action_pressed("move_forward"):
#		move_vector += self.transform.basis.z
#	elif Input.is_action_pressed("move_backward"):
#		move_vector -= self.transform.basis.z
#
#	move_vector = move_vector.normalized()
#	var move_length := move_vector.length()
#	animation_tree.set("parameters/speed/blend_amount", move_length)
#
#	if move_length > 0.1:
#		if (Input.is_action_pressed("boost_speed")):
#			self.move_and_slide(move_vector * boost_speed)
#			animation_tree.set("parameters/run_scale/scale", 1.5)
#		else:
#			self.move_and_slide(move_vector * move_speed)
#			animation_tree.set("parameters/run_scale/scale", 1.0)
#
#
#func _rotate() -> void:
#	var rotation_vector: Vector3
#
#	if Input.is_action_pressed("turn_right"):
#		rotation_vector.y -= 1
#	elif Input.is_action_pressed("turn_left"):
#		rotation_vector.y += 1
#
#	if rotation_vector.length() > 0.1:
#		self.rotation_degrees += rotation_vector * turn_speed


func _send_state() -> void:
	_state = {
		"T": OS.get_system_time_msecs(),
		"P": self.global_transform.origin
	}
	GameServer.send_state(_state)


func _on_path_cleared() -> void:
	_target_path = Vector3.ZERO


func _on_path_selected(position: Vector3) -> void:
	if not _terrain:
		return;
	
	_target_path = position
	
#	_next_node = Vector3.ZERO
#	_nav_path = _terrain.find_path_to(self.global_transform.origin, position)
