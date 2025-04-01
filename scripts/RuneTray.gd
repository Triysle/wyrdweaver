extends Node2D
class_name RuneTray

# Rune scene to instance
@export var rune_scene: PackedScene
@export var spacing: float = 80.0  # Space between runes

# Runes data for the first circle
var initial_runes = [
	{
		"type": "sowilo",
		"name": "Sowilo",
		"description": "Sun rune"
	},
	{
		"type": "fehu",
		"name": "Fehu",
		"description": "Wealth rune"
	},
	{
		"type": "ansuz",
		"name": "Ansuz",
		"description": "Communication rune"
	},
	{
		"type": "jera",
		"name": "Jera",
		"description": "Harvest rune"
	},
	{
		"type": "dagaz",
		"name": "Dagaz",
		"description": "Day/Awakening rune"
	}
]

# Reference to spawned runes
var runes = []

# Called when the node enters the scene tree for the first time
func _ready():
	# Spawn initial runes
	spawn_initial_runes()

# Spawn the initial set of runes
func spawn_initial_runes() -> void:
	if not rune_scene:
		push_error("RuneTray: No rune scene assigned!")
		return
	
	var start_x = -(spacing * (initial_runes.size() - 1)) / 2
	
	for i in range(initial_runes.size()):
		var rune_data = initial_runes[i]
		var rune_instance = rune_scene.instantiate()
		
		# Set properties
		rune_instance.rune_type = rune_data["type"]
		rune_instance.rune_name = rune_data["name"]
		rune_instance.rune_description = rune_data["description"]
		
		# Position in tray
		rune_instance.position = Vector2(start_x + (i * spacing), 0)
		
		# Track the rune
		runes.append(rune_instance)
		
		# Add to scene
		add_child(rune_instance)
		
		# Connect signals
		rune_instance.drag_started.connect(_on_rune_drag_started)
		rune_instance.drag_ended.connect(_on_rune_drag_ended)

# Signal handlers
func _on_rune_drag_started(rune) -> void:
	# Bring the dragged rune to front
	move_child(rune, get_child_count() - 1)

func _on_rune_drag_ended(rune) -> void:
	# Any additional logic needed when a rune is placed/returned
	pass
