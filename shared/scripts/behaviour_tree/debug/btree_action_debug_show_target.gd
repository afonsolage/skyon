class_name BTreeNodeLeafActionDebugShowTarget
extends BTreeNodeLeafAction

func _tick(data: Dictionary) -> int:
	var target := _get_global(data, "target") as Vector3
	if not target:
		Log.e("Not target found!")
		return _failure()
	
	var mesh_instance := MeshInstance.new()
	mesh_instance.mesh = SphereMesh.new()
	mesh_instance.scale_object_local(Vector3(0.2, 0.2, 0.2))
	mesh_instance.translation = target
	
	data.root_parent.add_child(mesh_instance)
	
	data.debug_target_mesh = mesh_instance
	
	return _success()
