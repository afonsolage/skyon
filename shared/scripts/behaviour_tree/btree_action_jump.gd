extends BTreeNodeLeafAction

export(float) var jump_force: float = 4.0

func _tick(data: Dictionary) -> int:
	var actor = data.actor
	if not actor.gravity is GravityComponent:
		Log.e("This action only works on entities with GravityComponent")
		return _failure()

	actor.gravity.force += jump_force
	
	return _success()
