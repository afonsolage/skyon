class_name LootBag
extends KinematicBody

var inventory_id: int

func _to_string() -> String:
	return self.name


func get_state() -> Dictionary:
	return {
		"P": self.translation,
	}


func get_full_state() -> Dictionary:
	return {
		"S": get_state(),
	}
