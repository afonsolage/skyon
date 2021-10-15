class_name NPCSystem
extends Node

var _channel_id: int

onready var loot_bag_res := preload("res://systems/npc/nodes/loot_bag.tscn")

func _ready():
	_channel_id = Systems.get_current_channel_id(self)
	
	yield(spawn_loot_bag(Vector3(198, 5, 200)), "completed")


func spawn_loot_bag(position: Vector3) -> void:
	var item_system = Systems.get_item(_channel_id);
	
	var id = int(rand_range(1, 10000))
	var inventory = yield(item_system.create_inventory(id, 1), "completed")
	
	var loot_bag := loot_bag_res.instance() as LootBag
	loot_bag.name = "N%d" % loot_bag.get_instance_id()
	loot_bag.translate(position)
	loot_bag.inventory_id = inventory._id

	var _item1 = yield(item_system.create_item("f2a55017-3afe-457c-bbf3-ea39afecd0fa", inventory), "completed")
	var _item2 = yield(item_system.create_item("3225e9eb-8014-43a7-8e35-57b7d517b01e", inventory), "completed")

	Systems.get_world(_channel_id).add_npc(loot_bag)	


remote func interact(name: String) -> void:
	var session_id := self.get_tree().get_rpc_sender_id()
	var player = Systems.get_world(_channel_id).get_player(session_id)
	
	if not player:
		return
	
	var npc = Systems.get_world(_channel_id).get_npc(name)
	
	if npc is LootBag:
		Systems.get_item(_channel_id).show_inventory(player, npc.inventory_id)
