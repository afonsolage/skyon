class_name BTreeNodeLeafActionFindRandom2DPlace
extends BTreeNodeLeafAction

export(float) var max_radius: float = 5.0
export(float) var min_radius: float = 2.0
export(bool) var keep_origin: bool = true

func _tick(data: Dictionary) -> int:
	var actor := data.actor as Spatial	
	
	var origin := data.original_position as Vector3 if keep_origin else actor.translation
	var offset := Vector3(
			rand_range(-min_radius / 2.0, max_radius / 2.0), 
			origin.y, 
			rand_range(-min_radius / 2.0, max_radius / 2.0))

	if offset.length() < min_radius:
		offset += offset * (min_radius - offset.length())
	elif offset.length() > max_radius:
		offset -= offset * (offset.length() - max_radius)
		
	var target := origin + offset
	
	_set_global(data, "target", target)
	
	return _success()
