extends Node

var ip := "127.0.0.1"
var port := 44001 

var combat : CombatServer

var _net := NetworkedMultiplayerENet.new()


func _ready() -> void:
	if not GameWorld.is_on_world():
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


func _on_connection_succeeded() -> void:
	Log.i("Succesfully connected!")
	_setup()
	_join_world()


func _on_connection_failed() -> void:
	Log.e("Failed to connect")


func _setup() -> void:
	combat = CombatServer.new()
	combat.name = "CombatServer"
	add_child(combat)


func _join_world() -> void:
	rpc_id(1, "join_world")


remote func spawn_main_player(position: Vector3):
	Log.d("Spawn main player at %s" % position)
	
	var game_world := GameWorld.get_instance()
	if game_world:
		game_world.spawn_main_player(position)


func send_state(state: Dictionary) -> void:
	rpc_unreliable_id(1, "set_player_state", state)


remote func state_sync(states: Dictionary) -> void:
	StateClient.set_states(states)
