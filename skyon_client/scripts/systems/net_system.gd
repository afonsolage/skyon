class_name NetSystem
extends NodeSystem

signal session_started()
signal session_ended()

var ip := "127.0.0.1"
var port := 44001 

var _net := NetworkedMultiplayerENet.new()

static func instance() -> NetSystem:
	if not is_on_world():
		Log.e("The game server isn't loaded. You can't call it from here.")
		return null
	else:
		return _get_root().get_node("/root/Main/NetSystem") as NetSystem

func _ready() -> void:
	if not  is_on_world():
		Log.e("You are not in a world. Skipping networking.")
		return;
		
	_connect_to_server()


func _connect_to_server() -> void:
	Log.ok(_net.create_client(ip, port))
	get_tree().set_network_peer(_net)
	
	Log.ok(_net.connect("connection_succeeded", self, "_on_connection_succeeded"))
	Log.ok(_net.connect("connection_failed", self, "_on_connection_failed"))
	Log.ok(_net.connect("server_disconnected", self, "_on_connection_lost"))


func _on_connection_lost() -> void:
	Log.e("Connection lost!")
	self.emit_signal("session_ended")


func _on_connection_succeeded() -> void:
	Log.i("Succesfully connected!")
	self.emit_signal("session_started")


func _on_connection_failed() -> void:
	Log.e("Failed to connect")




