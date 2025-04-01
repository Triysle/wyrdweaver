extends Node2D
class_name ResourceContainer

# Resource container properties
@export var max_resource: float = 100.0

# Current amount of resource
var current_resource: float = 0.0

# References
@onready var progress_bar = $ProgressBar

func _ready():
	# Set initial resource to 0
	current_resource = 0.0
	
	# Initialize progress bar
	if progress_bar:
		progress_bar.min_value = 0
		progress_bar.max_value = max_resource
		progress_bar.value = current_resource

# Add resource to the container
func add_resource(amount: float):
	current_resource = min(current_resource + amount, max_resource)
	update_visuals()

# Update all visual elements to match current resource amount
func update_visuals():
	# Update progress bar
	if progress_bar:
		progress_bar.value = current_resource

# Start particle effects (kept for compatibility)
func start_particles():
	# Empty implementation - no color change
	pass
