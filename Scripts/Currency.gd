extends Node

#Variables for all "currencies". Like health, score, etc.
#TODO: Show current state of these currencies in UI.
var towerCoin = 0 #Curerncy for towers
var grugarians = 100 #Currency for units. Assuming this is also base health.
#var friendlyBase = 100 #This is just here in case we wish to decouple pop/unit currency from health.

#Currency Generation Modifiers. IF this happens this will keep any generation modification that occurs.
#Base is starting generation value with no mods.
var towerCoinGen = [["Base", 1]] #Additions should be arrays with 2 values.
var grugarianGen = [["Base", 2]] #Additions should be arrays with 2 values.

#Time isn't really a currency but its needed for base currency calculations.
var startTime = 0
var genInterval = 1000 #In milliseconds. The interval that must pass for currency gen to occur.

# Called when the node enters the scene tree for the first time.
func _ready():
	#Grabbing a time to start with for currency calculation. Idk a better spot.
	startTime = Time.get_ticks_msec()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#not doing calculation unless current scene is a map.
	#This check will change when more maps are in. Prob use an array with all map scene map node names.
	if get_tree().root.get_child(-1).get_name() == "Caveman Map":
		var currentTime = Time.get_ticks_msec()
		#Checking to see if one second has passed.
		if (currentTime - startTime) >= genInterval:
			#Calling on functions that require a second to pass to calculate.
			currency_calc_tower()
			currency_calc_unit()
			
			#Changing startTime variable to check for second change again.
			startTime = currentTime
	
	#TODO: Make it so that if the scene changes outside of maps that all vars reset to default. Game reset.


#This holds every calculation that deals with towercoin gen. May take a dict argument later for gen rate change/bonus.
#Not for adding or removing towerCoins 
func currency_calc_tower(modification: Array = []):
	var coinGenerated = 0
	if len(modification) == 0:
		coinGenerated = evaluate_generation(towerCoinGen)
	else:
		coinGenerated = evaluate_generation(towerCoinGen, modification)
	
	towerCoin += coinGenerated
	
	print("Current tC Balance: ", towerCoin)


#Calculates the correct generation value for the currency. Possible to be seperated based on currency if needed.
func evaluate_generation(prevModifications: Array, modification: Array = []):
	if len(modification) == 2:
		prevModifications.append(modification)
	elif len(modification) != 0:
		print("ERROR!: Generation modification not added due to invalid form.")
	
	var generation = 0
	
	for genChange in prevModifications:
		#This is where we evaluate each modification and apply it.
		#Index 0 will be the Operation, and index 1 the value to do the operation with.
		if genChange[0] == "Base":
			generation = genChange[1]
		
		#TODO: Write cases for other modification types. More elif which can take things like "Add", "Multiply", etc.

	return generation


#This holds every calculation that deals with the unit/health currency gen. Maybe take dict arg later as opt.
#Not for adding or removing grugarians.
func currency_calc_unit(modification: Array = []):
	var grugariansBorn = 0
	if len(modification) == 0:
		grugariansBorn = evaluate_generation(grugarianGen)
	else:
		grugariansBorn = evaluate_generation(grugarianGen, modification)
	
	grugarians += grugariansBorn
	
	print("Current Grugarian Population: ", grugarians)


#Function for any REMOVAL of towerCoin from player.
func pay_towerCoin(cost: int):
	towerCoin -= cost

#Function for any REMOVAL of grugarians from player.
func pay_grugarians(cost: int):
	grugarians -= cost

#Function for any one off ADDING of towerCoin to player account.
func receive_towerCoin(bonus: int):
	towerCoin += bonus

#Function for any one off ADDING of grugarians to player account.
func receive_grugarians(bonus: int):
	grugarians += bonus
