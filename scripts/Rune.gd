extends Area2D
class_name Rune

# Rune properties
@export var rune_type: String = ""  # sowilo, fehu, ansuz, jera, dagaz

# Current state
var current_state: String = "in_tray"  # in_tray, being_dragged, placed, activated
var original_position: Vector2 = Vector2.ZERO
var is_being_dragged: bool = false
var current_node = null  # Reference to the node where this rune is placed

# Signals
signal rune_drag_started(rune)
signal rune_drag_ended(rune)

func _ready():
	# Store the original position for returning to tray if needed
	original_position = position
	
	# Set up initial appearance
	$RuneGlow.visible = false
	
	# Set up the collision shape
	$CollisionShape2D.shape = CircleShape2D.new()
	$CollisionShape2D.shape.radius = 30
	
	# Ensure process is initially disabled until dragging
	set_process(false)
	
	print("Rune initialized: ", rune_type)

func _input_event(_viewport, event, _shape_idx):
	if current_state == "activated":
		return
		
	# Mouse button pressed - start dragging
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			print("Mouse down on rune: ", rune_type)
			start_drag()
		else:
			print("Mouse up on rune: ", rune_type)
			end_drag()

# Called every frame while being dragged
func _process(_delta):
	if is_being_dragged:
		# Update position to follow mouse
		global_position = get_global_mouse_position()

# Start dragging this rune
func start_drag():
	if current_state == "placed" or current_state == "activated":
		print("Cannot drag rune in state: ", current_state)
		return
		
	is_being_dragged = true
	current_state = "being_dragged"
	
	print("Started dragging rune: ", rune_type)
	
	# Bring to front visually
	z_index = 10
	
	# Signal that dragging has started
	emit_signal("rune_drag_started", self)
	
	# Enable processing for movement
	set_process(true)

# End dragging this rune
func end_drag():
	if not is_being_dragged:
		return
		
	is_being_dragged = false
	
	# Check for overlapping nodes to place rune
	var overlapping_areas = get_overlapping_areas()
	var valid_placement = false
	
	print("Checking ", overlapping_areas.size(), " overlapping areas for placement")
	
	for area in overlapping_areas:
		if area is RuneNode:
			var node = area
			print("Found RuneNode: ", node.node_position, " requires: ", node.required_rune_type)
			if node.can_accept_rune(rune_type):
				print("Placing rune ", rune_type, " on node ", node.node_position)
				# Place on node
				place_on_node(node)
				valid_placement = true
				break
	
	# If no valid placement, return to tray
	if not valid_placement:
		print("No valid placement found, returning to tray")
		return_to_tray()
	
	# Signal that dragging has ended
	emit_signal("rune_drag_ended", self)
	
	# Disable processing for movement
	set_process(false)

# Place this rune on a specific node
func place_on_node(node):
	# Update the rune's position to center on the node
	global_position = node.global_position
	
	# Update state
	current_state = "placed"
	current_node = node
	
	print("Placing rune on node: ", node.node_position)
	
	# Inform the node that this rune is being placed on it
	if node.place_rune(self):
		# Successfully placed
		print("Rune placed successfully")
		z_index = 5  # Above node but below other dragged runes
	else:
		# Node rejected placement
		print("Node rejected placement")
		return_to_tray()

# Return this rune to its original position in the tray
func return_to_tray():
	# Create a tween for smooth return animation
	var tween = create_tween()
	tween.tween_property(self, "position", original_position, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	# Reset state
	current_state = "in_tray"
	current_node = null
	z_index = 0
	
	print("Rune returned to tray")

# Activate the rune (when part of a completed pattern)
func activate():
	if current_state != "placed":
		print("Cannot activate rune in state: ", current_state)
		return
		
	current_state = "activated"
	
	print("Rune activated: ", rune_type)
	
	# Show the glow effect
	$RuneGlow.visible = true
	
	# Create a gentle pulsing effect
	var tween = create_tween().set_loops()
	tween.tween_property($RuneGlow, "modulate:a", 0.3, 1.5)
	tween.tween_property($RuneGlow, "modulate:a", 0.8, 1.5)
	
	# Disable further interaction
	set_process(false)
