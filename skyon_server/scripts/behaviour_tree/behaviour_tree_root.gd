extends Node
class_name BehaviourTreeRoot

export(NodePath) var actor_path: NodePath
export(bool) var active := true

var _data: Dictionary = {}

func _ready():
	if self.get_child_count() != 1:
		Log.e("Behaviour tree root should only one child")
		active = false
	
	_data.actor = get_node(actor_path) as Node
	
func _process(delta: float) -> void:
	if not active:
		return
	
	_data.delta = delta
	
	self.get_child(0).tick(_data)
