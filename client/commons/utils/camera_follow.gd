extends Camera

export(NodePath) var _follow_target_path : NodePath
export(Vector3) var offset : Vector3

var _follow_target : Spatial

func _physics_process(_delta):
	if not _follow_target:
		if not Systems.world:
			return
			
		_follow_target = Systems.world.main_player
	else:
		self.transform.origin = _follow_target.transform.origin - offset


