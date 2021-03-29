class_name BehaviourTreeNode
extends Node

func _tick(_data: Dictionary) -> int:
	Log.e("You should not use this node!")
	return BehaviourTreeResult.SUCCESS


func _store(data: Dictionary, key: String, value) -> void:
	if not data.has(get_instance_id()):
		data[get_instance_id()] = {}

	data[get_instance_id()][key] = value


func _restore(data: Dictionary, key: String):
	if not data.has(get_instance_id()):
		return null
	else:
		return data[get_instance_id()][key]
