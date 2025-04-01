extends Node2D
class_name FirstPage

# References to key elements
@onready var runic_circle = $RunicCircle
@onready var rune_tray = $RuneTray
@onready var resource_container = $ResourceContainer

func _ready():
	# Connect signals
	_connect_signals()

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

# Handle resource generation from the circle
func _on_resource_generated(amount):
	if resource_container:
		resource_container.add_resource(amount)
	else:
		print("ERROR: ResourceContainer not found when generating resources!")

# Handle circle activation
func _on_circle_activated():
	if resource_container:
		resource_container.start_particles()
	else:
		print("ERROR: ResourceContainer not found when activating circle!")

# Handle rune drag started
func _on_rune_drag_started(_rune):
	# Reserved for future implementation
	pass

# Handle rune drag ended
func _on_rune_drag_ended(_rune):
	# Reserved for future implementation
	pass
