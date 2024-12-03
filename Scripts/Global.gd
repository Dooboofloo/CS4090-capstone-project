extends Node

#TODO: Score stuff goes here
#var scoreTracker = []
var PLAYER_SCORE = 0

const UNIT_ATTACK_COOLDOWN = 1.0

var UNIT_ATTACK_TIMER

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	UNIT_ATTACK_TIMER = Timer.new()
	UNIT_ATTACK_TIMER.wait_time = UNIT_ATTACK_COOLDOWN
	UNIT_ATTACK_TIMER.autostart = true
	self.add_child(UNIT_ATTACK_TIMER)
	

#Handling resetting of all variables that need to be reset and storing player score.
#Takes a variable called storage if given which is a list of other items to store given by caller.
#Storage should take the format [["<Type>", <item>], ...]
func game_over(storage = []):
	#Checking to make sure the game is over.
	if Currency.grugarians > 0:
		print("ERROR! There are still Grugarians left to fight!")
		return
	
	# Reset stats
	#reset_stats()
	
	#Handling given items to store.
	#for i in len(storage):
		#if storage[i][0] == "Score":
			#scoreTracker.append(storage[i][1])
		
		#NOTE: Using the above as example, you can add more things that game_over should track,
		#NOTE: you just need to make sure you add the necessary content to global. Mainly for taking things
		#NOTE: from gamestate at gameover.
		
	#Notifying player
	print()
	print("!--------------!GAME OVER!--------------!")
	print("The streets of Grugaria are silent. Grag's hand holds a crown of a lost nation. Grugaria has fallen.")
	print("A passing dimension traveling Grugarian apostle records your stats within G.R.U.G.")
	print()
	
	get_tree().change_scene_to_file("res://Scenes/game_over.tscn")

func reset_stats():
	#Resetting grug vars
	Currency.grugarians = 100
	Currency.grugarianGen = [["Base", 2]]
	
	#Resetting tower vars
	Currency.towerCoin = 0
	Currency.towerCoinGen = [["Base", 1]]
	
	#Things we reset to be safe than sorry.
	Currency.startTimeTC = 0
	Currency.startTimeGrug = 0
	Currency.genIntervalTC = 2000
	Currency.genIntervalGrug = 4000
	
	# Reset player score
	Global.PLAYER_SCORE = 0

func add_score(score: int):
	PLAYER_SCORE += score

func remove_score(score: int):
	PLAYER_SCORE -= score
