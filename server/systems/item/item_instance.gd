class_name ItemInstance
extends Reference

var id: int
var resource: ItemResource
var tier: int
var quality: int
var required_proficiency: int
var stack_count: int

var consumable_action_effect_list := []

var equipment_max_durability: int
var equipment_durability: int
var equipment_skills := {}
var equipment_attributes := {}

func serialize() -> Dictionary:
	var res = {}
	
	res.id = id
	res.resource = resource.uuid
	res.tier = tier
	res.quality = quality
	res.required_proficiency = required_proficiency
	res.stack_count = stack_count
	
	res.consumable_action_effect_list = consumable_action_effect_list
	res.equipment_max_durability = equipment_max_durability
	res.equipment_durability = equipment_durability
	res.equipment_skills = equipment_skills
	res.equipment_attributes = equipment_attributes
	
	return res
