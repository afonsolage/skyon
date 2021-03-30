class_name BTreeNodeLeafActionMoveToTarget
extends BTreeNodeLeafAction

export(float) var move_speed: float = 2.0
export(float) var reach_distance: float = 1.0

func _tick(data: Dictionary) -> int:
	var target = _get_global(data, "target") as Vector3
	if not target:
		Log.e("Not target found!")
		return _failure()

	var actor = data.actor
	if not actor is KinematicBody:
		Log.e("This action can only moves KinematicBody")
		return _failure()

	var body := actor as KinematicBody
	var _velocity = body.move_and_slide(-body.transform.basis.z * move_speed)

	var target_2d := Vector2(target.x, target.z)
	var transaltion_2d := Vector2(body.translation.x, body.translation.z)
	var dist := transaltion_2d.distance_to(target_2d)

	if dist > reach_distance:
		return _running()
	else:
		return _success()

