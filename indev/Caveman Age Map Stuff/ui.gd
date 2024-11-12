extends CanvasLayer

# Update Tower Coin and Grugarians on UI 
func update_currency_display():
	$HBoxContainer/Label.text = "Tower Coin: " + str(Currency.towerCoin) + " | Grugarians: " + str(Currency.grugarians)

# Reference to the TowersPlaced script
var towers_placed_script: Node = null

func _ready():
	# Get the TowersPlaced node
	towers_placed_script = get_parent().get_node("TowersPlaced")

func _on_place_tower_btn_pressed() -> void:
	# Call preview_placement in TowersPlaced script
	towers_placed_script.preview_placement("res://indev/Caveman Age Map Stuff/DummyTower.tscn")


# Refresh UI 
func _process(delta):
	update_currency_display()
