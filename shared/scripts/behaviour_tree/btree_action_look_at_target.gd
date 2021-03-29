class_name BTreeNodeLeafActionLookAtTarget
extends BTreeNodeLeafAction

func _tick(data: Dictionary) -> int:
	var target := _get_global(data, "target") as Vector3
	if not target:
		Log.d("Not target found!")
		return _failure()
	
	var actor = data.actor
	if not actor is Spatial:
		Log.e("This action can only work on Spatial")
		return _failure()
	
	var actor_spatial := actor as Spatial
	var look_at := target
	look_at.y = actor_spatial.translation.y
	actor_spatial.look_at(look_at, Vector3.UP)
	
	return _success()
