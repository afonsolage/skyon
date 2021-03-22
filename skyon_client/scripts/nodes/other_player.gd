extends KinematicBody

export(float) var move_speed := 3.0
export(float) var boost_speed := 6.0
export(float) var turn_speed := 3.0
export(float) var jump_force := 5.0

onready var animation_tree: AnimationTree = $AnimationTree

func _ready():
	pass # Replace with function body.

