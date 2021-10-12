class_name GravityComponent
extends Object

var parent: Spatial
var jump_force := 4.0
var force := 0.0

func _init(parent_node: Spatial) -> void:
	if not parent_node:
		Log.d("Can't add this component to a null parent")
	parent = parent_node


func is_grounded() -> bool:
	return force > -0.001 and force < 0.001

func jump() -> void:
	force += jump_force
