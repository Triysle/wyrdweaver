extends Node2D
class_name RunicCircle

# Circle properties
@export var resource_generation_rate: float = 1.0

# Node references
@onready var central_node = $CentralNode
@onready var cardinal_nodes = $CardinalNodes
@onready var connection_lines = $ConnectionLines
@onready var activation_particles = $ActivationParticles
@onready var success_indicator = $SuccessIndicator

# State tracking
var correct_nodes = []  # Nodes with correct runes
var is_circle_activated = false
var resource_generation_active = false
var valid_pattern = false

# Signals
signal circle_activated
signal circle_deactivated
signal resource_generated(amount)

func _ready():
	# Set up node connections
	_connect_node_signals()
	
	# Initialize connection lines as invisible
	for line in connection_lines.get_children():
		line.visible = false
	
	# Hide success indicator
	success_indicator.visible = false

# Connect signals from all rune nodes
func _connect_node_signals():
	# Connect central node
	central_node.rune_placed_correctly.connect(_on_rune_placed_correctly)
	central_node.rune_placed_incorrectly.connect(_on_rune_placed_incorrectly)
	central_node.rune_removed.connect(_on_rune_removed)
	
	# Connect cardinal nodes
	for node in cardinal_nodes.get_children():
		if node is RuneNode:
			node.rune_placed_correctly.connect(_on_rune_placed_correctly)
			node.rune_placed_incorrectly.connect(_on_rune_placed_incorrectly)
			node.rune_removed.connect(_on_rune_removed)

# Process resource generation when circle is active
func _process(delta):
	if resource_generation_active:
		var amount = resource_generation_rate * delta
		emit_signal("resource_generated", amount)

# Handle a rune being placed correctly
func _on_rune_placed_correctly(node_position):
	print("Correct rune placed at: ", node_position)
	# Add to correct nodes list if not already there
	if not correct_nodes.has(node_position):
		correct_nodes.append(node_position)
	
	# Update connections
	_update_connections()
	
	# Check if pattern is complete
	_check_pattern_completion()

# Handle a rune being placed incorrectly
func _on_rune_placed_incorrectly(node_position):
	print("Incorrect rune placed at: ", node_position)
	# Remove from correct nodes list if it was there
	if correct_nodes.has(node_position):
		correct_nodes.erase(node_position)
	
	# Update connections
	_update_connections()
	
	# Check if pattern is now incomplete
	_check_pattern_completion()

# Handle a rune being removed
func _on_rune_removed(node_position):
	print("Rune removed from: ", node_position)
	# Remove from correct nodes list if it was there
	if correct_nodes.has(node_position):
		correct_nodes.erase(node_position)
	
	# Update connections
	_update_connections()
	
	# Check if pattern is now incomplete
	_check_pattern_completion()
	
	# If the circle was activated, deactivate it
	if is_circle_activated:
		_deactivate_circle()

# Update the visual connections between nodes
func _update_connections():
	# Clear any existing connections
	for line in connection_lines.get_children():
		line.visible = false
	
	# If center is in correct nodes, draw connections to any correct cardinal nodes
	if correct_nodes.has("center"):
		# Connect center to each correct cardinal node
		for cardinal_pos in ["north", "east", "south", "west"]:
			if correct_nodes.has(cardinal_pos):
				var line_name = "ConnectionLine_" + cardinal_pos
				var line = connection_lines.get_node_or_null(line_name)
				if line:
					line.visible = true

# Check if the pattern is complete and activate the circle if it is
func _check_pattern_completion():
	# For the first circle, we consider it complete when all 5 nodes have correct runes
	var all_correct = correct_nodes.size() >= 5
	
	if all_correct and not is_circle_activated:
		_activate_circle()
	elif not all_correct and is_circle_activated:
		_deactivate_circle()

# Activate the entire circle
func _activate_circle():
	if is_circle_activated:
		return
		
	is_circle_activated = true
	valid_pattern = true
	
	print("Activating circle")
	
	# Activate all nodes
	central_node.activate()
	for node in cardinal_nodes.get_children():
		if node is RuneNode:
			node.activate()
	
	# Start particle effects
	activation_particles.emitting = true
	
	# Show success indicator
	success_indicator.visible = true
	success_indicator.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(success_indicator, "modulate:a", 0.5, 2.0)
	
	# Start resource generation
	resource_generation_active = true
	
	# Emit signal
	emit_signal("circle_activated")

# Deactivate the circle
func _deactivate_circle():
	if not is_circle_activated:
		return
		
	is_circle_activated = false
	valid_pattern = false
	
	print("Deactivating circle")
	
	# Deactivate all nodes
	central_node.deactivate()
	for node in cardinal_nodes.get_children():
		if node is RuneNode:
			node.deactivate()
	
	# Stop particle effects
	activation_particles.emitting = false
	
	# Hide success indicator
	var tween = create_tween()
	tween.tween_property(success_indicator, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): success_indicator.visible = false)
	
	# Stop resource generation
	resource_generation_active = false
	
	# Emit signal
	emit_signal("circle_deactivated")
