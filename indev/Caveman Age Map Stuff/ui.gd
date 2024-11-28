extends CanvasLayer

# References
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

# Update Tower Coin and Grugarians on UI 
func update_currency_display():
	$HBoxContainer/Label.text = "Tower Coin: " + str(Currency.towerCoin) + " | Grugarians: " + str(Currency.grugarians)

func _on_place_tower_btn_pressed() -> void:
	# Call preview_placement in TowersPlaced script
	towers_placed_script.preview_placement(sniperTower)

func _on_send_unit_btn_pressed() -> void:
	path_manager.spawn_unit("normal") # TODO: Change depending on which button pressed
	yap(warcry())

# Handle Keymapping Events
func _input(event):
	if event.is_action_pressed("place_tower"):
		_on_place_tower_btn_pressed()
	elif event.is_action_pressed("test_spawn_unit"):
		_on_send_unit_btn_pressed()
		
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
	
# Utility funciton
func get_timestamp():
	var now = Time.get_time_dict_from_system()
	var timestamp = "%02d:%02d:%02d" % [now.hour, now.minute, now.second]
	return timestamp

# returns a random warcry 
func warcry():
	# random warcry to test displaying message 
	var warcries = ["RAHHH!!!", "For Grug!", "Long Live Grug!"]
	return warcries[randi() % 3]
	
	
