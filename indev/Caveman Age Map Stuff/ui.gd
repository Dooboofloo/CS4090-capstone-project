extends CanvasLayer

# References
var pause_menu_scene: PackedScene = null 
var towers_placed_script: Node = null
var path_manager: Node = null
var message_container: RichTextLabel = null
var messages = []

#Tower Models Preload
var dummyTower = preload("res://Scenes/Instantiable/Tower Archetypes/DummyTower.tscn")
var basicTower = preload("res://Scenes/Instantiable/Tower Archetypes/BasicTower.tscn")
var multiTower = preload("res://Scenes/Instantiable/Tower Archetypes/MultiTower.tscn")
var econTCTower = preload("res://Scenes/Instantiable/Tower Archetypes/EconTCTower.tscn")
var rapidTower = preload("res://Scenes/Instantiable/Tower Archetypes/RapidTower.tscn")
var sniperTower = preload("res://Scenes/Instantiable/Tower Archetypes/SniperTower.tscn")

func _ready():
	# Get the TowersPlaced node
	towers_placed_script = get_parent().get_node("TowersPlaced")
	path_manager = get_parent().get_node("PathManager")
	message_container = $RichTextLabel
	pause_menu_scene = preload("res://Scenes/pause_menu.tscn")
	
	$HBoxContainer/Tower1Button.text = "Basic Tower"
	$HBoxContainer/Tower2Button.text = "Multi Tower"
	$HBoxContainer/Tower3Button.text = "Econ TC Tower"
	$HBoxContainer/Tower4Button.text = "Rapid Tower"
	$HBoxContainer/Tower5Button.text = "Sniper Tower"

# Update Tower Coin and Grugarians on UI 
func update_currency_display():
	$HBoxContainer/Label.text = "Tower Coin: " + str(Currency.towerCoin) + " | Grugarians: " + str(Currency.grugarians)

#func _on_place_tower_btn_pressed() -> void:
	## Call preview_placement in TowersPlaced script
	#towers_placed_script.preview_placement(sniperTower)
	#

func _on_send_unit_btn_pressed() -> void:
	path_manager.spawn_unit("normal") # TODO: Change depending on which button pressed
	yap(warcry())
	
func _on_pause_button_pressed() -> void:
	# pause game, add pause menu to UI
	if not get_tree().paused:
		var pause_menu = pause_menu_scene.instantiate() 
		add_child(pause_menu)
		print("PAUSE")
		get_tree().paused = true


# Handle Keybinding Events
func _input(event):
	#if event.is_action_pressed("place_tower"):
		#_on_place_tower_btn_pressed()
	if event.is_action_pressed("test_spawn_unit"):
		_on_send_unit_btn_pressed()
	elif event.is_action_pressed("tower1"):
		_on_tower_1_button_pressed()
	elif event.is_action_pressed("tower2"):
		_on_tower_2_button_pressed()
	elif event.is_action_pressed("tower3"):
		_on_tower_3_button_pressed()
	elif event.is_action_pressed("tower4"):
		_on_tower_4_button_pressed()
	elif event.is_action_pressed("tower5"):
		_on_tower_5_button_pressed()

# Display Messages on Screen 
func yap(message: String):
	# add message to messages 
	var formatted_message = "[%s] %s" % [get_timestamp(), message]
	messages.insert(0, formatted_message)
	# if more than 6 messages, remove one 
	if len(messages) > 6:
		messages.pop_back()
	
	# update message container
	message_container.clear()
	message_container.push_bgcolor("black")
	message_container.push_color("white")
	for msg in messages: 
		message_container.append_text(msg)
		message_container.newline()

# Refresh UI 
func _process(_delta):
	update_currency_display()

	if Input.is_action_just_released("escape"):
		_on_pause_button_pressed()
	elif Input.is_action_just_released("pause_play"):
		_on_pause_button_pressed()

# Utility funciton
func get_timestamp():
	var now = Time.get_time_dict_from_system()
	var timestamp = "%02d:%02d:%02d" % [now.hour, now.minute, now.second]
	return timestamp

# returns a random warcry 
func warcry():
	# random warcry to test displaying message 
	var warcries = ["RAHHH!!!", "For Grugaria!", "Long Live Grug!"]
	return warcries[randi() % 3]
	
func _on_tower_1_button_pressed() -> void:
	towers_placed_script.preview_placement(basicTower)

func _on_tower_2_button_pressed() -> void:
	towers_placed_script.preview_placement(multiTower)

func _on_tower_3_button_pressed() -> void:
	towers_placed_script.preview_placement(econTCTower)

func _on_tower_4_button_pressed() -> void:
	towers_placed_script.preview_placement(rapidTower)
	
func _on_tower_5_button_pressed() -> void:
	towers_placed_script.preview_placement(sniperTower)
