class_name GdUnitTestSuiteExtended
extends GdUnitTestSuite

func add_child_autofree(child: Node, legible_unique_name: bool = false) -> void:
	.add_child(auto_free(child), legible_unique_name)


func next_frame() -> void:
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")


func create_mocked_main_player() -> MainPlayer:
	var main_player := mock("res://scenes/characters/main_player.tscn", CALL_REAL_FUNC) as MainPlayer
	add_child_autofree(main_player)
	return main_player


func create_mocked_mob(name: String) -> Mob:
	var mob := mock("res://scenes/mobs/mob.tscn", CALL_REAL_FUNC) as Mob
	mob.name = name
	add_child_autofree(mob, false)
	return mob


func mock_world_system() -> void:
	var world := mock("res://scenes/systems/world_system.tscn", CALL_REAL_FUNC) as WorldSystem
	add_child_autofree(world)
	Systems.world = world


func mock_combat_system() -> void:
	var combat := mock("res://scenes/systems/combat_system.tscn", CALL_REAL_FUNC) as CombatSystem
	add_child_autofree(combat)
	Systems.combat = combat


func mock_main_player() -> void:
	var main_player = mock("res://scenes/characters/main_player.tscn", CALL_REAL_FUNC) as MainPlayer
	Systems.world.add_child(auto_free(main_player))
	Systems.world.main_player = main_player
