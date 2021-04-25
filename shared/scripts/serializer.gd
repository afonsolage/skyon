class_name Serializer
extends Node

static func fix_ints(obj: Object) -> void:
	for prop in obj.get_property_list():
		if prop.type == TYPE_INT:
			obj.set(prop.name, obj.get(prop.name) as int)

