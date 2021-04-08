class_name BTreeNodeLeafActionAttackEnemy
extends BTreeNodeLeafAction

var _combat_system: CombatSystem

func _ready() -> void:
	if ProjectSettings.get_setting("global/SERVER"):
		var channel_id = Systems.get_current_channel_id(self)
		_combat_system = Systems.get_combat(channel_id)
	else:
		_combat_system = Systems.combat

func _tick(data: Dictionary) -> int:
	if not "combat" in data.actor:
		Log.e("This action can be used only on entities that has CombatComponent")
	
	var enemy = _get_global(data, "enemy") as Spatial
	if not enemy:
		return _failure()
	
	if not "combat" in enemy:
		Log.e("Trying to attack an enemy which doesn't has CombatComponent")
		return _failure()
	
	if _combat_system.is_attack_ready(data.actor):
		var _result = _combat_system.attack(data.actor, enemy)
		return _success()
	else:
		return _failure()
	
