extends Camera3D

@export var acceleration = 25.0
@export var moveSpeed = 7.0
@export var mouseSpeed = 300.0

var velocity = Vector3.ZERO
var lookAngles = Vector2.ZERO
var yConstraint = [0.51, 15]
var xConstraint = [-30,30]
var zConstraint = [-60,60]



# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#Below here is stuff for the camera moving around.
	lookAngles.y = clamp(lookAngles.y, PI / -2, PI / 2)
	set_rotation(Vector3(lookAngles.y, lookAngles.x, 0))
	
	var direction = updateDirection()
	
	if direction.length_squared() > 0:
		velocity += direction * acceleration * delta
	if velocity.length() > moveSpeed:
		velocity = velocity.normalized() * moveSpeed

	translate(velocity * delta)
	
	limitCamera()

func _input(event):
	if Input.is_action_just_pressed("right_click"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED) and (event is InputEventMouseMotion):
		lookAngles -= event.relative / mouseSpeed


func updateDirection():
	var dir = Vector3()
	if Input.is_action_pressed("move_forward"):
		dir += Vector3.FORWARD
	if Input.is_action_pressed("move_backward"):
		dir += Vector3.BACK
	if Input.is_action_pressed("move_left"):
		dir += Vector3.LEFT
	if Input.is_action_pressed("move_right"):
		dir += Vector3.RIGHT
	if Input.is_action_pressed("move_up"):
		dir += Vector3.UP
	if Input.is_action_pressed("move_down"):
		dir += Vector3.DOWN
	
	if dir == Vector3.ZERO:
		velocity = Vector3.ZERO #No input? No movement.
		
	return dir.normalized() #Dividing all nums in vector by largest num to make nums smaller.


#Limits camera movement
func limitCamera():
	#limiting x position. changing x by a larger position presents jitters
	while position.x > xConstraint[1]:
		position.x -= .0001
	while position.x < xConstraint[0]:
		position.x += .0001
	
	#limiting y position
	while position.y > yConstraint[1]:
		position.y -= .0001
	while position.y < yConstraint[0]:
		position.y += .0001
	
	#limiting z position
	while position.z > zConstraint[1]:
		position.z -= .0001
	while position.z < zConstraint[0]:
		position.z += .0001
