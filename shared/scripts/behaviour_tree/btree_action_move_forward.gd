class_name BTreeNodeLeafActionMoveFoward
extends BTreeNodeLeafAction

export(float) var move_speed: float = 2.0
export(float) var reach_distance: float = 1.0

func _tick(data: Dictionary) -> int:
	if not _has_global(data, "target"):
		Log.e("Not target found!")
		return _failure()

	var actor = data.actor
	if not actor is KinematicBody:
		Log.e("This action can only moves KinematicBody")
		return _failure()

	var body := actor as KinematicBody
	var _velocity = body.move_and_slide(-body.transform.basis.z * move_speed)

	return _running()
