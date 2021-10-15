class_name Inventory
extends Reference

var _items = []
var _owner_id: int
var _owner_type: int
var _db_id: int
var _has_limited_slots: bool

func _init(slot_count: int) -> void:
	if slot_count > 0:
		_items.resize(slot_count)
		_has_limited_slots = true


func get_at(index: int) -> ItemInstance:
	return _items[index]


func set_at(index: int, item: ItemInstance) -> void:
	_items[index] = item


func has_limited_slots() -> bool:
	return _has_limited_slots
