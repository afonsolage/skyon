class_name AISystem
extends Node

enum AIState {
	IDLE, 
	WANDER,
}

const IDLE_TIMEOUT := 3.0
const MAX_WALK_RADIOUS := 15

func _physics_process(delta):
	var entities := []
	entities += Systems.world.list_monsters()
	
	for entity in entities:
		if "ai" in entity:
			_ai_process(entity, delta)

func _ai_process(entity: Spatial, delta: float) -> void:
	entity.ai.next_state -= delta
	
	if entity.ai.next_state < 0.0:
		_change_state(entity)
	else:
		_process_current_state(entity)


func _change_state(entity: Spatial) -> void:
	entity.ai.state = int(rand_range(0.0, 1.0) * AIState.keys().size())
	entity.ai.next_state = IDLE_TIMEOUT
	
	if entity.ai.state == AIState.WANDER:
		entity.rotation_degrees.y += rand_range(-180.0, 180)


func _process_current_state(entity: Spatial) -> void:
	var ai = entity.ai as AIComponent
	
	if ai.state == AIState.IDLE:
		pass
	elif ai.state == AIState.WANDER:
		var mv_spd: float = entity.move_speed if entity.gravity.is_grounded() else entity.move_speed * 2
		var _velocity = entity.move_and_slide(entity.transform.basis.z * mv_spd)
		
		if ai.is_on_wall() and entity.gravity.is_grounded():
			entity.gravity.jump()
			
#		if ai.original_position.distance_to(entity.translation) > MAX_WALK_RADIOUS:
#			ai.state = AIState.IDLE
	else:
		Log.e("Invalid ai state %d" % ai.state)
