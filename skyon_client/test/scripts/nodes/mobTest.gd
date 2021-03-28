# GdUnit generated TestSuite
class_name mobTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://scripts/nodes/mob.gd'

var mob_scene: Mob

func before_test() -> void:
	var packed_scene = load("res://scenes/mobs/mob.tscn")
	mob_scene = mock(packed_scene, CALL_REAL_FUNC)
	add_child(mob_scene)


func test_set_state() -> void:
	mob_scene.translation = Vector3(1, 2, 3)
	mob_scene.rotation_degrees = Vector3(4, 5, 6)
	mob_scene._animation_tree.set("parameters/speed/blend_amount", 7)

	mob_scene.set_state({
		"P": Vector3(3, 2, 1),
		"R": Vector3(6, 1, 3),
		"A": 3,
	})

	assert_that(mob_scene.translation == Vector3(3, 2, 1)).is_true()
	assert_that(mob_scene.rotation_degrees == Vector3(6, 1, 3)).is_true()
	assert_that(mob_scene._animation_tree.get("parameters/speed/blend_amount")).is_equal(3)


func test_set_full_state() -> void:
	var combat := CombatComponent.new(mob_scene)
	combat.health = 321
	combat.max_health = 123
	var full_state = {
		"S": {
			"P": Vector3(2, 1, 3),
			"R": Vector3(6, 4, 5),
			"A": 9,
		},
		"C": combat.encode(),
	}
	
	mob_scene.set_full_state(full_state)
	
	verify(mob_scene).set_state(full_state.S)
	assert_that(mob_scene.combat.encode()).is_equal(combat.encode())



func test__on_health_changed() -> void:
	mob_scene._health_bar.health = 1
	mob_scene._health_bar.max_health = 5
	mob_scene.combat.health = 15
	mob_scene.combat.max_health = 20
	
	mob_scene._on_health_changed()
	
	assert_that(mob_scene._health_bar.health == mob_scene.combat.health).is_true()
	assert_that(mob_scene._health_bar.max_health == mob_scene.combat.max_health).is_true()


func test__on_health_changed_callback() -> void:
	mob_scene.combat.emit_health_changed()

	verify(mob_scene)._on_health_changed()
