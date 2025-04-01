extends Node2D
class_name FirstPage

# References to key elements
@onready var runic_circle = $RunicCircle
@onready var rune_tray = $RuneTray
@onready var resource_container = $ResourceContainer

# Tutorial elements
@onready var tutorial_hand = $TutorialElements/TutorialHand
var tutorial_active = true

func _ready():
	# Connect signals
	_connect_signals()
	
	# Start the tutorial if enabled
	if tutorial_active:
		start_tutorial()

# Connect all necessary signals
func _connect_signals():
	# Connect circle to resource container
	if runic_circle:
		runic_circle.resource_generated.connect(_on_resource_generated)
		runic_circle.circle_activated.connect(_on_circle_activated)
	else:
		print("ERROR: RunicCircle not found!")
	
	# Connect runes in tray
	if rune_tray and rune_tray.has_node("RuneContainer"):
		for rune in rune_tray.get_node("RuneContainer").get_children():
			if rune is Rune:
				rune.rune_drag_started.connect(_on_rune_drag_started)
				rune.rune_drag_ended.connect(_on_rune_drag_ended)
	else:
		print("ERROR: RuneTray or RuneContainer not found!")

# Start the tutorial sequence
func start_tutorial():
	# Check if the tutorial hand exists
	if not tutorial_hand:
		print("ERROR: TutorialHand not found!")
		tutorial_active = false
		return
		
	# Check if the nodes we need for the tutorial exist
	if not rune_tray or not rune_tray.has_node("RuneContainer/RuneSowilo") or not runic_circle or not runic_circle.has_node("CentralNode"):
		print("ERROR: Required nodes for tutorial not found!")
		tutorial_active = false
		return
	
	# Show the tutorial hand pointing to the central rune
	show_tutorial_hand(rune_tray.get_node("RuneContainer/RuneSowilo").global_position)
	
	# Create a moving animation to the central node
	var tween = create_tween()
	tween.tween_property(tutorial_hand, "position", 
		runic_circle.get_node("CentralNode").global_position - global_position, 2.0)
	tween.tween_callback(func(): tutorial_hand.visible = false)

# Show the tutorial hand at a specific position
func show_tutorial_hand(target_position):
	if tutorial_hand:
		tutorial_hand.visible = true
		tutorial_hand.global_position = target_position

# Handle resource generation from the circle
func _on_resource_generated(amount):
	if resource_container:
		resource_container.add_resource(amount)
	else:
		print("ERROR: ResourceContainer not found when generating resources!")

# Handle circle activation
func _on_circle_activated():
	print("Circle activated! Trying to start resource container particles...")
	if resource_container:
		resource_container.start_particles()
		print("Resource container particles started!")
	else:
		print("ERROR: ResourceContainer not found when activating circle!")
		
	# End tutorial mode
	tutorial_active = false
	if tutorial_hand:
		tutorial_hand.visible = false

# Handle rune drag started
func _on_rune_drag_started(rune):
	# If tutorial is active, hide the hand when any rune is dragged
	if tutorial_active and tutorial_hand:
		tutorial_hand.visible = false

# Handle rune drag ended
func _on_rune_drag_ended(rune):
	# Nothing special to do here for now
	pass
