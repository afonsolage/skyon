class_name BTreeNodeLeafActionDebugShowTarget
extends BTreeNodeLeafAction

func _tick(data: Dictionary) -> int:
	if not "debug" in data or not data.debug:
		return  _success()
	
	var target := _get_global(data, "move_target") as Vector3
	if not target:
		Log.e("Not target found!")
		return _failure()
	
	var mesh_instance := MeshInstance.new()
	mesh_instance.mesh = SphereMesh.new()
	mesh_instance.scale = Vector3(0.2, 0.2, 0.2)
	
	get_tree().root.add_child(mesh_instance)
	
	
	mesh_instance.global_transform.origin = target
	
	if "debug_target_mesh" in data and is_instance_valid(data.debug_target_mesh):
		data.debug_target_mesh.queue_free()
		
	data.debug_target_mesh = mesh_instance
	
	return _success()
