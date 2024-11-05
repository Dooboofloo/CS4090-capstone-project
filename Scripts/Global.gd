extends Node

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused
