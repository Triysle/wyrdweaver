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
	runic_circle.resource_generated.connect(_on_resource_generated)
	runic_circle.circle_activated.connect(_on_circle_activated)
	
	# Connect runes in tray
	for rune in rune_tray.get_node("RuneContainer").get_children():
		if rune is Rune:
			rune.rune_drag_started.connect(_on_rune_drag_started)
			rune.rune_drag_ended.connect(_on_rune_drag_ended)

# Start the tutorial sequence
func start_tutorial():
	# Show the tutorial hand pointing to the central rune
	show_tutorial_hand($RuneTray/RuneContainer/RuneSowilo.global_position)
	
	# Create a moving animation to the central node
	var tween = create_tween()
	tween.tween_property(tutorial_hand, "position", 
		$RunicCircle/CentralNode.global_position - global_position, 2.0)
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

# Handle circle activation
func _on_circle_activated():
	if resource_container:
		resource_container.start_particles()
		
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
