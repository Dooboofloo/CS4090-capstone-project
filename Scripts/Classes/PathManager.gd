class_name PathManager
extends Path3D

var TEST_UNIT = preload("res://Scenes/Instantiable/Unit Archetypes/TestUnit.tscn")

func _process(delta: float) -> void:
	
	# TEST CODE
	if Input.is_action_just_pressed("test_spawn_unit"):
		spawn_unit()


func spawn_unit():
	print("Unit Spawned")
	# Create new test unit
	var test_unit = TEST_UNIT.instantiate()
	
	test_unit.start_path(self)
