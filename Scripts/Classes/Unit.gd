class_name Unit
extends PathFollow3D

enum ALIGNMENT {ENEMY, ALLY}

@export var unit_name: String
@export var alignment: ALIGNMENT
@export var move_speed: float = 10.0
@export var damage: int = 1
@export var health: int = 5

@export var cost: int = 7 # Cost for unit to be placed. Only matters for player deployment.

var IS_MOVING = false
var PATH_TO_FOLLOW = null

func _ready() -> void:
	self.loop = false

func _process(delta: float) -> void:
	if IS_MOVING and PATH_TO_FOLLOW != null:
		if self.alignment == ALIGNMENT.ENEMY:
			# Unit is an enemy
			self.progress += move_speed * delta
			
			# If an enemy makes it to its destination...
			if self.progress_ratio >= 1.0:
				crash_castle()
		else:
			# Unit is an ally
			self.progress -= move_speed * delta
			
			if self.progress_ratio <= 0.0:
				# TODO: Figure out what to do when an allied unit makes it to end of path
				print("Yeah we uhhhh crashed the enemy castle yuh")
				die()


func start_path(path: Path3D):
	# Only add self to the path if it hasn't been added before
	if PATH_TO_FOLLOW == null:
		PATH_TO_FOLLOW = path
		path.add_child(self) # Add self to path's children, then start moving
		
		IS_MOVING = true
		
		if self.alignment == ALIGNMENT.ALLY:
			self.progress = 1.0 # Allies move "backwards" down the path

# Function for doing damage to other unit
func deal_damage(receiver: Unit):
	receiver.take_damage(damage)

func take_damage(amount: int):
	health -= amount
	
	if health <= 0:
		die()

func die():
	print("Died")
	self.queue_free()

func crash_castle():
	# TODO
	# for now just kill it and print a message
	
	#If population is health, remove grugarians based on dmg or a calc of dmg, cost, hp (cost & hp = condition/skill).
	#If population is not health, same thing but remove basehealth. Currency.pay_grugarians(int)
	
	print("Castle Crashed!")
	die()
