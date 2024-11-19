# ALL TOWERS MUST HAVE DetectUnitArea ON LAYER 2 FOR COLLISION. This stops tower placement from being affected by it.
# CRITICAL TODO: tower upgrades currently upgrade ALL TOWERS AT ONCE! Must make unit placements UNIQUE
# ALSO, preview tower un-upgrades (related issue)

class_name Tower
extends Node3D

@export var tower_name: String
@export var damage: int = 1
@export var atk_speed: float = 2.0 # ex. atk speed 2 = 2 shots/second = 0.5 cooldown
@export var atk_range: float = 5.0

@onready var cooldown = 1 / atk_speed

@export var towerCost: int = 1 #I expect this to change. This is just tower cost to place.

@onready var unit_detection_area = $DetectUnitArea
@onready var unit_detection_shape = $DetectUnitArea/DetectUnitCollisionShape
@onready var cooldown_timer = $CooldownTimer

var ENEMIES_IN_RANGE = [] # A list of enemies that are currently in range
var is_preview = false #Variable for us to check if the unit is placed yet or just a preview.
var placeable = false #Variable for us to know if the tower can be placed or not.

#This contains the tower's upgrade path. We can in the future add two option but for now its just one.
#Holds a tuple of stat change type and amount. EX: [[["Attack", "Range"], [5, .3]], ...]
#This can be changed later to accept your choice of operation, currently it will only be addition though.
#For performance, the FIRST upgrade is the one at the END. LAST is the one at FRONT.
var upgrades = [[["Damage", "Range"], [4, .3]], [["Attack Speed", "Range"], [2, .3]]]

#This tracks cost of each upgrade. Meant to relate one to one in index. Can be made to do cost in both TC and grugs.
var upgrade_cost = [10, 5]

#This tracks if the user mouse is still on the tower allowing updating of upgrade indicator
var mouse_hover = false

#This variable allows us to only addcollision and removecollision once, rather than every delta like it was before.
#Since there is an order to it I just make it count down and check the value to see if we call the funciton.
#removecollision sees this is 2 and then runs that function, decrements to 1. addcollision sees 1, runs, decrements.
var only_once = 2

func _ready() -> void:
	
	#Initial gameplay setup stuff.
	update_range()
	cooldown_timer.wait_time = cooldown
	

	# Connect signals
	unit_detection_area.connect("body_entered", _on_detect_unit_area_body_entered)
	unit_detection_area.connect("body_exited", _on_detect_unit_area_body_exited)

func _process(_delta: float) -> void:
	
	if cooldown_timer.is_stopped() and len(ENEMIES_IN_RANGE) > 0:
		print("Pew!")
		
		ENEMIES_IN_RANGE.sort_custom( func(a, b): return global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position) )
		var closest_unit = ENEMIES_IN_RANGE[0]
		deal_damage(closest_unit)
	
	#Checking if we are in preview mode.
	if is_preview == true:
		preview_follow()
		#TODO: If you have a better idea for this only to be called once, change this!
	elif (is_preview == false) and (only_once == 1):
		preview_follow_end() 
		only_once -= 1
	
	#Checking if we need to update upgrade indicator.
	if mouse_hover == true:
		update_upgrade_indicator()

func deal_damage(receiver: Unit):
	# Deal damage
	receiver.take_damage(damage)
	
	# Start a cooldown after attacking
	cooldown_timer.start()

func destroy():
	# Maybe refund some of the player's money here or something
	self.queue_free()

func _on_detect_unit_area_body_entered(body: Node3D):
	var unit = body.get_parent()
	if unit is Unit:
		if unit.alignment == Unit.ALIGNMENT.ENEMY:
			print("ADDING NEW UNIT TO RANGE")
			# Add that unit to list of enemies
			ENEMIES_IN_RANGE.append(unit)

func _on_detect_unit_area_body_exited(body: Node3D):
	var unit = body.get_parent()
	if unit is Unit:
		if unit in ENEMIES_IN_RANGE:
			# Not actually sure if this works
			print("REMOVING UNIT FROM RANGE")
			# Remove that unit from the list of enemies
			var index = ENEMIES_IN_RANGE.find(unit)
			ENEMIES_IN_RANGE.remove_at(index)

#Stuff for the ability for a preview of the model to follow. Should be in each tower made.
func preview_follow():
	
	#TODO: Change this to a better way of only calling once if you have a better idea
	if only_once == 2:
		remove_collision()
		only_once -= 1
	
	var parent = get_parent_node_3d()
	#This should prevent calculation if no collision occurs so tower placement doesn't follow.
	#Somehow this bugged when I was working on something and it managed to pass, so if you know why, you can fix.
	if parent.get_3D_position().size() != 0:
		position = parent.get_3D_position().get("position")
		
		#Having the tower check itself if it can be placed.
		var validArea = parent.get_3D_position().get('collider') is PlaceableArea
		#Setting color to represent if placeable or not.
		if validArea and (Currency.towerCoin >= towerCost): #Can place and buy
			var colorCanPlace = Color8(99, 255, 102, 106)
			$Perish/PlacementDenial/CollisionShape3D/AreaPlaceableIndicator.mesh.material.albedo_color = colorCanPlace
			placeable = true
		else: #Non placeable states.
			if validArea: #Can place can't buy
				var colorNoCoin = Color8(255, 200, 52, 106)
				$Perish/PlacementDenial/CollisionShape3D/AreaPlaceableIndicator.mesh.material.albedo_color = colorNoCoin
			else: #Can't place
				var colorNoPlace = Color8(255, 73, 68, 106)
				$Perish/PlacementDenial/CollisionShape3D/AreaPlaceableIndicator.mesh.material.albedo_color = colorNoPlace
			placeable = false

