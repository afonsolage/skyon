class_name MobSystem
extends Node

var _channel_id: int

onready var mob_res := preload("res://systems/mob/nodes/mob.tscn")

func _ready():
	_channel_id = Systems.get_current_channel_id(self)
	

func spawn_mob():
	var mob := mob_res.instance() as Spatial
	mob.name = "M%d" % mob.get_instance_id()
	mob.translate(Vector3(30, 10, 30))
	mob.add_to_group("StateSync")

	Systems.get_world(_channel_id).add_mob(mob)	


func despawn_mob(id: String):
	var mob := Systems.get_world(_channel_id).get_mob(id) as Mob
	mob.queue_free()


func _on_CombatSystem_died(killed, _killer):
	if not killed is Mob:
		return

	killed.die()
	# TODO: Add loot, exp, and such
	
	yield(get_tree().create_timer(3), "timeout")
	despawn_mob(killed.name)
