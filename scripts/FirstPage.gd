extends Node2D
class_name FirstPage

# References to key elements
@onready var runic_circle = $RunicCircle
@onready var rune_tray = $RuneTray
@onready var resource_container = $ResourceContainer

func _ready():
	print("FirstPage ready - initializing nodes")
	
	# Initialize the rune tray system
	_initialize_rune_tray()
	
	# Wait one frame to make sure all nodes are fully initialized
	await get_tree().process_frame
	
	# Connect signals
	_connect_signals()

# Initialize the rune tray
func _initialize_rune_tray():
	# Make sure RuneTray has the correct script
	if not rune_tray.has_script() or not rune_tray is RuneTray:
		rune_tray.set_script(load("res://scripts/RuneTray.gd"))
		print("Added RuneTray script")

# Connect all necessary signals
func _connect_signals():
	# Connect circle to resource container
	if runic_circle:
		# Explicitly disconnect any previous connections to avoid duplicates
		if runic_circle.is_connected("resource_generated", _on_resource_generated):
			runic_circle.resource_generated.disconnect(_on_resource_generated)
		
		if runic_circle.is_connected("circle_activated", _on_circle_activated):
			runic_circle.circle_activated.disconnect(_on_circle_activated)
			
		# Connect the signals
		runic_circle.resource_generated.connect(_on_resource_generated)
		runic_circle.circle_activated.connect(_on_circle_activated)
		print("RunicCircle signals connected successfully")
	else:
		print("ERROR: RunicCircle not found!")
	
	# Connect runes in tray
	if rune_tray and rune_tray.has_node("RuneContainer"):
		for rune in rune_tray.get_node("RuneContainer").get_children():
			if rune is Rune:
				# Disconnect existing connections to avoid duplicates
				if rune.is_connected("rune_drag_started", _on_rune_drag_started):
					rune.rune_drag_started.disconnect(_on_rune_drag_started)
				
				if rune.is_connected("rune_drag_ended", _on_rune_drag_ended):
					rune.rune_drag_ended.disconnect(_on_rune_drag_ended)
				
				# Connect the signals
				rune.rune_drag_started.connect(_on_rune_drag_started)
				rune.rune_drag_ended.connect(_on_rune_drag_ended)
		print("Rune signals connected successfully")
	else:
		print("ERROR: RuneTray or RuneContainer not found!")
	
	# Check resource container
	if resource_container:
		print("ResourceContainer found")
	else:
		print("ERROR: ResourceContainer not found!")

# Handle resource generation from the circle
func _on_resource_generated(amount):
	if resource_container:
		print("Resource generated: ", amount)
		resource_container.add_resource(amount)
	else:
		print("ERROR: ResourceContainer not found when generating resources!")

# Handle circle activation
func _on_circle_activated():
	print("FirstPage: Circle activated signal received")
	if resource_container:
		print("Starting resource container particles")
		resource_container.start_particles()
	else:
		print("ERROR: ResourceContainer not found when activating circle!")

# Handle rune drag started
func _on_rune_drag_started(rune):
	print("Rune drag started: ", rune.rune_type)
	
	# If it's coming from the tray, free up its slot
	if rune.current_state == "in_tray" and rune_tray and rune_tray.has_method("free_slot_for_rune"):
		rune_tray.free_slot_for_rune(rune)

# Handle rune drag ended
func _on_rune_drag_ended(rune):
	print("Rune drag ended: ", rune.rune_type)