func preview_follow_end():
	add_collision()


func remove_collision():
	$Perish/PlacementDenial.set_collision_layer_value(1, false)
	$Perish/PlacementDenial/CollisionShape3D/AreaPlaceableIndicator.visible = true
	
	$DetectUnitArea.monitoring = false

func add_collision():
	$Perish/PlacementDenial.set_collision_layer_value(1, true)
	$Perish/PlacementDenial/CollisionShape3D/AreaPlaceableIndicator.visible = false
	
	$DetectUnitArea.monitoring = true


#Stuff for upgrade paths of tower.
#Handler for cooldown calculation stuff
func update_cooldown():
	cooldown = 1 / atk_speed
	cooldown_timer.wait_time = cooldown


#Handles processing of tower upgrade. We assume cost req is checked prior to call.
#This will only pop upgrades list. We assume cost array was popped to give the pay function its int.
func upgrade_tower():
	if len(upgrades) != 0:
		print("Upgrading tower...")
		#grabbing current upgrade and unpacking it.
		var upgrade = upgrades.pop_back()
		var stats = upgrade[0]
		var changes = upgrade[1]
		
		#Length of stats and changes should be equal
		if len(stats) == len(changes):
			for i in len(upgrade[0]):
				if stats[i] == "Damage":
					damage += changes[i]
				elif stats[i] == "Range":
					atk_range += changes[i]
					update_range()
				elif stats[i] == "Attack Speed":
					atk_speed += changes[i]
					update_cooldown()
				else:
					print("ERROR! Unknown stat, skipping.")
		else:
			print("ERROR! Tower upgrade failed due to missing upgrade data.")
	else:
		print("ERROR! No upgrades remain! You, may not like it but this is what peak performance looks like.")
		
	return

#Below is all the stuff for detecting mouse actions to control upgrade indicator and upgrade attempt.

#Double clicking tower should attempt upgrade if not preview. Based on if they click the tower.
func _on_perish_input_event(_camera, event, _event_position, _normal, _shape_idx):
	if event is InputEventMouseButton and is_preview == false:
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click == true:
			var upgradeCostSize = len(upgrade_cost)
			
			if upgradeCostSize != 0:
				if Currency.towerCoin >= upgrade_cost[upgradeCostSize-1]:
					
					Currency.pay_towerCoin(upgrade_cost.pop_back())
					upgrade_tower()
					
				else:
					print("ERROR! Not enough tC! Sorry, no loans.")
			else:
				print("ERROR! No more upgrade costs remain! You, may not like it but this is what peak performance looks like.")


#Seeing if user is hovering the tower and its not preview. If so, indicates upgrade status indicator.
func _on_perish_mouse_entered():
	if is_preview == false:
		$"Upgrade Indicator".show()
		
		mouse_hover = true

#Seeing if user left hovering the tower and its not preview. If so, removes upgrade status indicator.
func _on_perish_mouse_exited():
	if is_preview == false:
		$"Upgrade Indicator".hide()
		
		mouse_hover = false

#Sees current status of currency and updates upgrade status indicator based on it.
func update_upgrade_indicator():
	var upgradeCostSize = len(upgrade_cost)
	var upgradeIndicator = $"Upgrade Indicator/MeshInstance3D"
	
	if upgradeCostSize == 0: #There are no upgrades remaining
		var goldColor = Color8(255, 255, 0, 255)
		upgradeIndicator.mesh.material.albedo_color = goldColor
		upgradeIndicator.mesh.material.emission = goldColor
	elif upgrade_cost[upgradeCostSize-1] <= Currency.towerCoin: #They have the money
		var greenColor = Color8(16, 255, 5, 255)
		upgradeIndicator.mesh.material.albedo_color = greenColor
		upgradeIndicator.mesh.material.emission = greenColor
	else: #They don't have the money.
		var redColor = Color8(255, 0, 15, 255)
		upgradeIndicator.mesh.material.albedo_color = redColor
		upgradeIndicator.mesh.material.emission = redColor
	
	return

#Updating range visuals.
#NOTE: This will need to change with range shape as this is built for a circle.
func update_range():
	# Set visual stuff
	$RangeIndicator.mesh.top_radius = atk_range - 0.5
	$RangeIndicator.mesh.bottom_radius = atk_range
	
	# Set gameplay stuff
	unit_detection_shape.shape.radius = atk_range
