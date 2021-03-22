class_name SelectTarget
extends Spatial

enum TargetType {
	TARGET,
	PATH,
}

const _target_color = Color(0.0, 0.0, 0.8, 0.5)
const _path_color = Color(0.0, 0.8, 0.0, 0.5)

onready var _target_anim := $Target/AnimationPlayer
onready var _select_anim := $Select/AnimationPlayer

onready var _target_mesh : MeshInstance = $Target/MeshInstance
onready var _select_mesh : MeshInstance = $Select/MeshInstance

func _ready():
	_target_anim.play("up_and_down_loop")
	_select_anim.play("scale_loop")


func reset(target_type: int, position: Vector3 = Vector3.ZERO) -> void:
	if not _target_mesh or not _select_mesh:
		yield(self, "ready")
	
	self.translation = position
	self.visible = true
	
	if target_type == TargetType.TARGET:
		_target_mesh.get("material/0").albedo_color = _target_color
		_select_mesh.get("material/0").set_shader_param("albedo", _target_color)
	else:
		_target_mesh.get("material/0").albedo_color = _path_color
		_select_mesh.get("material/0").set_shader_param("albedo", _path_color)
	pass
