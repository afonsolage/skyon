class_name BTreeNodeLeafConditionIsGrounded
extends BTreeNodeLeafCondition

func _tick(data: Dictionary) -> int:
	var actor = data.actor
	if not actor.gravity is GravityComponent:
		Log.e("This action only works on entities with GravityComponent")
		return _failure()

	if actor.gravity.is_grounded():
		return _success()
	else:
		return _failure()
