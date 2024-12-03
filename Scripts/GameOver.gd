extends VBoxContainer

const MAIN_SCENE = preload("res://indev/Caveman Age Map Stuff/Caveman Scene.tscn")
const MENU_SCENE = preload("res://Scenes/main_menu.tscn")
const ROTATION_SPEED = 0.2

func _ready() -> void:
	$"../VBoxContainer2/Score".text = "Score: %s" % Global.PLAYER_SCORE

func _process(delta: float) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _on_new_game_button_pressed() -> void:
	Global.reset_stats() # Make sure stats are in initial state
	get_tree().change_scene_to_packed(MAIN_SCENE)

func _on_quit_game_button_pressed() -> void:
	Global.reset_stats() # Make sure stats are in initial state
	get_tree().change_scene_to_packed(MENU_SCENE)
