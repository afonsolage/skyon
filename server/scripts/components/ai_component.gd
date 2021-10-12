class_name AIComponent
extends Object



var parent : Spatial
var state: int #enum is just a dictionary of ints
var next_state: float
var original_position: Vector3

var _wall_raycast: RayCast

func _init(parent_node: Spatial) -> void:
	if not parent_node:
		Log.d("Can't add this component to a null parent")
	parent = parent_node
	
	original_position = parent.translation
	_wall_raycast = load("res://scenes/components/wall_raycast.tscn").instance()
	parent_node.add_child(_wall_raycast)


func is_on_wall() -> bool:
	return _wall_raycast.is_colliding()
