extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	placement()


func placement():
	#attempting block placement in world
	const RAY_LENGTH = 100
	#Checking for if the user left clicked
	if Input.is_action_just_pressed("left_click"): 
		
		#This portion is ray casting.
		var space_state = get_world_3d().direct_space_state
		var mousepos = get_viewport().get_mouse_position()
		#Getting general state of space and where the mouse is at all times.

		#Setting our cast to start from our mouse (this case it will always be camera)
		var origin = %Camera3D.project_ray_origin(mousepos)
		#Finding the end of our ray cast by adding the position where your mouse would be in the 3D world times how long it is.
		var end = origin + %Camera3D.project_ray_normal(mousepos) * RAY_LENGTH
		#Setting up the query for asking the physics server to give us ray info.
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		#Making it so that it collides only with areas
		query.collide_with_areas = true
		query.collide_with_bodies = false
	
		#Sending out our raycast finaly and getting the positional info and data of point.
		var result = space_state.intersect_ray(query)
		print(result)
	
		#This part is checking results and placing whatever needs to be.
		if result.get('collider') == %Placeable_Area:
			#Preloading scene with our model
			var model = preload("res://indev/Caveman Age Map Stuff/DummyTower.tscn")
			#Duplicating the object
			var newTower = model.instantiate()
			#Setting locationwhere it should appear
			newTower.position = result.get('position')
			#Adding the tower to the scene.
			add_child(newTower)
			print("Done!")
		else:
			print("NO PLACE")
