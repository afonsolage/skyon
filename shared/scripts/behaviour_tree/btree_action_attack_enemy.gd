class_name BTreeNodeLeafActionAttackEnemy
extends BTreeNodeLeafAction

func _tick(data: Dictionary) -> int:
	if not "combat" in data.actor:
		Log.e("This action can be used only on entities that has CombatComponent")
	
	var enemy = _get_global(data, "enemy") as Spatial
	if not enemy:
		return _failure()
	
	if not "combat" in enemy:
		Log.e("Trying to attack an enemy which doesn't has CombatComponent")
		return _failure()
	
	if Systems.combat.is_attack_ready(data.actor):
		var _result = Systems.combat.attack(data.actor, enemy)
		return _success()
	else:
		return _failure()
	
