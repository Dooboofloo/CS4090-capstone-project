extends Node

#TODO: Score stuff goes here

const UNIT_ATTACK_COOLDOWN = 1.0

var UNIT_ATTACK_TIMER

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	UNIT_ATTACK_TIMER = Timer.new()
	UNIT_ATTACK_TIMER.wait_time = UNIT_ATTACK_COOLDOWN
	UNIT_ATTACK_TIMER.autostart = true
	self.add_child(UNIT_ATTACK_TIMER)
	

func _input(_event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused

func game_over():
	pass
