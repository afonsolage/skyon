class_name BTreeNodeLeafActionTargetEnemy
extends BTreeNodeLeafAction

func _tick(data: Dictionary) -> int:
	var enemy = _get_global(data, "enemy") as Spatial
	
	if not enemy:
		return _failure()
	
	var target := enemy.global_transform.origin as Vector3
	
	_set_global(data, "move_target", target)
	
	return _success()
