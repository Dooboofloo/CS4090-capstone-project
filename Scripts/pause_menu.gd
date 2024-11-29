extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_play_button_pressed() -> void:
	# unpause game, remove pause menu instance
	get_tree().paused = false
	queue_free()

func _on_restart_button_pressed() -> void:
	# TODO: Restart Game
	pass # Replace with function body.

func _on_settings_pressed() -> void:
	# TODO: Setting Menu 
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	# TODO: Save the Game
	get_tree().quit()
