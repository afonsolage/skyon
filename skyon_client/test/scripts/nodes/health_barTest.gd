# GdUnit generated TestSuite
class_name health_barTest
extends GdUnitTestSuiteExtended

# TestSuite generated from
const __source = 'res://scripts/nodes/health_bar.gd'
const HealthBar = preload(__source)

var health_bar: HealthBar

func before_test() -> void:
	health_bar = mock("res://scenes/components/HealthBar.tscn", CALL_REAL_FUNC)
	add_child_autofree(health_bar)


func test__update_foreground() -> void:
	health_bar.health = 10
	health_bar.max_health = 20
	
	verify(health_bar, 2)._update_foreground()

func test_reset() -> void:
	health_bar.health = 50
	health_bar.max_health = 100
	health_bar.reset()
	
	verify(health_bar, 3)._update_foreground()
	assert_that(health_bar.health == health_bar.max_health).is_true()
