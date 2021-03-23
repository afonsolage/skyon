extends Node

var _player_states: Dictionary

func _physics_process(_delta: float) -> void:
	_process_player_states(_player_states.duplicate(true))
	var states := _get_states()
	
	if not states.empty():
		GameServer.broadcast_states(states)


func remove_player_state(session_id: int) -> void:
	if not _player_states.erase(session_id):
		Log.e("Session id %d not found" % session_id)


func set_player_state(session_id: int, state: Dictionary) -> void:
	if _player_states.has(session_id):
		var last_state: Dictionary = _player_states[session_id]
		if last_state.T > state.T:
			return
	
	_player_states[session_id] = state


func _process_player_states(state_snap: Dictionary) -> void:
	for session_id in state_snap:
		var state: Dictionary = state_snap[session_id]
		var player = get_node("/root/GameWorld/Players/P%d" % session_id) as Spatial
		if not player.move(state.P as Vector3):
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
