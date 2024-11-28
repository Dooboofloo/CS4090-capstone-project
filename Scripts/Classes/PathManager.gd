class_name PathManager
extends Path3D

@onready var UI = get_tree().current_scene.find_child("UI")

var TEST_UNIT = preload("res://Scenes/Instantiable/Unit Archetypes/TestUnit.tscn")
var NORMAL_UNIT = preload("res://Scenes/Instantiable/Unit Archetypes/NormalUnit.tscn")
var FAST_UNIT = preload("res://Scenes/Instantiable/Unit Archetypes/FastUnit.tscn")
var HEAL_UNIT = preload("res://Scenes/Instantiable/Unit Archetypes/HealUnit.tscn")
var TANK_UNIT = preload("res://Scenes/Instantiable/Unit Archetypes/TankUnit.tscn")
var RANGED_UNIT = preload("res://Scenes/Instantiable/Unit Archetypes/RangedUnit.tscn")

var EMERGENCY_STOP = false # This is for game over stuff, so the wave system stops
var WAVE_PROCESSING = true

const WAVE_PATH = "res://Waves/waves.txt"
var wave_file_lines
var wave_file_pointer = 0

var CURRENT_WAVE = 0
var ENEMY_UNIT_MULTIPLIERS = {
	"normal": 2.0,
	"fast": 1.75,
	"heal": 1.5,
	"tank": 2.5,
	"ranged": 1.5
}

func _ready() -> void:
	var file = FileAccess.open(WAVE_PATH, FileAccess.READ)
	wave_file_lines = file.get_as_text(true).split("\n")
	file.close()

func _process(_delta: float) -> void:
	
	# Test code - remove from release
	if Input.is_action_just_pressed("test_spawn_enemy"):
		var unit_types = ["normal", "fast", "heal", "tank", "ranged"]
		spawn_enemy(unit_types.pick_random())
	
	
	#if WAVE_PROCESSING and (not EMERGENCY_STOP):
		#process_wave()


func spawn_unit(unit_type: String):
	print("Unit Spawned: " + unit_type)
	
	var unit
	match unit_type:
		"normal":
			unit = NORMAL_UNIT.instantiate()
		"fast":
			unit = FAST_UNIT.instantiate()
		"heal":
			unit = HEAL_UNIT.instantiate()
		"tank":
			unit = TANK_UNIT.instantiate()
		"ranged":
			unit = RANGED_UNIT.instantiate()
	
	unit.alignment = Unit.ALIGNMENT.ALLY
	
	unit.start_path(self)

func spawn_enemy(unit_type: String):
	print("Enemy Spawned: " + unit_type)
	
	var unit
	match unit_type:
		"normal":
			unit = NORMAL_UNIT.instantiate()
		"fast":
			unit = FAST_UNIT.instantiate()
		"heal":
			unit = HEAL_UNIT.instantiate()
		"tank":
			unit = TANK_UNIT.instantiate()
		"ranged":
			unit = RANGED_UNIT.instantiate()
	
	unit.alignment = Unit.ALIGNMENT.ENEMY
	unit.enemyMult = ENEMY_UNIT_MULTIPLIERS[unit_type]
	
	unit.start_path(self)

func wait(delay: float):
	WAVE_PROCESSING = false
	var timer = get_tree().create_timer(delay)
	timer.connect("timeout", _end_wait)

func start_wave(num: int):
	CURRENT_WAVE = num
	UI.yap("WAVE " + str(num) + " BEGINS!")

func set_mult(unit_type: String, new_mult: float):
	ENEMY_UNIT_MULTIPLIERS[unit_type] = new_mult

func end_wave(delay:float):
	if delay < 0:
		# If delay is negative, we have completed the final wave.
		UI.yap("FINAL WAVE COMPLETED. CONGRATULATIONS ON TOTAL GRAGICIDE!")
	else:
		UI.yap("WAVE COMPLETED. You have " + str(delay) + " seconds to prepare!")
	
	wait(delay)

func process_wave():
	#COMMANDS = ["startwave", "setmult", "enemy", "wait", "endwave"]
	# startwave [int] - changes current wave number and yaps
	# setmult [enemy_type] [multiplier] - sets the enemy health multiplier of enemy_type to multiplier
	# enemy [enemy_type] - spawns one instance of an enemy with type enemy_type
	# wait [float] - waits a number of seconds equal to float
	# endwave [float] - ends wave an yaps. waits a number of seconds equal to float. if float is negative, halts processing and issues congratulations
	
	# If reach end of wave file, don't try to process
	if wave_file_pointer >= len(wave_file_lines):
		WAVE_PROCESSING = false
		return
	
	# Split commands by space
	var current_command = wave_file_lines[wave_file_pointer].split(" ")
	
	match current_command[0]:
		"startwave":
			var wave_num = int(current_command[1])
			print("Starting wave " + str(wave_num))
			start_wave( wave_num )
		"setmult":
			var enemy_type = current_command[1]
			var new_mult = float(current_command[2])
			print("Setting mult for enemy " + enemy_type + "s to " + str(new_mult))
			set_mult( enemy_type, new_mult )
		"enemy":
			var enemy_type = current_command[1]
			print("Spawning enemy...")
			spawn_enemy( enemy_type )
		"wait":
			var delay = float(current_command[1])
			wait( delay )
		"endwave":
			var delay = float(current_command[1])
			end_wave( delay )
		_:
			pass
	
	# Increment the line pointer
	wave_file_pointer += 1


func _end_wait():
	WAVE_PROCESSING = true
