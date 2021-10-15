class_name ItemSystem
extends Node

const ITEMS_PATH := "res://assets/resources/items.res"

var _resources := {}

func _ready() -> void:
	_load_resources()


func get_resource(uuid: String) -> ItemResource:
	return _resources[uuid]


func _load_resources() -> void:
	if not FileUtils.exists(ITEMS_PATH):
		Log.e("Items resource not found %s" % ITEMS_PATH)
	
	var file := File.new()
	Log.ok(file.open(ITEMS_PATH, File.READ))
	var items := parse_json(file.get_as_text()) as Array
	file.close()
	
	for item_dict in items:
		var item_resource := dict2inst(item_dict) as ItemResource
		Serializer.fix_ints(item_resource)
		_resources[item_resource.uuid] = item_resource
	
	Log.d("Loaded %d item resources" % _resources.size())


func _parse_item_instance(dict: Dictionary) -> ItemInstance:
	var instance = ItemInstance.new()
	
	for k in dict:
		if k == "resource":
			instance.resource = get_resource(dict[k])
		else:
			instance.set(k, dict[k])
		
	
	return instance


remote func show_inventory(inventory: Dictionary) -> void:
	# TODO: Show inventory based on received items
	Log.d("Inventory received: %s" % inventory)
	
	var instances = []
	for item in inventory.items:
		instances.push_back(_parse_item_instance(item))

	var inventory_window = Systems.ui.show_window(Systems.ui.Window.INVENTORY) as InventoryWindow
	inventory_window.set_items(instances)
