# GdUnit generated TestSuite
class_name gravity_componentTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://scripts/components/gravity_component.gd'

var gravity : GravityComponent

func before_test() -> void:
	var dummy = Spatial.new()
	self.add_child(dummy)
	gravity = load(__source).new(dummy)

func test_is_grounded():
	gravity.force = 0.0
	assert_that(gravity.is_grounded()).is_true()
	
	gravity.force = 5
	assert_that(gravity.is_grounded()).is_false()
	
	gravity.force = -1
	assert_that(gravity.is_grounded()).is_false()
	
	gravity.force = 0.0005
	assert_that(gravity.is_grounded()).is_true()

func test_jump():
	var previous_force := gravity.force
	gravity.jump()
	assert_that(gravity.force).is_equal(gravity.jump_force + previous_force)
