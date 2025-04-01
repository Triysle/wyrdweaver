extends Node2D
class_name RunicCircle

# Circle properties
@export var resource_generation_rate: float = 1.0

# Node references
@onready var central_node = $CentralNode
@onready var cardinal_nodes = $CardinalNodes
@onready var connection_lines = $ConnectionLines
@onready var activation_particles = $ActivationParticles

# State tracking
var activated_nodes = []
var is_circle_activated = false
var connection_lines_visible = []  # Array to track which connection lines are visible

# Signals
signal circle_activated
signal resource_generated(amount)

func _ready():
	# Set up node connections
	_connect_node_signals()
	
	# Initialize connection lines as invisible
	for line in connection_lines.get_children():
		line.visible = false

# Connect signals from all rune nodes
func _connect_node_signals():
	# Connect central node
	central_node.rune_placed_correctly.connect(_on_rune_placed_correctly)
	
	# Connect cardinal nodes
	for node in cardinal_nodes.get_children():
		if node is RuneNode:
			node.rune_placed_correctly.connect(_on_rune_placed_correctly)

# Process resource generation when circle is active
func _process(delta):
	if is_circle_activated:
		var amount = resource_generation_rate * delta
		emit_signal("resource_generated", amount)

# Handle a rune being placed correctly
func _on_rune_placed_correctly(node_position):
	# Add to activated nodes list if not already there
	if not activated_nodes.has(node_position):
		activated_nodes.append(node_position)
	
	# Update connections
	_update_connections()
	
	# Check if pattern is complete
	_check_pattern_completion()

# Update the visual connections between nodes
func _update_connections():
	# Clear any existing connections
	for line in connection_lines.get_children():
		line.visible = false
	
	# If center is activated, draw connections to any activated cardinal nodes
	if activated_nodes.has("center"):
		# Connect center to each activated cardinal node
		for cardinal_pos in ["north", "east", "south", "west"]:
			if activated_nodes.has(cardinal_pos):
				var line_name = "ConnectionLine_" + cardinal_pos
				var line = connection_lines.get_node_or_null(line_name)
				if line:
					line.visible = true
					connection_lines_visible.append(cardinal_pos)

# Check if the pattern is complete and activate the circle if it is
func _check_pattern_completion():
	# For the first circle, we consider it complete when all 5 nodes are filled
	if activated_nodes.size() >= 5:
		_activate_circle()

# Activate the entire circle
func _activate_circle():
	if is_circle_activated:
		return
		
	is_circle_activated = true
	
	# Activate all nodes
	central_node.activate()
	for node in cardinal_nodes.get_children():
		if node is RuneNode:
			node.activate()
	
	# Start particle effects
	activation_particles.emitting = true
	
	# Show success indicator
	$SuccessIndicator.visible = true
	var tween = create_tween()
	tween.tween_property($SuccessIndicator, "modulate:a", 0.0, 2.0)
	
	# Start processing resource generation
	set_process(true)
	
	# Emit the circle activated signal
	emit_signal("circle_activated")
