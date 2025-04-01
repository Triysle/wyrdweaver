extends Node2D
class_name ResourceContainer

# Resource container properties
@export var max_resource: float = 100.0
@export var display_format: String = "runes"  # runes, tally, visual

# Visual properties
@export var min_scale: float = 0.0
@export var max_scale: float = 1.0

# Current amount of resource
var current_resource: float = 0.0

# References
@onready var fill_sprite = $ResourceFill
@onready var counter = $ResourceCounter
@onready var particles = $ResourceParticles

func _ready():
	# Set up initial state
	update_visuals()
	
	# Particles should be off initially
	if particles:
		particles.emitting = false
	else:
		print("ERROR: ResourceParticles not found in ResourceContainer!")

# Add resource to the container
func add_resource(amount: float):
	current_resource = min(current_resource + amount, max_resource)
	update_visuals()
	print("Resource added: ", amount, " Current: ", current_resource)

# Update all visual elements to match current resource amount
func update_visuals():
	var fill_percentage = current_resource / max_resource
	
	# Update fill sprite
	if fill_sprite:
		# Ensure the scale is never zero (which would make it invisible)
		var new_scale = lerp(min_scale, max_scale, fill_percentage)
		if new_scale <= 0.01:  # Minimum visible scale
			new_scale = 0.01
			
		fill_sprite.scale = Vector2(new_scale, new_scale)
		
		# Also adjust alpha for extra visual feedback
		fill_sprite.modulate.a = lerp(0.3, 0.8, fill_percentage)
	else:
		print("ERROR: ResourceFill sprite not found in ResourceContainer!")
	
	# Update counter text
	if counter:
		var display_value = _format_resource_value(current_resource)
		counter.text = display_value
	else:
		print("ERROR: ResourceCounter not found in ResourceContainer!")

# Format the resource value based on the display format
func _format_resource_value(value: float) -> String:
	# Round to nearest integer for display
	var int_value = int(value)
	
	match display_format:
		"runes":
			# Simple runic representation (using Elder Futhark where possible)
			if int_value <= 0:
				return ""
			elif int_value <= 9:
				# Single runic digits
				var runes = ["", "ᚠ", "ᚢ", "ᚦ", "ᚨ", "ᚱ", "ᚲ", "ᚷ", "ᚹ", "ᚺ"]
				return runes[int_value]
			else:
				# Just return the number for now, could be expanded with proper runic numerals
				return str(int_value)
				
		"tally":
			# Tally mark style (simplified)
			var output = ""
			var remaining = int_value
			
			# Add groups of 5
			while remaining >= 5:
				output += "ᛉ "  # Using Algiz rune for a 5-group
				remaining -= 5
			
			# Add remaining singles
			for i in range(remaining):
				output += "ᛁ "  # Using Isa rune for single marks
				
			return output
			
		"visual":
			# In a real implementation, this would just return an empty string
			# and the visual would be handled entirely by the fill level
			return ""
			
		_:
			# Default case
			return str(int_value)

# Start particle effects (when resources are being generated)
func start_particles():
	if particles:
		particles.emitting = true
		print("Resource particles started!")
	else:
		print("ERROR: Cannot start particles - ResourceParticles not found!")
		
# Stop particle effects
func stop_particles():
	if particles:
		particles.emitting = false
	else:
		print("ERROR: Cannot stop particles - ResourceParticles not found!")
