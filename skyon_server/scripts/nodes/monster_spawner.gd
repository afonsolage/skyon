extends Node

onready var monster_res := preload("res://scenes/monster.tscn")

var _uid_cnt: int = 1

func _ready():
	var monster := monster_res.instance() as Spatial
	monster.name = "M%d" % monster.get_instance_id()
	monster.translate(Vector3(30, 10, 30))
	monster.add_to_group("StateSync")
	
	self.add_child(monster)
