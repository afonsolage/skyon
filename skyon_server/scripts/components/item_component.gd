class_name ItemComponent
extends Reference

var uuid: String
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
