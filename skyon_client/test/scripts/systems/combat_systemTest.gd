# GdUnit generated TestSuite
class_name combat_systemTest
extends GdUnitTestSuiteExtended

# TestSuite generated from
const __source = 'res://scripts/systems/combat_system.gd'

var system: CombatSystem

func before_test() -> void:
	mock_combat_system()
	system = Systems.combat

func test___damage_received() -> void:
	mock_world_system()
	var mob := .create_mocked_mob("M123")
	mob.combat.health = 51
	
	do_return(mob).on(Systems.world).get_spatial("M123")
	
	system.__damage_received({
		"attacked": "M123",
		"attacker": "M123",
		"dmg": 10
	})
	
	assert_that(mob.combat.health == 41).is_true()
	assert_that(mob._health_bar.health == 41).is_true()
	
	verify(mob)._on_health_changed()

func test__on_InputSystem_attack_pressed() -> void:
	mock_world_system()
	mock_main_player()
	var mob = TestUtils.create_static_body_cube(Vector3(0, 0, -1.5), [], [1])
	self.add_child_autofree(mob)
	
	yield(next_frame(), "completed")
	
	Systems.combat._on_InputSystem_attack_pressed()
	
