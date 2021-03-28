extends "res://addons/gut/test.gd"


class TestMobScript:
	extends "res://addons/gut/test.gd"

	var res = preload("res://scripts/nodes/mob.gd")
	var mob: Mob
	
	func before_each() -> void:
		mob = autofree(res.new())
	
	
	func test_when_instanciated_combat_is_not_null() -> void:
		assert_not_null(mob.combat)


	func test_when_instanciated_combat_signals_are_connected() -> void:
		assert_connected(mob.combat, mob, "health_changed", "_on_health_changed")


class TestMobScene:
	extends "res://addons/gut/test.gd"

	var scene_double
	var mob_scene
	
	func before_each() -> void:
		scene_double = partial_double("res://scenes/mobs/mob.tscn")
		mob_scene = scene_double.instance()
		self.add_child_autoqfree(mob_scene)


	func test_when_set_state_the_position_rotation_and_animations_are_updated() -> void:
		var p = Vector3(1, 2, 3)
		var r = Vector3(4, 5, 6)
		var a = 7

		mob_scene.set_state({
			"P": p,
			"R": r,
			"A": a,
		})

		assert_eq(mob_scene.translation, p)
		assert_eq(mob_scene.rotation_degrees, r)
		assert_eq(mob_scene._animation_tree.get("parameters/speed/blend_amount"), a)
	
	
	func test_when_set_full_state_the_state_combat_and_health_are_updated() -> void:
		var p = Vector3(1, 2, 3)
		var r = Vector3(4, 5, 6)
		var a = 7
		var c = CombatComponent.new(mob_scene).encode()
		var s = {
			"P": p,
			"R": r,
			"A": a,
		}
		mob_scene.combat.health = 123
		mob_scene.set_full_state({
			"S": s,
			"C": c
		})
		
		assert_called(mob_scene, "set_state", [s])
		assert_eq_shallow(mob_scene.combat.encode(), c)
		

	func test_when_combat_signal_health_changed_is_emmited_the_callback_is_called() -> void:
		mob_scene.combat.emit_health_changed()
		assert_called(mob_scene, "_on_health_changed")
		
	
	func test_when_on_health_changed_health_bar_is_updated() -> void:
		mob_scene._health_bar.health = 123
		mob_scene._health_bar.max_health = 456
		
		mob_scene.combat.health = 789
		mob_scene.combat.max_health = 101112
		
		mob_scene._on_health_changed()
		assert_eq(mob_scene._health_bar.health, 789)
		assert_eq(mob_scene._health_bar.max_health, 101112)
		
