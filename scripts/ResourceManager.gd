extends Node2D
class_name ResourceManager

# Signals
signal resource_increased(amount, total)
signal resource_container_updated(fill_percentage)

# Resource properties
@export var resource_name: String = "energy"
@export var initial_amount: int = 0
@export var max_amount: int = 100
@export var generation_rate: float = 1.0  # Resource units per second

# Visual elements
@onready var container_sprite: Sprite2D = $ContainerSprite
@onready var fill_sprite: Sprite2D = $FillSprite
@onready var particles: GPUParticles2D = $ResourceParticles
@onready var counter: Node2D = $ResourceCounter

# Resource tracking
var current_amount: int = 0
var is_generating: bool = false
var generation_timer: float = 0.0

# Called when the node enters the scene tree for the first time
func _ready():
	# Initialize resource
	current_amount = initial_amount
	
	# Initialize visuals
	update_container_visual()
	
	# Start with particles disabled
	if particles:
		particles.emitting = false

# Called every frame to handle resource generation
func _process(delta):
	if is_generating:
		generation_timer += delta
		
		# Generate resource every second
		if generation_timer >= 1.0:
			generation_timer = 0.0
			generate_resource(generation_rate)

# Start generating resources
func start_generation() -> void:
	is_generating = true
	
	# Visual feedback
	if particles:
		particles.emitting = true

# Stop generating resources
func stop_generation() -> void:
	is_generating = false
	
	# Visual feedback
	if particles:
		particles.emitting = false

# Generate a specific amount of resource
func generate_resource(amount: float) -> void:
	var actual_amount = min(current_amount + amount, max_amount) - current_amount
	current_amount += actual_amount
	
	# Update visuals
	update_container_visual()
	
	# Emit signal
	emit_signal("resource_increased", actual_amount, current_amount)

# Update the visual representation of the container
func update_container_visual() -> void:
	var fill_percentage = float(current_amount) / max_amount
	
	# Update fill sprite
	if fill_sprite:
		# Adjust the size or scale of the fill sprite to match the percentage
		# This depends on how your fill visual is set up
		# For example, if using a vertical fill:
		fill_sprite.scale.y = fill_percentage
		
		# Or if using a shader material:
		# fill_sprite.material.set_shader_parameter("fill_amount", fill_percentage)
	
	# Update counter
	if counter:
		update_counter_visual(current_amount)
	
	# Emit signal for other systems
	emit_signal("resource_container_updated", fill_percentage)

# Update the runic counter visual
func update_counter_visual(value: int) -> void:
	# This would implement a runic number system
	# For now, we'll just update a label if it exists
	var label = counter.get_node_or_null("Label")
	if label:
		label.text = format_as_runic_number(value)

# Format a number as a runic representation
# This is a placeholder - you'll need to implement actual runic numbering
func format_as_runic_number(value: int) -> String:
	# Simple placeholder - replace with actual runic numbering system
	# For example, might use Elder Futhark runes or runic tally marks
	return str(value)  # For now, just return the number as text
