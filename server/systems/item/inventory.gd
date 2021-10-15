class_name Inventory
extends Reference

var _items = []
var _owner_id: int
var _owner_type: int
var _id: int
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


func find_free_slot() -> int:
	for i in range(_items.size()):
		if not _items[i]:
			return i
	
	if _has_limited_slots:
		return -1
	else:
		_items.push_back(null)
		return _items.size() - 1


func is_slot_free(index: int) -> bool:
	return index < _items.size() && not _items[index]


func serialize() -> Dictionary:
	var res := {}
	
	res.id = _id
	res.items = []
	
	for item in _items:
		res.items.push_back(item.serialize())
	
	return res
