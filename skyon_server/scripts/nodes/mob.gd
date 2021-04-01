class_name Mob
extends KinematicBody

export(float) var move_speed := 1.0

onready var combat := CombatComponent.new(self)
onready var gravity := GravityComponent.new(self)

var current_action: String = "Idle"

func get_state() -> Dictionary:
	return {
		"P": self.translation,
		"R": self.rotation_degrees,
		"A": current_action
	}


func get_full_state() -> Dictionary:
	return {
		"S": get_state(),
		"C": combat.encode(),
	}

