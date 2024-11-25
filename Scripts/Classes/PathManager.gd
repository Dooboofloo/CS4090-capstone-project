class_name PathManager
extends Path3D

var TEST_UNIT = preload("res://Scenes/Instantiable/Unit Archetypes/TestUnit.tscn")
var NORMAL_UNIT = preload("res://Scenes/Instantiable/Unit Archetypes/NormalUnit.tscn")
var FAST_UNIT = preload("res://Scenes/Instantiable/Unit Archetypes/FastUnit.tscn")
var HEAL_UNIT = preload("res://Scenes/Instantiable/Unit Archetypes/HealUnit.tscn")
var TANK_UNIT = preload("res://Scenes/Instantiable/Unit Archetypes/TankUnit.tscn")
var RANGED_UNIT = preload("res://Scenes/Instantiable/Unit Archetypes/RangedUnit.tscn")


func _process(_delta: float) -> void:
	
	# TEST CODE
	#if Input.is_action_just_pressed("test_spawn_unit"):
		#spawn_unit()
	
	if Input.is_action_just_pressed("test_spawn_enemy"):
		spawn_enemy()


func spawn_unit():
	print("Unit Spawned")
	var test_unit = RANGED_UNIT.instantiate()
	
	test_unit.alignment = Unit.ALIGNMENT.ALLY
	
	test_unit.start_path(self)

func spawn_enemy():
	print("Enemy Spawned")
	var test_unit = NORMAL_UNIT.instantiate()
	
	test_unit.alignment = Unit.ALIGNMENT.ENEMY
	
	test_unit.start_path(self)
