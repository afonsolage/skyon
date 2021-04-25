class_name ItemSystem
extends Node

const ITEMS_PATH := "res://resources/items.res"

var _resources := {}

func _ready() -> void:
	_load_resources()

func _load_resources() -> void:
	if not FileUtils.exists(ITEMS_PATH):
		Log.e("Items resource not found %s" % ITEMS_PATH)
	
	var file := File.new()
	Log.ok(file.open_compressed(ITEMS_PATH, File.READ, File.COMPRESSION_ZSTD))
	var items := file.get_var() as Array
	
		
