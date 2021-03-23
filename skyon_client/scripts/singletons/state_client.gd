extends Node

var last_state_time : int = 0

onready var _monster_res := preload("res://scenes/monsters/monster.tscn")

func set_states(states: Dictionary) -> void:
	if states.T < last_state_time:
		Log.d("Discarting outdated states: %s" % [states])
	else:
		last_state_time = states.T
	
	var _erased := states.erase("T")
	
	for state in states:
		var type: String = state.left(1)
		if type == "P":
			_set_player_state(state, states[state])
		elif type == "M":
			_set_monster_state(state, states[state])


func _set_player_state(_id: String, _state: Dictionary):
	# TODO: set other players state
	pass


func _set_monster_state(id: String, state: Dictionary):
	var game_world = GameWorld.get_instance()
	var monster: Spatial = game_world.monsters.get_node_or_null("%s" % id)
	
	if not monster:
		monster = _monster_res.instance()
		monster.name = id
		game_world.monsters.add_child(monster)
	else:
		monster = monster as Spatial
	
	monster.set_state(state)
