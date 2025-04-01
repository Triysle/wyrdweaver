extends Area2D
class_name Rune

# Signals
signal drag_started(rune)
signal drag_ended(rune)
signal activated(rune)

# Enums
enum RuneState {IN_TRAY, DRAGGING, PLACED, ACTIVATED}

# Rune properties
@export var rune_type: String = ""
@export var rune_name: String = ""
@export var rune_description: String = ""

# Current state of the rune
var current_state: int = RuneState.IN_TRAY
var original_position: Vector2
var current_node = null
var dragging: bool = false

# Visual elements
@onready var sprite: Sprite2D = $Sprite2D
@onready var glow_effect: Sprite2D = $GlowEffect
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Called when the node enters the scene tree for the first time
func _ready():
	# Initialize visuals
	if glow_effect:
		glow_effect.visible = false
	
	# Set original position
	original_position = position
	
	# Connect signals
	input_event.connect(_on_input_event)

# Called every frame to handle dragging
func _process(delta):
	if dragging:
		position = get_global_mouse_position()

# Start dragging the rune
func drag_start() -> void:
	if current_state == RuneState.IN_TRAY:
		dragging = true
		current_state = RuneState.DRAGGING
		z_index = 10  # Ensure dragged rune is above others
		emit_signal("drag_started", self)
		
		# Visual feedback
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)

# End dragging and check for placement
func drag_end() -> void:
	if current_state == RuneState.DRAGGING:
		dragging = false
		z_index = 0  # Reset z-index
		
		# Reset scale
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
		
		emit_signal("drag_ended", self)
		
		# Check if over a valid node
		var can_place = false
		var overlapping_areas = get_overlapping_areas()
		
		for area in overlapping_areas:
			if area is RuneNode:
				if area.place_rune(self):
					can_place = true
					current_node = area
					current_state = RuneState.PLACED
					# Move to the center of the node
					position = area.global_position
					break
		
		# If not placed on a valid node, return to tray
		if not can_place:
			return_to_tray()

# Return the rune to its original position in the tray
func return_to_tray() -> void:
	current_state = RuneState.IN_TRAY
	current_node = null
	
	# Animate return to tray
	var tween = create_tween()
	tween.tween_property(self, "position", original_position, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

# Activate the rune after all requirements are met
func activate() -> void:
	if current_state == RuneState.PLACED:
		current_state = RuneState.ACTIVATED
		
		# Visual feedback for activation
		if glow_effect:
			glow_effect.visible = true
			var tween = create_tween()
			tween.tween_property(glow_effect, "modulate:a", 1.0, 0.5)
		
		emit_signal("activated", self)

# Signal handlers
func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start drag on mouse down
				if current_state == RuneState.IN_TRAY:
					drag_start()
			else:
				# End drag on mouse up
				if current_state == RuneState.DRAGGING:
					drag_end()
