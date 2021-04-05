class_name NetSystem
extends Node

signal session_connected(session_id)
signal session_disconnected(session_id)

var port := 44001

var _net := NetworkedMultiplayerENet.new()
var _sessions := {}

func _ready():
	Log.d("Initializing Net System")
	
	_net.server_relay = false
	
	_start_server()


func _start_server() -> void:
	Log.ok(_net.create_server(port))
	
	get_tree().set_network_peer(_net)
	
	Log.i("Net Server started!")
	
	Log.ok(_net.connect("peer_connected", self, "_on_peer_connected"))
	Log.ok(_net.connect("peer_disconnected", self, "_on_peer_disconnected"))


func _on_peer_connected(session_id: int) -> void:
	Log.i("[Session %d] connected!" % session_id)
	_sessions[session_id] = null
	self.emit_signal("session_connected", session_id)
	
	# TODO: get this from the last map or something like that


func _on_peer_disconnected(session_id: int) -> void:
	Log.i("[Session %d] disconnected" % session_id)
	if _sessions.erase(session_id):
		self.emit_signal("session_disconnected", session_id)
	else:
		Log.e("Session %d not found on session list!" % session_id)


func is_session_valid(session_id: int) -> bool:
	return session_id in _sessions


func get_sessions() -> PoolIntArray:
	return get_tree().get_network_connected_peers()
