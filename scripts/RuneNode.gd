extends Area2D
class_name RuneNode

# Rune node properties
@export var required_rune_type: String = ""
@export var node_position: String = "center" # center, north, east, south, west

# Current state
var current_state: String = "empty" # empty, filled
var is_activated: bool = false # Track activation separately
var current_rune = null

# Reference to the rune that's currently placed on this node
var placed_rune = null

# Signals
signal rune_placed_correctly(node_position)
signal rune_placed_incorrectly(node_position)
signal rune_removed(node_position)

func _ready():
	# Set up initial appearance
	$NodePlaceholder.visible = true
	$NodeHighlight.visible = false
	
	# Set up the collision shape
	$CollisionShape2D.shape = CircleShape2D.new()
	$CollisionShape2D.shape.radius = 30
	
	print("RuneNode ready: ", node_position, " requires: ", required_rune_type)

# Check if a rune can be placed on this node (always true now)
func can_accept_rune(_rune_type: String) -> bool:
	# Only check if the node is empty, not if the rune type matches
	var can_accept = current_state == "empty"
	print("Node ", node_position, " can accept any rune: ", can_accept)
	return can_accept

# Place a rune on this node
func place_rune(rune):
	if current_state != "empty":
		print("Cannot place rune - node is not empty: ", current_state)
		return false
		
	# Set reference to the placed rune
	placed_rune = rune
	current_rune = rune.rune_type
	
	print("Rune ", current_rune, " placed on node ", node_position)
	
	# Update state
	current_state = "filled"
	
	# Visually indicate the rune is placed
	$NodePlaceholder.visible = false
	
	# Check if it's the correct rune type
	if current_rune == required_rune_type:
		# Show the node highlight for correct placement
		$NodeHighlight.visible = true
		
		# Emit signal about successful placement
		print("Emitting rune_placed_correctly signal for ", node_position)
		emit_signal("rune_placed_correctly", node_position)
	else:
		# It's an incorrect rune type
		print("Emitting rune_placed_incorrectly signal for ", node_position)
		emit_signal("rune_placed_incorrectly", node_position)
	
	return true

# Remove rune from this node
func remove_rune():
	if current_state == "empty":
		print("Cannot remove rune - node is already empty")
		return
		
	print("Removing rune from node ", node_position)
	
	# Check if this was a correct rune that's being removed
	var was_correct = (current_rune == required_rune_type)
	
	# Reset state
	current_state = "empty"
	current_rune = null
	placed_rune = null
	is_activated = false
	
	# Restore visual state
	$NodePlaceholder.visible = true
	$NodeHighlight.visible = false
	
	# Emit signal about rune removal
	print("Emitting rune_removed signal for ", node_position)
	emit_signal("rune_removed", node_position)

# Activate this node (when the circle pattern is correct)
func activate():
	if current_state != "filled":
		print("Cannot activate node - not filled")
		return
		
	if is_activated:
		print("Node already activated")
		return
		
	print("Activating node: ", node_position)
	is_activated = true
	
	# Tell the placed rune to activate as well
	if placed_rune:
		print("Telling rune to activate")
		placed_rune.activate()
	else:
		print("ERROR: No placed_rune reference on node ", node_position)

# Deactivate this node (when the circle pattern breaks)
func deactivate():
	if not is_activated:
		print("Node not activated, nothing to deactivate")
		return
		
	print("Deactivating node: ", node_position)
	is_activated = false
	
	# Tell the placed rune to deactivate as well
	if placed_rune:
		print("Telling rune to deactivate")
		placed_rune.deactivate()
