extends Node

# Settings that apply to the entire game
var debug_mode: bool = false
var tutorial_enabled: bool = true
var sound_enabled: bool = false  # Since our game design doesn't use audio

# Resources
var total_resources: Dictionary = {
	"energy": 0,
	"knowledge": 0,
	"time": 0,
	"progress": 0
}

# Game state
var unlocked_pages: Array = [0]  # First page is unlocked by default
var completed_circles: Array = []

func _ready():
	# Set up debug input
	set_process_input(true)

func _input(event):
	# Toggle debug mode with F8
	if event.is_action_pressed("debug_toggle"):
		debug_mode = !debug_mode
		print("Debug mode: ", debug_mode)
	
	# Reset game with R key (only in debug mode)
	if debug_mode and event.is_action_pressed("reset_game"):
		reset_game()
		
# Reset the game state (for debugging)
func reset_game():
	if !debug_mode:
		return
		
	print("Resetting game...")
	
	# Reset resources
	for key in total_resources.keys():
		total_resources[key] = 0
	
	# Reset game state
	unlocked_pages = [0]
	completed_circles = []
	
	# Reload current scene
	get_tree().reload_current_scene()

# Add resources to the global total
func add_resource(resource_type: String, amount: float):
	if resource_type in total_resources:
		total_resources[resource_type] += amount
		
	# Check for page unlocks
	check_unlocks()

# Check if any new pages should be unlocked
func check_unlocks():
	# This will be expanded as more pages are added
	
	# Second page unlocks at 100 energy
	if total_resources["energy"] >= 100 and not unlocked_pages.has(1):
		unlocked_pages.append(1)
		print("Page 1 unlocked!")
