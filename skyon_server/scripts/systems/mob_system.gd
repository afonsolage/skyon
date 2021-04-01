class_name MobSystem
extends Node

onready var mob_res := preload("res://scenes/mobs/mob.tscn")

func _ready():
	spawn_mob()


func spawn_mob():
	var mob := mob_res.instance() as Spatial
	mob.name = "M%d" % mob.get_instance_id()
	mob.translate(Vector3(30, 10, 30))
	mob.add_to_group("StateSync")

	Systems.world.add_mob(mob)	


func despawn_mob(id: String):
	var mob := Systems.world.get_mob(id)
	mob.queue_free()


func _on_CombatSystem_died(killed, _killer):
	if not killed is Mob:
		return

	killed.die()
	# TODO: Add loot, exp, and such
	
	yield(get_tree().create_timer(3), "timeout")
	despawn_mob(killed.name)
