class_name BTreeNodeLeafConditionIsTargetReached
extends BTreeNodeLeafCondition

export(float) var reach_distance: float = 1.0

func _tick(data: Dictionary) -> int:
	var target := _get_global(data, "move_target") as Vector3
	if not target:
		Log.e("Not target found!")
		return _failure()
	
	var actor = data.actor
	if not actor is Spatial:
		Log.e("This condition can only work on Spatial")
		return _failure()

	var body := actor as Spatial
	
	var target_2d := Vector2(target.x, target.z)
	var transaltion_2d := Vector2(body.translation.x, body.translation.z)
	var dist := transaltion_2d.distance_to(target_2d)

	if dist > reach_distance:
		return _failure()
	else:
		return _success()
