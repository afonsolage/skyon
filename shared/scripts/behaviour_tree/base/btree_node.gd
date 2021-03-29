class_name BTreeNode
extends Node

func _tick(_data: Dictionary) -> int:
	Log.e("You should not use this node!")
	return _success()


func _set_global(data: Dictionary, key: String, value) -> void:
	data[key] = value


func _get_global(data: Dictionary, key: String):
	return data[key]


func _store(data: Dictionary, key: String, value) -> void:
	if not data.has(get_instance_id()):
		data[get_instance_id()] = {}

	data[get_instance_id()][key] = value


func _restore(data: Dictionary, key: String):
	if not data.has(get_instance_id()):
		return null
	else:
		return data[get_instance_id()][key]


func _reset(data: Dictionary) -> void:
	data.erase(get_instance_id())


func _success() -> int:
	return BTreeResult.SUCCESS


func _running() -> int:
	return BTreeResult.RUNNING


func _failure() -> int:
	return BTreeResult.RUNNING
