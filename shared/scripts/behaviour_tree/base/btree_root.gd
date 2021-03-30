extends Node
class_name BTreeRoot, "./icons/root.png"

export(NodePath) var actor_path: NodePath
export(bool) var active := true

var _data: Dictionary = {}

func _ready():
	if self.get_child_count() != 1:
		Log.e("Behaviour tree root should only one child")
		active = false
	
	var actor := get_node(actor_path) as Spatial
	_data.actor = actor
	_data.original_position = actor.global_transform.origin
	_data.root_parent = self.get_parent()
	
func _physics_process(delta: float) -> void:
	if not active:
		return
	
	_data.delta = delta
	
	self.get_child(0)._tick(_data)
