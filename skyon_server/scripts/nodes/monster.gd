extends KinematicBody

enum AIState {
	IDLE, 
	WANDER,
}

const IDLE_TIMEOUT := 3.0
const MAX_WALK_RADIOUS := 15

export(float) var move_speed := 1.0
export(float) var jump_force := 4.0

var _gravity_body: GravityBody
var _ai_state: int #enum is just a dictionary of ints
var _ai_next_state: float
var _move_to: Vector3
var _on_wall: bool = false

onready var _original_position := self.translation
onready var _wall_raycast := $WallRayCast

func _ready() -> void:
	_gravity_body = GravityBody.new(self)
	_ai_state = AIState.IDLE
	_ai_next_state = IDLE_TIMEOUT

func _physics_process(delta: float) -> void:
	_gravity_body.apply(delta)
	_ai_process(delta)


func get_state() -> Dictionary:
	return {
		"P": self.translation,
		"R": self.rotation_degrees,
		"A": _ai_state,
	}


func _ai_process(delta) -> void:
	_ai_next_state -= delta
	
	if _ai_next_state < 0.0:
		_ai_change_state()
	else:
		_ai_process_current_state()


func _ai_change_state() -> void:
	_ai_state = int(rand_range(0.0, 1.0) * AIState.keys().size())
	_ai_next_state = IDLE_TIMEOUT
	
	if _ai_state == AIState.WANDER:
		self.rotation_degrees.y += rand_range(-180.0, 180)


func _ai_process_current_state() -> void:
	if _ai_state == AIState.IDLE:
		pass
	elif _ai_state == AIState.WANDER:
		var mv_spd := move_speed if _gravity_body.is_grounded() else move_speed * 2
		var _velocity := self.move_and_slide(self.transform.basis.z * mv_spd)
		
		#Log.d("%s %s" % [_wall_raycast.is_colliding(), _gravity_body.is_grounded()])
		
		if _wall_raycast.is_colliding() and _gravity_body.is_grounded():
			_gravity_body.jump(jump_force)
			
		if _original_position.distance_to(self.translation) > MAX_WALK_RADIOUS:
			_ai_state = AIState.IDLE
	else:
		Log.e("Invalid ai state %d" % _ai_state)
