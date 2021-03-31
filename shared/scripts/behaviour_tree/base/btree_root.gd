extends Node
class_name BTreeRoot, "./icons/root.png"

export(NodePath) var actor_path: NodePath
export(bool) var active := true
export(bool) var enable_debug_nodes := true
export(float) var tick_every := 1.0 / 60.0

var _data: Dictionary = {}
var _elapsed: float

func _ready():
	if self.get_child_count() != 1:
		Log.e("Behaviour tree root should have one child")
		active = false
	
	var actor := get_node(actor_path) as Spatial
	_data.actor = actor
	_data.original_position = actor.global_transform.origin
	_data.root_parent = self.get_parent()
	_data.debug = enable_debug_nodes
	
func _physics_process(delta: float) -> void:
	if not active:
		return
	
	_elapsed += delta
	
	if _elapsed < tick_every:
		return
	
	_data.delta = _elapsed
	_elapsed = 0
	
	self.get_child(0)._tick(_data)
