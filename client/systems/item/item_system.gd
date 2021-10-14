class_name ItemSystem
extends Node

const ITEMS_PATH := "res://resources/items.res"

var _resources := {}

func _ready() -> void:
	_load_resources()


func _load_resources() -> void:
#	var loader = preload("res://scripts/shared/item_resource/item_resource_loader.gd")
#	_resources = loader.load_resources()
	
	Log.d("Loaded %d item resources" % _resources.size())


remote func show_inventory(inventory: Dictionary) -> void:
	# TODO: Show inventory based on received items
	pass
