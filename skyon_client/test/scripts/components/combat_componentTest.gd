# GdUnit generated TestSuite
class_name CombatComponentTest
extends GdUnitTestSuite

# warning-ignore:return_value_discarded

# TestSuite generated from
const __source = 'res://scripts/components/combat_component.gd'

var combat : CombatComponent

func before_test() -> void:
	var dummy = Spatial.new()
	self.add_child(dummy)
	combat = load(__source).new(dummy)

#func test__init() -> void:
	# load(__source).new(null)
	# Wait for a better way of testing error messages
#	assert_not_yet_implemented()
	
func test_encode() -> void:
	combat.attack = 1
	combat.attack_range = 2
	combat.defense = 3
	combat.health = 4
	combat.max_health = 5
	
	var encoded := combat.encode()
	
	assert_dict(encoded) \
			.is_not_null() \
			.is_not_empty() \
			.is_equal({
				"A": 1,
				"AR": 2,
				"D": 3,
				"H": 4,
				"MH": 5,
			})

func test_decode() -> void:
	var dict := {
		"A": 1,
		"AR": 2,
		"D": 3,
		"H": 4,
		"MH": 5,
	}
	var other_combat := CombatComponent.new(combat.parent)
	other_combat.attack = dict.A
	other_combat.attack_range = dict.AR
	other_combat.defense = dict.D
	other_combat.health = dict.H
	other_combat.max_health = dict.MH

	combat.decode(dict)
	
	assert_that(combat).is_equal(other_combat)

#func test_emit_health_changed():
	# Wait for a way to check if signal was 
