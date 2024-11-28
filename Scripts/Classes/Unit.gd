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
@export var maxHealth: int = 5

@export var cost: int = 7 # Cost for unit to be placed. Only matters for player deployment.

#CAUTION: When the waves are implemented, this should be changed based on current wave, to make enemy units not die quick.
@export var enemyMult: float = 1.5 #A multiplier for the enemy. Right now it buffs health of enemy unit only.

var velocity = 0

var IS_MOVING = false
var PATH_TO_FOLLOW = null

var IS_FIGHTING = false
var CLASHING_UNIT = null

#Model stuff
var hurtHealth = preload("res://Textures/healthbarHurt.png")
var severeHealth = preload("res://Textures/healthbarSevere.png")

func _ready() -> void:
	
	#Handling if the user has enough grugarians to spawn unit.
	if self.alignment == ALIGNMENT.ALLY:
		if Currency.grugarians < self.cost:
			print("ERROR: Not enough grugarians available to train unit!")
			self.queue_free()
		elif Currency.grugarians == self.cost:
			print("ERROR: Grug has better things to do than train a unit (this would kill you).")
			self.queue_free()
		else:
			Currency.pay_grugarians(self.cost)
	
	
	self.loop = false
	
	# Detect when other units interact
	unit_collision_area.connect("area_entered", _area_entered)
	unit_collision_area.connect("area_exited", _area_exited)
	
	#Detect when units are in the ranged attack area if ranged unit. (Heal/Ranged)
	if self.unit_name in ["HealUnit", "RangedUnit"]:
		var ranged_collision_area = $"Ranged Area"
		ranged_collision_area.connect("area_entered", _ranged_area_entered)
		ranged_collision_area.connect("area_exited", _ranged_area_exited)
		
		#Moving around collision area if an enemy
		if self.alignment == ALIGNMENT.ENEMY:
			ranged_collision_area.rotate_x(deg_to_rad(180))
	
	Global.UNIT_ATTACK_TIMER.connect("timeout", _global_unit_attack_step)
	
	#Buffing if an enemy unit
	if self.alignment == ALIGNMENT.ENEMY:
		maxHealth = maxHealth * enemyMult
		health = maxHealth
		

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
	#Handling if healer
	if self.unit_name == "HealUnit":
		receiver.heal_damage(damage)
	else:
		receiver.take_damage(damage)

func take_damage(amount: int):
	health -= amount
	
	# TODO: Play a sound?
	changeHealthBar()
	
	if health <= 0:
		die()

#Function for healer unit.
func heal_damage(amount: int):
	if health < maxHealth:
		health += amount
		health = min(maxHealth, health) # Prevent overheal
		
		changeHealthBar()

func die():
	print("Died")
	self.queue_free()

func crash_castle():
	
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
		# If the colliding enemy is an enemy unit and melee, start fighting!!
		if unit.alignment != self.alignment:
			if (not self.IS_FIGHTING):
				begin_fighting(unit)
			IS_MOVING = false
			velocity = 0.0
			
		else:
			if (not unit.IS_MOVING) or (unit.IS_FIGHTING and (unit.unit_name not in ["HealUnit", "RangedUnit"])):
				IS_MOVING = false
				velocity = 0.0

func _area_exited(area: Area3D):
	var unit = area.get_parent()
	
	if unit is Unit:
		IS_MOVING = true

func _ranged_area_entered(area: Area3D):
	var unit = area.get_parent()
	
	if unit is Unit:
		if (unit != self) and (self.IS_FIGHTING == false):
			if (unit.alignment == self.alignment) and (self.unit_name == "HealUnit"):
				begin_fighting(unit)
			elif (unit.alignment != self.alignment) and (self.unit_name == "RangedUnit"):
				begin_fighting(unit)

func _ranged_area_exited(area: Area3D):
	var unit = area.get_parent()
	
	if unit is Unit:
		if self.unit_name in ["HealUnit", "RangedUnit"]:
			IS_FIGHTING = false
			CLASHING_UNIT = null

func begin_fighting(clashing_unit: Unit):
	IS_FIGHTING = true
	CLASHING_UNIT = clashing_unit

func stop_fighting():
	IS_FIGHTING = false
	CLASHING_UNIT = null
	
	#If statement cause if ranged will kill it should not start moving.
	if self.unit_name != "RangedUnit":
		IS_MOVING = true

func _global_unit_attack_step():
	if IS_FIGHTING and CLASHING_UNIT != null:
		var will_kill = ((CLASHING_UNIT.health - self.damage) <= 0)
		
		if self.unit_name == "HealUnit":
			print("Healing damage!")
			will_kill = false
		else:
			print("Dealing damage!")
		deal_damage(CLASHING_UNIT)
		
		if will_kill:
			stop_fighting()

#Change health bar graphic based on current health state.
#We can make this an actual health bar or use colors on the unit itself.
func changeHealthBar():
	var percentHealth: float = float(health) / float(maxHealth)
	
	if percentHealth <= 2.5/4.0 and percentHealth > 1.0/4.0:
		var texture = hurtHealth
		$HealthBar.texture = texture
	elif percentHealth <= 1.0/4.0:
		var texture = severeHealth
		$HealthBar.texture = texture
