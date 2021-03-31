class_name BTreeNodeLeafActionTargetEnemy
extends BTreeNodeLeafAction

export(float) var target_offset = 1

func _tick(data: Dictionary) -> int:
	var enemy = _get_global(data, "enemy") as Spatial
	
	if not enemy:
		return _failure()
	
	var target := enemy.global_transform.origin as Vector3
	var current_pos := data.actor.global_transform.origin as Vector3
	
	var dir = target.direction_to(current_pos)
	target += dir * target_offset
	
	_set_global(data, "target", target)
	
	return _success()
