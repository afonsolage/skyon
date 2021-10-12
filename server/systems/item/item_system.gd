class_name ItemSystem
extends Node

const ITEMS_PATH := "res://resources/items.res"

var _resources := {}
var _instances := {}

func _ready() -> void:
	_load_resources()
	_load_instances()


func find_resource_by_name(name: String) -> ItemResource:
	for item in _resources.values():
		if item.name == name:
			return item
	
	return null


func create_item(resource_uuid: String, tier: int = 0, quality: int = -1) -> ItemInstance:
	if not _resources.has(resource_uuid):
		Log.e("Failed to find item with uuid %s" % resource_uuid)
		return null 
	
	var item_properties = _randomize_item(_resources[resource_uuid], tier, quality)
	item_properties.resource_uuid = resource_uuid
	
	
	return _insert_item(item_properties)


func _randomize_item(item_resource: ItemResource, tier: int, quality: int) -> Dictionary:
	var item = {}
	item.tier = tier
	
	#TODO: Randomize item based on configuration
	var rnd := RandomNumberGenerator.new()
	rnd.randomize()
	
	if quality == -1:
		var r := rnd.randi_range(1, 100)
		if r <= 1:
			quality = 3
		elif r <= 10:
			quality = 2
		elif r <= 30:
			quality = 1
		else:
			quality = 0
	
	item.quality = quality
	item.required_proficiency = tier * 10
	
	if item_resource.category == Consts.ItemCategory.EQUIPMENT:
		item.equipment_max_durability = rnd.randi_range(tier * 10 + 10, tier * 15 + 15)
		item.equipment_durability = item.equipment_max_durability
		
		var equipment_resource = item_resource as EquipmentItemResource
		
		for skill in equipment_resource.skill_list:
			var skill_id = skill[0]
			var skill_rate = skill[1]
			
			if rnd.randi_range(0, 100) > skill_rate:
				continue
			
			var level = tier * 5 + quality
			item.equipment_skills[skill_id] = level
		
		for attribute in equipment_resource.attribute_list:
			var attribute_id = attribute[0]
			var attribute_value = attribute[1]
			
			var min_value = int(
					attribute_value
					+ (tier * 0.5 * attribute_value) 
					+ (quality * 0.25 * attribute_value))
			var max_value = int(attribute_value * 1.25)
			
			item.equipment_attributes[attribute_id] = rnd.randi_range(min_value, max_value)
	
	return item


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


func _load_instances() -> void:
	var result := yield(Systems.db.get("/item_instance"), "completed") as Array
	
	for line in result:
		var instance = _parse_item_instance(line)
		
		if instance:
			assert(not _instances.has(instance.id))
			_instances[instance.id] = instance

	
	Log.d("Loaded %d item instance" % _instances.size())


func _parse_item_instance(json) -> ItemInstance:
	var instance = ItemInstance.new()
	
	for prop in json:
		if typeof(json[prop]) == TYPE_NIL:
			continue
		elif prop == "resource_uuid":
			if not _resources.has(json[prop]):
				Log.e("Invalid item resource uuid %s on item instance %d" % [json[prop], json.id])
				return null
			else:
				instance.resource = _resources[json[prop]]
		else:
			instance.set(prop, json[prop])
	
	return instance


func _insert_item(properties: Dictionary) -> ItemInstance:
	var instance = yield(Systems.db.post("/item_instance", properties), "completed")
	
	if typeof(instance) == TYPE_ARRAY:
		return _parse_item_instance(instance[0])
	else:
		return null
	
