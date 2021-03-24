class_name WorldSystem
extends Node

var _player_states: Dictionary
var _uid_cnt: int = 1

onready var _player_res = preload("res://scenes/characters/player.tscn")
onready var _players = $Players
onready var _monsters = $Monsters
onready var monster_res := preload("res://scenes/monsters/monster.tscn")


func _ready():
	var monster := monster_res.instance() as Spatial
	monster.name = "M%d" % monster.get_instance_id()
	monster.translate(Vector3(30, 10, 30))
	monster.add_to_group("StateSync")
	
	_monsters.add_child(monster)
	


func _physics_process(_delta: float) -> void:
	_process_player_states(_player_states.duplicate(true))
	var states := _get_states()
	
	if not states.empty():
		_broadcast_states(states)


func get_player(session_id: int) -> Player:
	var node : Node = _players.get_node("P%d" % session_id)
	if not node:
		return null
	else:
		return node as Player


func remove_player_state(session_id: int) -> void:
	if not _player_states.erase(session_id):
		Log.e("Session id %d not found" % session_id)
	
	var player = get_player(session_id)
	if player:
		player.queue_free()


func _process_player_states(state_snap: Dictionary) -> void:
	for session_id in state_snap:
		var state: Dictionary = state_snap[session_id]
		var player = get_player(session_id)
		if player and not player.move(state.P as Vector3):
			# TODO: Reject the new state
			Log.e("Invalid player %d state %s" % [session_id, state])


func _get_states() -> Dictionary:
	var states = {}
	var sync_nodes: Array = get_tree().get_nodes_in_group("StateSync")
	
	if not sync_nodes.empty():
		for node in sync_nodes:
			var spatial = node as Spatial
			states[spatial.name] = spatial.get_state()
		
		states.T = OS.get_ticks_msec()
	
	return states


func _broadcast_states(states: Dictionary) -> void:
	var peers := get_tree().get_network_connected_peers()
	for peer in peers:
		rpc_unreliable_id(peer, "state_sync", states)


remote func join_world() -> void:
	var session_id := get_tree().get_rpc_sender_id()
	Log.i("[Session %d] joined!" % session_id)
	
	var player := _player_res.instance() as Spatial
	player.name = "P%d" % session_id
	player.translate(Vector3(30, 30, 30))
	player.add_to_group("StateSync")
	
	_players.add_child(player)

	rpc_id(session_id, "spawn_main_player", Vector3(30, 10, 30))


remote func set_player_state(state: Dictionary) -> void:
	var session_id := get_tree().get_rpc_sender_id()
	if _player_states.has(session_id):
		var last_state: Dictionary = _player_states[session_id]
		if last_state.T > state.T:
			return
	
	_player_states[session_id] = state



func _on_session_disconnected(session_id):
	remove_player_state(session_id)

