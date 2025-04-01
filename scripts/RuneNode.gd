extends Area2D
class_name RuneNode

# Signals
signal rune_placed(node, rune_type)
signal rune_activated()

# Enums
enum NodeState {EMPTY, FILLED, ACTIVATED}

# Node properties
@export var required_rune_type: String = ""
@export var node_name: String = ""
@export var connection_points: Array[NodePath] = []

# Current state of the node
var current_state: int = NodeState.EMPTY
var current_rune = null

# Visual elements
@onready var highlight_sprite: Sprite2D = $Highlight
@onready var glow_effect: Sprite2D = $GlowEffect
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Called when the node enters the scene tree for the first time
func _ready():
	# Initialize visuals
	if highlight_sprite:
		highlight_sprite.visible = false
	if glow_effect:
		glow_effect.visible = false
	
	# Connect signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

# Validate if the rune can be placed on this node
func validate_rune(rune_type: String) -> bool:
	return rune_type == required_rune_type or required_rune_type == ""

# Place a rune on this node
func place_rune(rune) -> bool:
	if current_state != NodeState.EMPTY:
		return false
		
	if validate_rune(rune.rune_type):
		current_rune = rune
		current_state = NodeState.FILLED
		emit_signal("rune_placed", self, rune.rune_type)
		
		# Visual feedback
		if glow_effect:
			glow_effect.visible = true
			var tween = create_tween()
			tween.tween_property(glow_effect, "modulate:a", 1.0, 0.3)
			tween.tween_property(glow_effect, "modulate:a", 0.5, 0.3)
			tween.set_loops(2)
		
		return true
	else:
		return false

# Activate the node after all requirements are met
func activate() -> void:
	if current_state == NodeState.FILLED:
		current_state = NodeState.ACTIVATED
		
		# Visual feedback for activation
		if current_rune:
			current_rune.activate()
		
		if glow_effect:
			glow_effect.visible = true
			var tween = create_tween()
			tween.tween_property(glow_effect, "modulate:a", 1.0, 0.5)
			
		emit_signal("rune_activated")

# Connect to another node (visually and logically)
func connect_to(other_node: RuneNode) -> void:
	# This would be implemented to create visual connections
	# between nodes when they're both activated
	pass

# Reset the node to empty state
func reset() -> void:
	current_state = NodeState.EMPTY
	current_rune = null
	
	# Reset visuals
	if glow_effect:
		glow_effect.visible = false
	
	if highlight_sprite:
		highlight_sprite.visible = false

# Highlight the node (for tutorial purposes)
func highlight(should_highlight: bool = true) -> void:
	if highlight_sprite:
		highlight_sprite.visible = should_highlight
		
		if should_highlight:
			var tween = create_tween()
			tween.tween_property(highlight_sprite, "modulate:a", 0.8, 0.5)
			tween.tween_property(highlight_sprite, "modulate:a", 0.2, 0.5)
			tween.set_loops(-1)

# Signal handlers
func _on_mouse_entered() -> void:
	if current_state == NodeState.EMPTY:
		# Slight visual feedback on hover
		if highlight_sprite:
			highlight_sprite.visible = true
			highlight_sprite.modulate.a = 0.3

func _on_mouse_exited() -> void:
	if current_state == NodeState.EMPTY:
		# Remove hover feedback
		if highlight_sprite:
			highlight_sprite.visible = false
