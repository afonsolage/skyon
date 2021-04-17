class_name WorldSystem
extends Node

var main_player : MainPlayer
var map_instance: MapInstance

var _last_state_time : int = 0


onready var _mobs: Node = $Mobs
onready var _mob_res := preload("res://scenes/mobs/mob.tscn")

func _ready() -> void:
	Log.d("Initializing World System")
	rpc_id(1, "__join_world")


func _physics_process(delta: float) -> void:
	_process_gravity(delta)
	_send_state()


func set_map_instance(instance: MapInstance) -> void:
	map_instance = instance
	self.add_child(instance)


func get_camera() -> Camera:
	return get_viewport().get_camera()


func get_spatial(id: String) -> Spatial:
	var type := id.left(1)
	match type:
		"P":
			if int(id.right(1)) == main_player.session_id:
				return main_player
			else:
				return null
		"M":
			return _mobs.get_node(id) as Spatial
		_:
			Log.e("Unknown spatial type on id %s" % id)

	return null


func has_spatial(id: String) -> bool:
	var type := id.left(1)
	match type:
		"P":
			#Not yet implemented!
			pass
		"M":
			return _mobs.has_node(id)
		_:
			Log.e("Unknown spatial type on id %s" % id)

	return false


func _send_state() -> void:
	if not main_player:
		return
		
	var state := main_player.get_state()
	state.T = OS.get_ticks_msec()
	rpc_unreliable_id(1, "__set_player_state", state)


func _process_gravity(delta: float) -> void:
	var magnitude = ProjectSettings.get_setting("physics/3d/default_gravity")
	if main_player:
		main_player.gravity.force -= magnitude * delta
		var gravity = Vector3(0, main_player.gravity.force, 0)
		main_player.gravity.force = main_player.move_and_slide(gravity, Vector3.UP, true).y


func _set_player_state(_id: String, _state: Dictionary):
	# TODO: set other players state
	pass


func _set_mob_state(id: String, state: Dictionary) -> void:
	var mob: Spatial = _mobs.get_node_or_null("%s" % id)
	
	if not mob:
		Log.d("Unable to set state. Mob %s not found" % id)
		return
	
	mob.set_state(state)


func _spawn(id: String, state: Dictionary) -> void:
	var type := id.left(1)

	match type:
		"P":
			#Not yet implemented!
			pass
		"M":
			_spawn_mob(id, state)
		_:
			Log.e("Unknown spatial type on id %s" % id)


func _spawn_mob(id: String, state: Dictionary) -> void:
	var mob := _mob_res.instance()
	mob.name = id

	_mobs.add_child(mob)
	
	mob.set_full_state(state)


remote func __state_sync(states: Dictionary) -> void:
	if states.T < _last_state_time:
		Log.d("Discarting outdated states: %s" % [states])
	else:
		_last_state_time = states.T
	
	var _erased := states.erase("T")
	
	for state in states:
		var type: String = state.left(1)
		match type:
			"P":
				_set_player_state(state, states[state])
			"M":
				_set_mob_state(state, states[state])
			_:
				Log.e("Unknown spatial type on id %s" % state)


remote func __enter_on_area_of_interest(id: String, state: Dictionary) -> void:
	if has_spatial(id):
		Log.e("There is already an spatial with the id %s " % id)
		return

	_spawn(id, state)


remote func __exit_from_area_of_interest(id: String) -> void:
	var spatial := get_spatial(id)
	if spatial:
		spatial.queue_free()


remote func __spawn_main_player(position: Vector3, session_id: int) -> void:
	main_player = load("res://scenes/characters/main_player.tscn").instance() as Spatial
	main_player.name = "Main Player"
	main_player.session_id = session_id
	main_player.translate(position)

	self.add_child(main_player)

