extends Camera

export(NodePath) var _follow_target_path : NodePath

onready var _follow_target : Spatial = get_node(_follow_target_path) as Spatial

var _offset : Vector3

func _ready():
	_offset = _follow_target.transform.origin - self.transform.origin
	print(_offset)

func _physics_process(delta):
	self.transform.origin = _follow_target.transform.origin - _offset
	pass
