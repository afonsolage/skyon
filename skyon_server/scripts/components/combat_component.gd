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


func encode() -> Dictionary:
	return {
		"H": health,
		"MH": max_health,
		"A": attack,
		"D": defense,
		"AR": attack_range,
	}


func decode(state: Dictionary) -> void:
	health = state.H
	max_health = state.MH
	attack = state.A
	defense = state.D
	attack_range = state.AR


func is_alive() -> bool:
	return health > 0
