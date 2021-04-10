class_name DBSystem
extends Node

const DB_PATH = "user://db"

var _next_unique_id: int

func _ready() -> void:
	pass


class DBTaskRead:
	extends Reference

	var deferred_object: Object
	var deferred_method: String
	var deferred_args: Array

	var uuid: String
	var result: Dictionary


class DBTaskWrite:
	extends Reference

	var deferred_object: Object
	var deferred_method: String
	var deferred_args: Array

	var uuid: String
	var data: Dictionary
