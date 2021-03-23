extends Node

var port := 44001

var combat : CombatServer

var _net := NetworkedMultiplayerENet.new()
var _player_res: PackedScene

onready var _players = get_node("/root/GameWorld/Players")

func _ready():
	_load_resources()
	_setup()
	_start_server()


func _load_resources() -> void:
	_player_res = preload("res://scenes/characters/player.tscn")


func _setup() -> void:
	combat = CombatServer.new()
	combat.name = "CombatServer"
	add_child(combat)

func _start_server() -> void:
	Log.ok(_net.create_server(port))
	
	get_tree().set_network_peer(_net)
	
	Log.i("Server started!")
	
	Log.ok(_net.connect("peer_connected", self, "_on_peer_connected"))
	Log.ok(_net.connect("peer_disconnected", self, "_on_peer_disconnected"))


func _on_peer_connected(session_id: int) -> void:
	Log.i("[Session %d] connected!" % session_id)
	
	

func _on_peer_disconnected(session_id: int) -> void:
	Log.i("[Session %d] disconnected" % session_id)
	var player := get_node("/root/GameWorld/Players/P%d" % session_id)
	_players.remove_child(player)
	StateServer.remove_player_state(session_id)


func broadcast_states(states: Dictionary) -> void:
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
	StateServer.set_player_state(session_id, state)

