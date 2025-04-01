extends Area2D
class_name RuneNode

# Rune node properties
@export var required_rune_type: String = ""
@export var node_position: String = "center" # center, north, east, south, west

# Current state
var current_state: String = "empty" # empty, filled, activated
var current_rune = null

# Reference to the rune that's currently placed on this node
var placed_rune = null

# Signals
signal rune_placed_correctly(node_position)
# We'll use this signal later when implementing incorrect placement feedback
# signal rune_placed_incorrectly(node_position)

func _ready():
	# Set up initial appearance
	$NodePlaceholder.visible = true
	$NodeHighlight.visible = false
	
	# Set up the collision shape
	$CollisionShape2D.shape = CircleShape2D.new()
	$CollisionShape2D.shape.radius = 30

# Check if a rune can be placed on this node
func can_accept_rune(rune_type: String) -> bool:
	return current_state == "empty" and rune_type == required_rune_type

# Place a rune on this node
func place_rune(rune):
	if current_state != "empty":
		return false
		
	# Set reference to the placed rune
	placed_rune = rune
	current_rune = rune.rune_type
	
	# Update state
	current_state = "filled"
	
	# Visually indicate the rune is placed
	$NodePlaceholder.visible = false
	
	# Emit signal about successful placement
	emit_signal("rune_placed_correctly", node_position)
	return true

# Remove rune from this node
func remove_rune():
	if current_state == "empty":
		return
		
	# Reset state
	current_state = "empty"
	current_rune = null
	placed_rune = null
	
	# Restore visual state
	$NodePlaceholder.visible = true
	$NodeHighlight.visible = false

# Activate this node (when the circle pattern is correct)
func activate():
	if current_state != "filled":
		return
		
	current_state = "activated"
	
	# Tell the placed rune to activate as well
	if placed_rune:
		placed_rune.activate()
