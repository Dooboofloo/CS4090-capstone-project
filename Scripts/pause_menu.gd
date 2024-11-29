extends Control

const MAIN_SCENE = preload("res://indev/Caveman Age Map Stuff/Caveman Scene.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _on_play_button_pressed() -> void:
	# unpause game, remove pause menu instance
	get_tree().paused = false
	queue_free()

func _on_restart_button_pressed() -> void:
	# Restart Game
	get_tree().paused = false
	Global.reset_stats()
	get_tree().change_scene_to_file("res://indev/Caveman Age Map Stuff/Caveman Scene.tscn")

func _on_settings_pressed() -> void:
	# TODO: Setting Menu 
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	# TODO: Save the Game
	get_tree().quit()
