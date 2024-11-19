extends CanvasLayer

# References
var towers_placed_script: Node = null
var path_manager: Node = null
var message_container: VBoxContainer

func _ready():
	# Get the TowersPlaced node
	towers_placed_script = get_parent().get_node("TowersPlaced")
	path_manager = get_parent().get_node("PathManager")
	message_container = $VBoxContainer

# Update Tower Coin and Grugarians on UI 
func update_currency_display():
	$HBoxContainer/Label.text = "Tower Coin: " + str(Currency.towerCoin) + " | Grugarians: " + str(Currency.grugarians)

func _on_place_tower_btn_pressed() -> void:
	# Call preview_placement in TowersPlaced script
	towers_placed_script.preview_placement("res://indev/Caveman Age Map Stuff/DummyTower.tscn")

func _on_send_unit_btn_pressed() -> void:
	path_manager.spawn_unit()
	yap(warcry())

# Handle Keymapping Events
func _input(event):
	if event.is_action_pressed("place_tower"):
		_on_place_tower_btn_pressed()
	elif event.is_action_pressed("send_unit"):
		_on_send_unit_btn_pressed()
		
# Display Messages Screen 
func yap(message: String):
	# Create New Label for the Message 
	var label = Label.new()
	label.text = "[%s] %s" % [get_timestamp(), message]
	# label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	message_container.add_child(label)
	message_container.move_child(label, 0)
	
	# remove last message if there are 7 or more 
	if message_container.get_child_count() >= 7:
		message_container.get_child(6).queue_free()
	

# Refresh UI 
func _process(delta):
	update_currency_display()
	
# Utility funciton
func get_timestamp():
	var now = Time.get_time_dict_from_system()
	var timestamp = "%02d:02d:02d" % [now.hour, now.minute, now.second]
	print("" + str(now.hour) + ":" + str(now.minute) + ":" + str(now.second))
	#print("Getting Time")
	#print("Curretn Time: %02d:02d:02d" % [now.hour, now.minute, now.second]) 
	return "%02d:%02d:%02d" % [now.hour, now.minute, now.second]

# returns a random warcry 
func warcry():
	# random warcry to test displaying message 
	var warcries = ["RAHHH!!!", "For Grug!", "Long Live Grug!"]
	return warcries[randi() % 3]
	
	
