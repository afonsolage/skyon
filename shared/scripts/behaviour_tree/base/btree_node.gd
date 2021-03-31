class_name BTreeNode
extends Node

export(bool) var enabled : bool = true

var _name: String

func _ready() -> void:
	_name = self.name


func _tick(_data: Dictionary) -> int:
	Log.e("You should not use this node!")
	return _success()


func _set_global(data: Dictionary, key: String, value) -> void:
	data[key] = value


func _get_global(data: Dictionary, key: String):
	if key in data:
		return data[key]
	else:
		return null


func _has_global(data: Dictionary, key: String) -> bool:
	return data.has(key)


func _clear_global(data: Dictionary, key: String) -> void:
	var _erased := data.erase(key)


func _reset() -> void:
	pass

func _success() -> int:
	_reset()
	return BTreeResult.SUCCESS


func _running() -> int:
	return BTreeResult.RUNNING


func _failure() -> int:
	_reset()
	return BTreeResult.FAILURE


func _get_tree_branch() -> String:
	var nodes := [self.name]
	var parent := get_parent()
	
	while parent != null and not parent is BTreeRoot:
		nodes.push_back(parent.name)
		parent = parent.get_parent()
	
	var branch := ""

	for i in range(nodes.size() - 1, -1, -1):
		branch += "->%s" % nodes[i]
	
	return branch.right(2)
