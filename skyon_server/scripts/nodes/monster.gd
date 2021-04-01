class_name Monster
extends KinematicBody

export(float) var move_speed := 1.0

onready var combat := CombatComponent.new(self)
onready var gravity := GravityComponent.new(self)

func get_state() -> Dictionary:
	return {
		"P": self.translation,
		"R": self.rotation_degrees,
		"A": 0, # TODO: Change this for animation
	}


func get_full_state() -> Dictionary:
	return {
		"S": get_state(),
		"C": combat.encode(),
	}

