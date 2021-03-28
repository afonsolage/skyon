class_name GdUnitTestSuiteExtended
extends GdUnitTestSuite

func add_child_autofree(child: Node) -> void:
	.add_child(auto_free(child))


func next_frame() -> void:
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
