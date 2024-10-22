class_name Tower
extends Node3D

@export var tower_name: String
@export var damage: int = 1
@export var atk_speed: float = 2.0 # ex. atk speed 2 = 2 shots/second = 0.5 cooldown
@export var range: float = 5.0

@onready var cooldown = 1 / atk_speed

@onready var unit_detection_area = $DetectUnitArea
@onready var unit_detection_shape = $DetectUnitArea/DetectUnitCollisionShape
@onready var cooldown_timer = $CooldownTimer

var ENEMIES_IN_RANGE = [] # A list of enemies that are currently in range

func _ready() -> void:
	# Set visual stuff
	$RangeIndicator.mesh.top_radius = range - 0.5
	$RangeIndicator.mesh.bottom_radius = range
	
	# Set gameplay stuff
	unit_detection_shape.shape.radius = range
	cooldown_timer.wait_time = cooldown
	
	unit_detection_area

func _process(delta: float) -> void:
	
	if cooldown_timer.is_stopped() and len(ENEMIES_IN_RANGE) > 0:
		# TODO: Figure out a target in the list (most likely the closest unit) and fire at it
		# deal_damage(closest_unit)
		pass

func deal_damage(receiver: Unit):
	# Deal damge
	receiver.take_damage(damage)
	
	# Start a cooldown after attacking
	cooldown_timer.start()

func destroy():
	# Maybe refund some of the player's money here or something
	self.queue_free()

func _on_detect_unit_area_body_entered(body: Node3D):
	if body is Unit:
		# Add that unit to list of enemies
		ENEMIES_IN_RANGE.append(body)

func _on_detect_unit_area_body_exited(body: Node3D):
	if body is Unit:
		if body in ENEMIES_IN_RANGE:
			# Not actually sure if this works
			
			# Remove that unit from the list of enemies
			var index = ENEMIES_IN_RANGE.find(body)
			ENEMIES_IN_RANGE.remove_at(index)
