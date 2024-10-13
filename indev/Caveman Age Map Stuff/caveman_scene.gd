extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#Just to have the test unit move along the path. Probably use this idea for other units?
var forward = true
func _physics_process(delta):
	const move_speed := 15.0 #Sets the type to whatever it is being set equal to
	
	if %PathFollow3D.progress_ratio == 1:
		forward = false
	elif %PathFollow3D.progress_ratio == 0:
		forward = true
	
	if forward == true:
		%PathFollow3D.progress += move_speed * delta
	elif forward == false:
		%PathFollow3D.progress -= move_speed * delta
