# ALL TOWERS MUST HAVE DetectUnitArea ON LAYER 2 FOR COLLISION. This stops tower placement from being affected by it.

class_name Tower
extends Node3D

@export var tower_name: String
@export var damage: int = 1
@export var atk_speed: float = 2.0 # ex. atk speed 2 = 2 shots/second = 0.5 cooldown
@export var range: float = 5.0

@onready var cooldown = 1 / atk_speed

@export var towerCost: int = 1 #I expect this to change. This is just tower cost to place.

@onready var unit_detection_area = $DetectUnitArea
@onready var unit_detection_shape = $DetectUnitArea/DetectUnitCollisionShape
@onready var cooldown_timer = $CooldownTimer

var ENEMIES_IN_RANGE = [] # A list of enemies that are currently in range
var is_preview = false #Variable for us to check if the unit is placed yet or just a preview.
var placeable = false #Variable for us to know if the tower can be placed or not.

#This variable allows us to only addcollision and removecollision once, rather than every delta like it was before.
#Since there is an order to it I just make it count down and check the value to see if we call the funciton.
#removecollision sees this is 2 and then runs that function, decrements to 1. addcollision sees 1, runs, decrements.
var only_once = 2

func _ready() -> void:
	# Set visual stuff
	$RangeIndicator.mesh.top_radius = range - 0.5
	$RangeIndicator.mesh.bottom_radius = range
	
	# Set gameplay stuff
	unit_detection_shape.shape.radius = range
	cooldown_timer.wait_time = cooldown
	
	# Connect signals
	unit_detection_area.connect("body_entered", _on_detect_unit_area_body_entered)
	unit_detection_area.connect("body_exited", _on_detect_unit_area_body_exited)

func _process(delta: float) -> void:
	
	if cooldown_timer.is_stopped() and len(ENEMIES_IN_RANGE) > 0:
		print("Pew!")
		
		ENEMIES_IN_RANGE.sort_custom( func(a, b): return global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(a.global_position) )
		var closest_unit = ENEMIES_IN_RANGE[0]
		deal_damage(closest_unit)
	
	#Checking if we are in preview mode.
	if is_preview == true:
		preview_follow()
	#TODO: If you have a better idea for this only to be called once, change this!
	elif (is_preview == false) and (only_once == 1):
		preview_follow_end() 
		only_once -= 1

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
