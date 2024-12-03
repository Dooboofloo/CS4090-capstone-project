extends VBoxContainer

const MAIN_SCENE = preload("res://indev/Caveman Age Map Stuff/Caveman Scene.tscn")
const ROTATION_SPEED = 0.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"../VBoxContainer2/Score".text = "Score: %s" % Global.PLAYER_SCORE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# lol putting this in _process is kinda wack but fuck it # <- Real shit
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _on_new_game_button_pressed() -> void:
	Global.reset_stats() # Make sure stats are in initial state
	get_tree().change_scene_to_packed(MAIN_SCENE)

func _on_quit_game_button_pressed() -> void:
	get_tree().quit()
