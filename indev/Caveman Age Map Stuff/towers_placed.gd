extends Node3D

var current_preview = [] #Supposed to hold current tower for preview stuff. Prob shouldn't be a list but is nice.


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#Boots up preview of selected tower.
func preview_placement(model_path):
	#Using 3D position function to get our raycast query.
	var result = get_3D_position()
	
	#preventing it from trying to calculate position if ray collides with nothing. (Crashes if not here)
	if result.size() != 0:
	
		if current_preview.is_empty():
			#Preloading scene with our model
			var model = preload("res://indev/Caveman Age Map Stuff/DummyTower.tscn")
			#Duplicating the object
			var newTower = model.instantiate()
			#Setting locationwhere it should appear
			newTower.position = result.get('position')
			#Adding the tower to the scene.
			add_child(newTower)
			current_preview.append(newTower)
			
			current_preview[0].is_preview = true
			
			print("Preview Start")
		else:
			print("Debug: not empty ")
			print(current_preview)
	#Handling clicking of button when no raycast is possible as its based on cursor.
	else:
		if current_preview.is_empty():
			#Preloading scene with our model
			var model = preload("res://indev/Caveman Age Map Stuff/DummyTower.tscn")
			#Duplicating the object
			var newTower = model.instantiate()
			#Setting location where it should appear if button is not in playable area
			var safePosition = %Camera3D.position
			safePosition[1] =  0 
			newTower.position = safePosition
			#Adding the tower to the scene.
			add_child(newTower)
			current_preview.append(newTower)
			
			current_preview[0].is_preview = true
			
			print("Preview Start")


#If preview is canceled or another button is clicked, this removes current preview in world.
func preview_cancel():
	var towerPreview = current_preview.pop_front()
	towerPreview.queue_free()

#Handles checking if the placement is valid and stopping the "preview" (makes tower no longer move)
#This is not handled by the tower itself as if we did that we would get lots firing on left click input.
func placement():
	#We first check to see if they even have a tower to place.
	if !current_preview.is_empty():
		
		#Using 3D position function to get our raycast query.
		var result = get_3D_position()
		#Preventing it from trying to calculate position if ray collides with nothing. (Crashes if not here)
		if result.size() != 0:
			#This part is handling placement of the tower.
			if (current_preview[0].placeable):
				
				current_preview[0].is_preview = false
				Currency.pay_towerCoin(current_preview[0].towerCost)
				current_preview.pop_back()
				
				print("Placement Complete!")
			else:
				print("Invalid placement location / Not enough Tower Coin.")
		else:
			print("No ray collision, preventing calculations.")
	else:
		print("No preview is active, no tower to place.")


func _input(event):
	#Attempt tower placement if left click occurs and preview exists.
	if Input.is_action_just_pressed("left_click") and !current_preview.is_empty():
		placement()
	elif Input.is_action_just_pressed("place_cancel") and !current_preview.is_empty():
		preview_cancel()


func get_3D_position():
	#This function is for whenever you need the position in the world from the camera's view.
	const RAY_LENGTH = 100
	
	#This portion is ray casting.
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()
	#Getting general state of space and where the mouse is at all times.

	#Setting our cast to start from our mouse (this case it will always be camera)
	var origin = %Camera3D.project_ray_origin(mousepos)
	#Finding the end of our ray cast by adding the position where your mouse would be in the 3D world times how long it is.
	var end = origin + %Camera3D.project_ray_normal(mousepos) * RAY_LENGTH
		
	#Setting up the query for asking the physics server to give us ray info.
	#arg1= start position, arg2= end position, arg3= collision mask. ALL AREAS AND OBJ TO COLLIDE SHOULD BE LAYER 1
	var query = PhysicsRayQueryParameters3D.create(origin, end, 1)
		
	#Making it so that it collides only with areas. We look for areas with the right class to allow place
	query.collide_with_areas = true
	#This must be true to prevent tower placement within the path and other objects. Else ray goes through obj.
	query.collide_with_bodies = true
	
	#Sending out our raycast finaly and getting the positional info and data of point.
	var result = space_state.intersect_ray(query)
	
	return result
