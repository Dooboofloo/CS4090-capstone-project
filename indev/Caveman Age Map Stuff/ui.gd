extends CanvasLayer

# Update Tower Coin and Grugarians on UI 
func update_currency_display():
	$HBoxContainer/Label.text = "Tower Coin: " + str(Currency.towerCoin) + " | Grugarians: " + str(Currency.grugarians)

# Refresh 
func _process(delta):
	update_currency_display()
