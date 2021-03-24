class_name NetSystem
extends Node

signal session_connected(session_id)
signal session_disconnected(session_id)

var port := 44001

var _net := NetworkedMultiplayerENet.new()

func _ready():
	_start_server()


func _start_server() -> void:
	Log.ok(_net.create_server(port))
	
	get_tree().set_network_peer(_net)
	
	Log.i("Server started!")
	
	Log.ok(_net.connect("peer_connected", self, "_on_peer_connected"))
	Log.ok(_net.connect("peer_disconnected", self, "_on_peer_disconnected"))


func _on_peer_connected(session_id: int) -> void:
	Log.i("[Session %d] connected!" % session_id)
	self.emit_signal("session_connected")


func _on_peer_disconnected(session_id: int) -> void:
	Log.i("[Session %d] disconnected" % session_id)
	self.emit_signal("session_disconnected", session_id)


