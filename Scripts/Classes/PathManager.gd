class_name PathManager
extends Path3D

var TEST_UNIT = preload("res://Scenes/Instantiable/Unit Archetypes/TestUnit.tscn")

func _process(_delta: float) -> void:
	
	# TEST CODE
	#if Input.is_action_just_pressed("test_spawn_unit"):
		#spawn_unit()
	
	if Input.is_action_just_pressed("test_spawn_enemy"):
		spawn_enemy()


func spawn_unit():
	print("Unit Spawned")
	var test_unit = TEST_UNIT.instantiate()
	
	test_unit.alignment = Unit.ALIGNMENT.ALLY
	
	test_unit.start_path(self)

func spawn_enemy():
	print("Enemy Spawned")
	var test_unit = TEST_UNIT.instantiate()
	
	test_unit.alignment = Unit.ALIGNMENT.ENEMY
	
	test_unit.start_path(self)
