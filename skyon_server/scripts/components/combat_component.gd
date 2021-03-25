class_name CombatComponent
extends Object

var health : int = 100
var max_health : int = 100
var attack : int = 20
var defense: int = 5
var attack_range : int = 1

var parent : Spatial

func _init(parent_node: Spatial) -> void:
	if not parent_node:
		Log.d("Can't add this component to a null parent")
	parent = parent_node
