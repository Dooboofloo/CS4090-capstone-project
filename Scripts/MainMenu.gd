extends VBoxContainer

# TODO: 
# [ ] Save and Load Game

const MAIN_SCENE = preload("res://indev/Caveman Age Map Stuff/Caveman Scene.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# rotate camera pivot 
	$"../CameraPivot".rotation_degrees += Vector3(0,1,0)
	
	# lol putting this in _process is kinda wack but fuck it 
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

	
func _on_new_game_button_pressed() -> void:
	Global.reset_stats() # Make sure stats are in initial state
	get_tree().change_scene_to_packed(MAIN_SCENE)

func _on_load_game_button_pressed() -> void:
	pass

func _on_quit_game_button_pressed() -> void:
	get_tree().quit()
