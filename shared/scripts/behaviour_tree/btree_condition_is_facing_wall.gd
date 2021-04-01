class_name BTreeNodeLeafConditionIsFacingWall
extends BTreeNodeLeafCondition

export(NodePath) var wall_ray_cast_path: NodePath

var _wall_ray_cast: RayCast

func _ready():
	_wall_ray_cast = get_node(wall_ray_cast_path) as RayCast


func _tick(_data: Dictionary) -> int:
	if _wall_ray_cast.is_colliding():
		return _success()
	else:
		return _failure()
	
