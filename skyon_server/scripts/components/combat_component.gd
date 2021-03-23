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


func do_damage(other: CombatComponent) -> Dictionary:
	var dmg = other.defense - attack
	other.health -= dmg
	
	if other.health < 0:
		#Trigger death
		pass
	
	return {
		"dmg" : dmg,
	}


func is_on_attack_range(other: CombatComponent) -> bool:
	var dist := parent.translation.distance_to(other.parent.translation)
	return dist <= attack_range

