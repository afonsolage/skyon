class_name WorldSystem
extends Node

signal player_entered(session_id)
signal player_exited(session_id)

var map_instance: MapInstance

var _player_states: Dictionary
var _uid_cnt: int = 1

onready var _player_res = preload("res://scenes/characters/player.tscn")
onready var _players = $Players
onready var _mobs = $Mobs

func _init() -> void:
	Log.ok(Systems.net.connect("session_disconnected", self, "_on_session_disconnected"))


func _physics_process(delta: float) -> void:
	_process_gravity(delta)
	_process_player_states(_player_states.duplicate(true))
	_broadcast_states()


func setup_map_instance(map: MapComponent) -> void:
	map_instance = MapInstance.new()
	map_instance.name = "MapInstance"
	map_instance.map_component = map
	
	Log.ok(map_instance.connect("connection_area_entered", self, "_on_map_connection_area_entered"))
	
	self.add_child(map_instance)


func add_mob(mob: Spatial) -> void:
	_mobs.add_child(mob)


func has_player(session_id: int) -> bool:
	return _players.has_node("P%d" % session_id)


func get_player(session_id: int) -> Player:
	var node : Node = _players.get_node("P%d" % session_id)
	if not node:
		return null
	else:
		return node as Player


func get_mob(id: String) -> Mob:
	return _mobs.get_node(id) as Mob


func remove_player(session_id: int) -> void:
	if not _player_states.erase(session_id):
		return
	
	var player = get_player(session_id)
	if player:
		player.queue_free()
	
	self.emit_signal("player_exited", session_id)


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
		
		if not Systems.net.is_session_valid(player.session_id):
			Systems.net.disconnect_session(player.session_id)
			continue
		
		var state := {}
		for body in player.get_area_of_interest_bodies():
			if not body.is_in_group("StateSync"):
				continue
			
			state[body.name] = body.get_state()
		
		if not state.empty():
			state.T = OS.get_ticks_msec()
			rpc_unreliable_id(player.session_id, "__state_sync", state)


func _on_session_disconnected(session_id):
	remove_player(session_id)


func _on_player_area_of_interest_entered(body: PhysicsBody, player: Player) -> void:
	if not body.has_method("get_full_state"):
		Log.d("Skipping the area entered since %s doesn't have `get_full_state" % body.name)
		return

	var state: Dictionary = body.get_full_state()
	
	if Systems.net.is_session_valid(player.session_id):
		rpc_id(player.session_id, "__enter_on_area_of_interest", body.name, state)


func _on_player_area_of_interest_exited(body: PhysicsBody, player: Player) -> void:
	if not body.has_method("get_full_state"):
		Log.d("Skipping the area exited since %s doesn't have get_full_state" % body.name)
		return
	
	if Systems.net.is_session_valid(player.session_id):
		rpc_id(player.session_id, "__exit_from_area_of_interest", body.name)


func _on_map_connection_area_entered(player: Player, area_id: int) -> void:
	if area_id < 0 or area_id > HeightMapGenerator.DIRS.size():
		Log.e("Invalid area_id received (%d) for player %s on map %d" % [area_id, player, map_instance])
		return
	
	var position := map_instance.map_component.position
	var next_map_dir := HeightMapGenerator.DIRS[area_id] as Vector2
	var next_map_pos := position + next_map_dir
	
	Log.d("Moving player from map %s to map %s" % [position, next_map_pos])
	
	remove_player(player.session_id)
	Systems.channel.join_channel_map(player.session_id, next_map_pos)


remote func __join_world() -> void:
	var session_id := get_tree().get_rpc_sender_id()
	Log.i("[Session %d] joined!" % session_id)
	
	var player := _player_res.instance() as Player
	player.name = "P%d" % session_id
	player.translate(Vector3(200, 30, 200))
	player.add_to_group("StateSync")
	Log.ok(player.connect("area_of_interest_entered", 
			self, "_on_player_area_of_interest_entered", [player]))
	Log.ok(player.connect("area_of_interest_exited", 
			self, "_on_player_area_of_interest_exited", [player]))
			
	_players.add_child(player)

	rpc_id(session_id, "__spawn_main_player", Vector3(200, 30, 200), session_id)
	
	self.emit_signal("player_entered", session_id)


remote func __set_player_state(state: Dictionary) -> void:
	var session_id := get_tree().get_rpc_sender_id()
	if _player_states.has(session_id):
		var last_state: Dictionary = _player_states[session_id]
		if last_state.T > state.T:
			Log.d("Discarting state since received state is older")
			return
	elif not has_player(session_id):
		Log.d("Discarting state since player %d wasn't found")
		return
		
	_player_states[session_id] = state
