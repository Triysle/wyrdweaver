extends Node2D
class_name MainGame

# References to main scenes
@onready var first_page: Node2D
var current_page: Node2D

# Called when the node enters the scene tree for the first time
func _ready():
	# Load the first page
	load_first_page()

# Load the first page of the book
func load_first_page() -> void:
	var first_page_scene = load("res://scenes/first_page.tscn")
	if first_page_scene:
		first_page = first_page_scene.instantiate()
		add_child(first_page)
		current_page = first_page
		
		# Connect any needed signals
		# (None in this simple implementation)

# Handle any input that should be processed at the game level
func _input(event: InputEvent) -> void:
	# Example: debug shortcuts
	if event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_F1:
					# Toggle debug overlay (you could implement this)
					print("Debug key pressed")
				KEY_R:
					# Reset current page
					reset_current_page()

# Reset the current page
func reset_current_page() -> void:
	if current_page:
		# Remove current page
		current_page.queue_free()
		await get_tree().process_frame
		
		# Load the first page again
		load_first_page()

# Save game state (basic implementation)
func save_game() -> void:
	var save_data = {
		"flags": GameSettings.flags,
		# Add other data as needed
	}
	
	var save_file = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
	if save_file:
		save_file.store_string(JSON.stringify(save_data))
		print("Game saved")
	else:
		print("Failed to save game")

# Load game state (basic implementation)
func load_game() -> void:
	if FileAccess.file_exists("user://save_game.dat"):
		var save_file = FileAccess.open("user://save_game.dat", FileAccess.READ)
		var json_string = save_file.get_as_text()
		var json = JSON.new()
		var error = json.parse(json_string)
		
		if error == OK:
			var save_data = json.data
			
			# Load flags
			if save_data.has("flags"):
				GameSettings.flags = save_data["flags"]
			
			# Reset and load appropriate page based on progress
			reset_current_page()
			print("Game loaded")
		else:
			print("Error parsing save file: ", error)
	else:
		print("No save file found")
