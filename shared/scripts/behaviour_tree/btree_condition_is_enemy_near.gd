class_name BTreeNodeLeafConditionIsEnemyNear
extends BTreeNodeLeafCondition

export(NodePath) var aggro_area_path: NodePath

var _aggro_area: Area

func _ready() -> void:
	_aggro_area = get_node(aggro_area_path) as Area


func _tick(data: Dictionary) -> int:
	for body in _aggro_area.get_overlapping_bodies():
		if body == data.actor:
			continue
		
		# TODO: Check for groups
		
		_set_global(data, "enemy", body)
		return _success()
	
	return _failure()
