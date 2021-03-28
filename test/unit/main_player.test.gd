extends "res://addons/gut/test.gd"


class TestMainPlayerScript:
	extends "res://addons/gut/test.gd"

	var res = preload("res://scripts/nodes/main_player.gd")
	var main_player: MainPlayer

	func before_each() -> void:
		main_player = autofree(res.new())


	func test_when_attacking_started_is_busy() -> void:
		main_player._attacking_started()
		assert_true(main_player.is_busy, "Should be busy when attacking")


	func test_when_not_attacking_is_not_busy() -> void:
		assert_false(main_player.is_busy, "Should not be busy by default")


	func test_when_attacking_ended_is_not_busy() -> void:
		main_player._attacking_ended()
		assert_false(main_player.is_busy, "Should not be busy after attacking ended")


	func test_get_state_should_return_current_values() -> void:
		var state = main_player.get_state()
		
		assert_eq(state.P, main_player.translation)
		assert_eq(state.R, main_player.rotation_degrees)
		assert_eq(state.A, 0)


class TestMainPlayerScene:
	extends "res://addons/gut/test.gd"

	var scene_double
	var main_player_scene
	
	func before_each() -> void:
		scene_double = partial_double("res://scenes/characters/main_player.tscn")
		main_player_scene = scene_double.instance()
		self.add_child_autoqfree(main_player_scene)


	func test_when_playing_attack_animation_call_callback_func() -> void:
		main_player_scene._animation_tree.set("parameters/attack/active", true)
		
		yield(get_tree().create_timer(0.9), "timeout")
		
		assert_called(main_player_scene, '_attacking_started')
		assert_called(main_player_scene, '_attacking_ended')
	
	
	func test_when_walking_the_blend_tree_is_one() -> void:
		main_player_scene.set_walking()
		assert_eq(1.0,
				main_player_scene._animation_tree.get("parameters/speed/blend_amount"),
				"Should be 1.0")


	func test_when_idle_the_blend_tree_is_zero() -> void:
		main_player_scene.set_idle()
		assert_eq(0.0, 
				main_player_scene._animation_tree.get("parameters/speed/blend_amount"),
				"Should be 0.0")


	func test_when_facing_terrain_layer_collision_is_on_wall() -> void:
		var wall = TestUtils.create_static_body_cube(Vector3(0, 0, -1.5), [], [0])
		self.add_child_autoqfree(wall)
		
		yield(yield_to(get_tree(), "idle_frame", 1), YIELD)
		
		assert_true(main_player_scene.is_on_wall(), "Should be hitting the wall")
	
	
	func test_when_not_facing_terrain_layer_collision_not_is_on_wall() -> void:
		var some_obstacle = TestUtils.create_static_body_cube(Vector3(0, 0, -1.5), [], [1])
		self.add_child_autoqfree(some_obstacle)

		yield(yield_to(get_tree(), "idle_frame", 1), YIELD)

		assert_false(main_player_scene.is_on_wall(), "Should not be hitting the wall")


	func test_when_facing_mob_get_interation_area_bodies_should_return_it() -> void:
		var mob = TestUtils.create_static_body_cube(Vector3(0, 0, -2), [], [1])
		self.add_child_autoqfree(mob)
		var body = mob.get_child(0)
		
		yield(yield_to(get_tree(), "idle_frame", 1), YIELD)
		
		var bodies = main_player_scene.get_interaction_area_bodies()
		
		assert_false(bodies.empty(), "Bodies should not be empty")
		assert_eq_shallow(bodies, [body])


	func test_when_facing_player_get_interation_area_bodies_should_return_it() -> void:
		var player = TestUtils.create_static_body_cube(Vector3(0, 0, -2), [], [2])
		self.add_child_autoqfree(player)
		var body = player.get_child(0)
		
		yield(yield_to(get_tree(), "idle_frame", 1), YIELD)
		
		var bodies = main_player_scene.get_interaction_area_bodies()
		
		assert_false(bodies.empty(), "Bodies should not be empty")
		assert_eq_shallow(bodies, [body])


	func test_when_facing_resource_get_interation_area_bodies_should_return_it() -> void:
		var resource = TestUtils.create_static_body_cube(Vector3(0, 0, -2), [], [3])
		self.add_child_autoqfree(resource)
		var body = resource.get_child(0)
		
		yield(yield_to(get_tree(), "idle_frame", 1), YIELD)
		
		var bodies = main_player_scene.get_interaction_area_bodies()
		
		assert_false(bodies.empty(), "Bodies should not be empty")
		assert_eq_shallow(bodies, [body])


	func test_when_not_facing_mob_player_or_resource_get_interation_area_bodies_should_not_return_it() -> void:
		var other_body = TestUtils.create_static_body_cube(Vector3(0, 0, -2), [], [0,4,5,6])
		self.add_child_autoqfree(other_body)
		
		yield(yield_to(get_tree(), "idle_frame", 1), YIELD)
		
		var bodies = main_player_scene.get_interaction_area_bodies()
		
		assert_true(bodies.empty(), "Bodies should be empty")
