extends HBoxContainer


func _on_send_unit_button_pressed() -> void:
	print("Sending Unit!")

func _on_place_tower_button_pressed() -> void:
	print("Placing Tower!")
	var TowersPlacedNode = get_node("../Cavaman Map outline/TowersPlaced")
	TowersPlacedNode.placement(true)
