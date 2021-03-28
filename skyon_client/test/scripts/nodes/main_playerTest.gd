# GdUnit generated TestSuite
class_name main_playerTest
extends GdUnitTestSuiteExtended

# TestSuite generated from
const __source = 'res://scripts/nodes/main_player.gd'

var main_player: MainPlayer

func before_test() -> void:
	main_player = mock("res://scenes/characters/main_player.tscn", CALL_REAL_FUNC)
	add_child_autofree(main_player)


func after_test() -> void:
	remove_child(main_player)
	main_player.free()


func test_is_on_wall() -> void:
	assert_that(main_player.is_on_wall()).is_false()
	
	var wall = TestUtils.create_static_body_cube(Vector3(0, 0, -1.5), [], [0])
	self.add_child_autofree(wall)
	
	yield(next_frame(), "completed")
	
	wall.free()
	assert_that(main_player.is_on_wall()).is_true()
	
	var not_wall = TestUtils.create_static_body_cube(Vector3(0, 0, -1.5), [], [1])
	self.add_child_autofree(not_wall)
	
	yield(next_frame(), "completed")
	
	assert_that(main_player.is_on_wall()).is_false()


func test_get_state() -> void:
	main_player.translation = Vector3(1, 2, 3)
	main_player.rotation_degrees = Vector3(4, 5, 6)
	
	var state = main_player.get_state()

	assert_that(main_player.translation == state.P).is_true()
	assert_that(main_player.rotation_degrees == state.R).is_true()
	assert_that(0 == state.A).is_true()


func test__attacking_started() -> void:
	main_player.is_busy = false
	main_player._attacking_started()

	assert_that(main_player.is_busy).is_true()


func test__attacking_ended() -> void:
	main_player.is_busy = true
	main_player._attacking_ended()

	assert_that(main_player.is_busy).is_false()


func test_get_interaction_area_bodies() -> void:
	var wall = TestUtils.create_static_body_cube(Vector3(0, 0, -1.5), [], [0])
	var monster = TestUtils.create_static_body_cube(Vector3(0, 0, -1.5), [], [1])
	var player = TestUtils.create_static_body_cube(Vector3(0, 0, -1.5), [], [2])
	var resource = TestUtils.create_static_body_cube(Vector3(0, 0, -1.5), [], [3])
	var other_thing = TestUtils.create_static_body_cube(Vector3(0, 0, -1.5), [], [4, 5, 6, 7, 8])
	
	self.add_child_autofree(wall)
	self.add_child_autofree(monster)
	self.add_child_autofree(player)
	self.add_child_autofree(resource)
	self.add_child_autofree(other_thing)

	yield(next_frame(), "completed")

	var bodies := main_player.get_interaction_area_bodies()
	
	assert_that(bodies)\
		.is_not_null()\
		.is_not_empty()\
		.has_size(3)\
		.contains([
			monster.get_child(0),
			player.get_child(0),
			resource.get_child(0),
		])


func test_start_attack_animation() -> void:
	main_player.start_attack_animation()
	
	assert_that(main_player._animation_tree.get("parameters/attack/active")).is_true()


func test_set_walking() -> void:
	main_player.set_walking()
	
	assert_that(main_player._animation_tree.get("parameters/speed/blend_amount")).is_equal(1.0)


func test_set_idle() -> void:
	main_player.set_idle()
	
	assert_that(main_player._animation_tree.get("parameters/speed/blend_amount")).is_equal(0.0)


func test_animation_attack_callback() -> void:
	main_player.start_attack_animation()
	
	# Attack animation lasts 0.9 seconds
	yield(get_tree().create_timer(0.9), "timeout")
	
	verify(main_player)._attacking_started()
	verify(main_player)._attacking_ended()
