extends CanvasLayer

# References
var towers_placed_script: Node = null
var path_manager: Node = null

func _ready():
	# Get the TowersPlaced node
	towers_placed_script = get_parent().get_node("TowersPlaced")
	path_manager = get_parent().get_node("PathManager")

# Update Tower Coin and Grugarians on UI 
func update_currency_display():
	$HBoxContainer/Label.text = "Tower Coin: " + str(Currency.towerCoin) + " | Grugarians: " + str(Currency.grugarians)

func _on_place_tower_btn_pressed() -> void:
	# Call preview_placement in TowersPlaced script
	towers_placed_script.preview_placement("res://indev/Caveman Age Map Stuff/DummyTower.tscn")

func _on_send_unit_btn_pressed() -> void:
	path_manager.spawn_unit()
	print("RAHHH!!!")

# Refresh UI 
func _process(delta):
	update_currency_display()
