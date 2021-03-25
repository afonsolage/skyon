class_name MonsterSystem
extends Node

onready var monster_res := preload("res://scenes/monsters/monster.tscn")

func _ready():
	spawn_monster()


func spawn_monster():
	var monster := monster_res.instance() as Spatial
	monster.name = "M%d" % monster.get_instance_id()
	monster.translate(Vector3(30, 10, 30))
	monster.add_to_group("StateSync")

	Systems.world.add_monster(monster)	


func despawn_monster(id: String):
	var monster := Systems.world.get_monster(id)
	monster.queue_free()


func _on_CombatSystem_died(killed, killer):
	if not killed is Monster:
		return

	# TODO: Add loot, exp, and such
	despawn_monster(killed.name)
