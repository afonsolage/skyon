extends "res://addons/gut/test.gd"

var combat: CombatComponent

func before_each() -> void:
	var dummy = Spatial.new()
	add_child(dummy)
	combat = CombatComponent.new(dummy)

