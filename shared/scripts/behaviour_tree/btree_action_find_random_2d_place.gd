class_name BTreeNodeLeafActionFindRandom2DPlace
extends BTreeNodeLeafAction

export(float) var max_radius:float = 5.0
export(float) var min_radius:float = 2.0

func _tick(data: Dictionary) -> int:
	var actor := data.actor as Spatial	
	
	var origin := actor.translation
	var offset := Vector3(
			rand_range(-min_radius / 2.0, max_radius / 2.0), 
			origin.y, 
			rand_range(-min_radius / 2.0, max_radius / 2.0))
	
	var target := origin + offset
	
	Log.d("Found target: %s " % target)
	_set_global(data, "target", target)
	
	return _success()
