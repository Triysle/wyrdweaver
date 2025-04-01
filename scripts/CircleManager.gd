extends Node2D
class_name CircleManager

# Signals
signal circle_activated
signal circle_deactivated

# References to other nodes
@export var resource_manager_path: NodePath
@onready var resource_manager: ResourceManager = get_node(resource_manager_path) if resource_manager_path else null

# Node references
@onready var central_node: RuneNode = $CentralNode
@onready var north_node: RuneNode = $CardinalNodes/NorthNode
@onready var east_node: RuneNode = $CardinalNodes/EastNode
@onready var south_node: RuneNode = $CardinalNodes/SouthNode
@onready var west_node: RuneNode = $CardinalNodes/WestNode
@onready var connection_lines: Node2D = $ConnectionLines
@onready var activation_particles: GPUParticles2D = $ActivationParticles

# Track nodes and activation status
var all_nodes = []
var activated_nodes = []
var circle_active = false

# Called when the node enters the scene tree for the first time
func _ready():
	# Initialize nodes array
	all_nodes = [central_node, north_node, east_node, south_node, west_node]
	
	# Connect signal for each node
	for node in all_nodes:
		if node:
			node.rune_placed.connect(_on_rune_placed)
			node.rune_activated.connect(_on_rune_activated)
	
	# Initialize connection lines to be invisible
	for line in connection_lines.get_children():
		if line is Line2D:
			line.visible = false
	
	# Disable particles initially
	if activation_particles:
		activation_particles.emitting = false
	
	# Start the tutorial sequence
	start_tutorial()

# Start the tutorial sequence
func start_tutorial() -> void:
	# Highlight the central node first
	if central_node:
		central_node.highlight(true)

# Check if circle can be fully activated
func check_circle_completion() -> void:
	# Check if all nodes are activated
	var all_activated = true
	for node in all_nodes:
		if node and node.current_state != RuneNode.NodeState.ACTIVATED:
			all_activated = false
			break
	
	# If all nodes are activated, activate the circle
	if all_activated and not circle_active:
		activate_circle()

# Activate the circle
func activate_circle() -> void:
	circle_active = true
	
	# Visual effects
	if activation_particles:
		activation_particles.emitting = true
	
	# Start resource generation
	if resource_manager:
		resource_manager.start_generation()
	
	# Show all connection lines
	for line in connection_lines.get_children():
		if line is Line2D:
			line.visible = true
			animate_line(line)
	
	emit_signal("circle_activated")

# Deactivate the circle
func deactivate_circle() -> void:
	circle_active = false
	
	# Visual effects
	if activation_particles:
		activation_particles.emitting = false
	
	# Stop resource generation
	if resource_manager:
		resource_manager.stop_generation()
	
	# Hide all connection lines
	for line in connection_lines.get_children():
		if line is Line2D:
			line.visible = false
	
	emit_signal("circle_deactivated")

# Animate a connection line
func animate_line(line: Line2D) -> void:
	# Make sure line is visible
	line.visible = true
	
	# Animate it (for example, pulse effect)
	var tween = create_tween()
	tween.tween_property(line, "modulate:a", 1.0, 0.5)
	tween.tween_property(line, "modulate:a", 0.5, 0.5)
	tween.set_loops(-1)

# Create a visual connection between nodes
func create_connection(from_node: RuneNode, to_node: RuneNode) -> void:
	# Find or create a line between the nodes
	var line_name = from_node.name + "To" + to_node.name
	var line = connection_lines.get_node_or_null(line_name)
	
	if not line:
		# Create a new line
		line = Line2D.new()
		line.name = line_name
		line.width = 5
		line.default_color = Color(0.8, 0.8, 0.8, 0.8)  # Grayscale color
		connection_lines.add_child(line)
	
	# Set line points
	line.clear_points()
	line.add_point(from_node.global_position - connection_lines.global_position)
	line.add_point(to_node.global_position - connection_lines.global_position)
	
	# Make visible and animate
	line.visible = true
	animate_line(line)

# Signal handlers
func _on_rune_placed(node, rune_type) -> void:
	# When a rune is placed, check if it's the central node
	if node == central_node:
		# Activate central node immediately
		central_node.activate()
		
		# Now highlight cardinal nodes
		north_node.highlight(true)
		east_node.highlight(true)
		south_node.highlight(true)
		west_node.highlight(true)
		
		# Stop highlighting central node
		central_node.highlight(false)
	else:
		# Cardinal nodes need to be connected to central node first
		create_connection(node, central_node)
		
		# Check if the circle can be fully activated
		if central_node.current_state == RuneNode.NodeState.ACTIVATED:
			# Activate this node
			node.activate()
			
			# Stop highlighting this node
			node.highlight(false)

func _on_rune_activated(node) -> void:
	activated_nodes.append(node)
	
	# If all cardinal nodes are activated, activate the circle
	if activated_nodes.size() == all_nodes.size():
		activate_circle()
