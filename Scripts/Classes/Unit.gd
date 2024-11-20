class_name Unit
extends PathFollow3D

enum ALIGNMENT {ENEMY, ALLY}

@onready var unit_collision_area = $UnitCollisionArea

@export var unit_name: String
@export var alignment: ALIGNMENT
@export var move_speed: float = 5.0
@export var damage: int = 1
@export var health: int = 5

#This exists mainly for base damage calculations.
var maxHealth: int = 5

@export var cost: int = 7 # Cost for unit to be placed. Only matters for player deployment.

var velocity = 0

var IS_MOVING = false
var PATH_TO_FOLLOW = null

var IS_FIGHTING = false
var CLASHING_UNIT = null

func _ready() -> void:
	self.loop = false
	
	# Detect when other units interact
	unit_collision_area.connect("area_entered", _area_entered)
	unit_collision_area.connect("area_exited", _area_exited)
	Global.UNIT_ATTACK_TIMER.connect("timeout", _global_unit_attack_step)

func _process(delta: float) -> void:
	
	if IS_MOVING and PATH_TO_FOLLOW != null:
		
		velocity = lerp(velocity, move_speed, 0.01) # Smooth acceleration (helps with collision issues)
		
		if self.alignment == ALIGNMENT.ENEMY:
			# Unit is an enemy
			self.progress += velocity * delta
			
			# If an enemy makes it to its destination...
			if self.progress_ratio >= 1.0:
				crash_castle()
			
		else:
			# Unit is an ally
			self.progress -= velocity * delta
			
			if self.progress_ratio <= 0.0:
				die_for_grug()


func start_path(path: Path3D):
	# Only add self to the path if it hasn't been added before
	if PATH_TO_FOLLOW == null:
		PATH_TO_FOLLOW = path
		path.add_child(self) # Add self to path's children, then start moving
		
		velocity = move_speed
		IS_MOVING = true
		
		if self.alignment == ALIGNMENT.ALLY:
			self.progress_ratio = 1.0 # Allies move "backwards" down the path

# Function for doing damage to other unit
func deal_damage(receiver: Unit):
	receiver.take_damage(damage)

func take_damage(amount: int):
	health -= amount
	
	# TODO: Play a sound?
	changeHealthBar()
	
	if health <= 0:
		die()

func die():
	print("Died")
	self.queue_free()

func crash_castle():
	# TODO
	# for now just kill it and print a message
	
	#NOTE: This is the base damage calc. Idea is that the damage is based on unit damage and cost reduced by current health %.
	var baseDmg = ceil(float(damage) * (float(health)/float(maxHealth)) * float(cost))
	
	print("Castle Crashed! The Gragarian has killed ", baseDmg, " loyal Grugarians.")
	die()
	
	#The unit will not handle checking for gameover state. Probably the map will.
	Currency.pay_grugarians(baseDmg)

func die_for_grug():
	# TODO: Figure out what to do when an allied unit makes it to end of path
	print("Yeah we uhhhh crashed the enemy castle yuh")
	die()


func _area_entered(area: Area3D):
	var unit = area.get_parent()
	
	if unit is Unit:
		# If the colliding enemy is an enemy unit, start fighting!!
		if unit.alignment != self.alignment:
			begin_fighting(unit)
			IS_MOVING = false
			velocity = 0.0
			
		else:
			if (not unit.IS_MOVING) or unit.IS_FIGHTING:
				IS_MOVING = false
				velocity = 0.0

func _area_exited(area: Area3D):
	var unit = area.get_parent()
	
	if unit is Unit:
		IS_MOVING = true

func begin_fighting(clashing_unit: Unit):
	IS_FIGHTING = true
	CLASHING_UNIT = clashing_unit

func stop_fighting():
	IS_FIGHTING = false
	CLASHING_UNIT = null
	IS_MOVING = true

func _global_unit_attack_step():
	if IS_FIGHTING and CLASHING_UNIT != null:
		var will_kill = ((CLASHING_UNIT.health - self.damage) <= 0)
		
		print("Dealing damage!")
		deal_damage(CLASHING_UNIT)
		
		if will_kill:
			stop_fighting()

#Change health bar graphic based on current health state.
#We can make this an actual health bar or use colors on the unit itself.
func changeHealthBar():
	var percentHealth: float = float(health) / float(maxHealth)
	
	if percentHealth <= 2.5/4.0 and percentHealth > 1.0/4.0:
		var texture = load('res://Textures/healthbarHurt.png')
		$HealthBar.texture = texture
	elif percentHealth <= 1.0/4.0:
		var texture = load('res://Textures/healthbarSevere.png')
		$HealthBar.texture = texture
