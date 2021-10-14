class_name NPCSystem
extends Node

var _channel_id: int

onready var loot_bag_res := preload("res://systems/npc/nodes/loot_bag.tscn")

func _ready():
	_channel_id = Systems.get_current_channel_id(self)
	
	spawn_loot_bag(Vector3(198, 5, 200))


func spawn_loot_bag(position: Vector3) -> void:
	var loot_bag := loot_bag_res.instance() as Spatial
	loot_bag.name = "N%d" % loot_bag.get_instance_id()
	loot_bag.translate(position)

	Systems.get_world(_channel_id).add_npc(loot_bag)	

