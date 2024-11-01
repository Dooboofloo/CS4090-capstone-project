class_name Unit
extends PathFollow3D

enum ALIGNMENT {ENEMY, ALLY}

@export var unit_name: String
@export var alignment: ALIGNMENT
@export var move_speed: float = 10.0
@export var damage: int = 1
@export var health: int = 5

@export var cost: int = 7 #Cost for unit to be placed. Only matters for player deployment.

var IS_MOVING = false
var PATH_TO_FOLLOW = null

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if IS_MOVING and PATH_TO_FOLLOW != null:
		self.progress += move_speed * delta
		
		# If a unit makes it to its destination...
		if self.progress >= 1.0:
			
			if alignment == ALIGNMENT.ENEMY:
				# if that unit is an enemy, crash the castle
				crash_castle()
			else:
				# otherwise... do something else?
				# TODO: Determine reward for player's units completing their track
				pass

func start_path(path: Path3D):
	# Only add self to the path if it hasn't been added before
	if PATH_TO_FOLLOW == null:
		PATH_TO_FOLLOW = path
		path.add_child(self) # Add self to path's children, then start moving
		
		IS_MOVING = true

# Function for doing damage to other unit
func deal_damage(receiver: Unit):
	receiver.take_damage(damage)

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		die()

func die():
	self.queue_free()

func crash_castle():
	# TODO
	# for now just kill it and print a message
	
	#If population is health, remove grugarians based on dmg or a calc of dmg, cost, hp (cost & hp = condition/skill).
	#If population is not health, same thing but remove basehealth. Currency.pay_grugarians(int)
	
	print("Castle Crashed!")
	die()
