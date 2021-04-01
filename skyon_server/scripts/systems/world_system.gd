class_name WorldSystem
extends Node

var _player_states: Dictionary
var _uid_cnt: int = 1

onready var _player_res = preload("res://scenes/characters/player.tscn")
onready var _players = $Players
onready var _mobs = $Mobs


func _physics_process(delta: float) -> void:
	_process_gravity(delta)
	_process_player_states(_player_states.duplicate(true))
	_broadcast_states()


func add_mob(mob: Spatial) -> void:
	_mobs.add_child(mob)


func get_player(session_id: int) -> Player:
	var node : Node = _players.get_node("P%d" % session_id)
	if not node:
		return null
	else:
		return node as Player


func get_mob(id: String) -> Mob:
	return _mobs.get_node(id) as Mob


func remove_player_state(session_id: int) -> void:
	if not _player_states.erase(session_id):
		Log.e("Session id %d not found" % session_id)
	
	var player = get_player(session_id)
	if player:
		player.queue_free()


func list_monsters() -> Array:
	return _mobs.get_children()


func _process_player_states(state_snap: Dictionary) -> void:
	for session_id in state_snap:
		var state: Dictionary = state_snap[session_id]
		var player := get_player(session_id)
		# TODO: Reject the new state if it's invalid
		player.set_state(state)


func _process_gravity(delta: float) -> void:
	var bodies := []
	bodies += _mobs.get_children()
	bodies += _players.get_children()
	
	var magnitude = ProjectSettings.get_setting("physics/3d/default_gravity")
	for body in bodies:
		body.gravity.force -= magnitude * delta
		var gravity = Vector3(0, body.gravity.force, 0)
		body.gravity.force = body.move_and_slide(gravity, Vector3.UP).y


func _broadcast_states() -> void:
	for player in _players.get_children():
		player = player as Player
		
		var state := {}
		for body in player.get_area_of_interest_bodies():
			if not body.is_in_group("StateSync"):
				continue
			
			state[body.name] = body.get_state()
		
		if not state.empty():
			state.T = OS.get_ticks_msec()
			rpc_unreliable_id(player.session_id, "__state_sync", state)


remote func join_world() -> void:
	var session_id := get_tree().get_rpc_sender_id()
	Log.i("[Session %d] joined!" % session_id)
	
	var player := _player_res.instance() as Player
	player.name = "P%d" % session_id
	player.translate(Vector3(30, 30, 30))
	player.add_to_group("StateSync")
	Log.ok(player.connect("area_of_interest_entered", 
			self, "_on_player_area_of_interest_entered", [player]))
	Log.ok(player.connect("area_of_interest_exited", 
			self, "_on_player_area_of_interest_exited", [player]))
			
	_players.add_child(player)

	rpc_id(session_id, "__spawn_main_player", Vector3(30, 10, 30))


remote func set_player_state(state: Dictionary) -> void:
	var session_id := get_tree().get_rpc_sender_id()
	if _player_states.has(session_id):
		var last_state: Dictionary = _player_states[session_id]
		if last_state.T > state.T:
			return
	
	_player_states[session_id] = state


func _on_session_disconnected(session_id):
	remove_player_state(session_id)


func _on_player_area_of_interest_entered(body: PhysicsBody, player: Player) -> void:
	if not body.has_method("get_full_state"):
		Log.d("Skipping the area entered since %s doesn't have `get_full_state" % body.name)
		return

	var state: Dictionary = body.get_full_state()
	rpc_id(player.session_id, "__enter_on_area_of_interest", body.name, state)


func _on_player_area_of_interest_exited(body: PhysicsBody, player: Player) -> void:
	if not body.has_method("get_full_state"):
		Log.d("Skipping the area exited since %s doesn't have get_full_state" % body.name)
		return
	
	rpc_id(player.session_id, "__exit_from_area_of_interest", body.name)
