extends Node2D
class_name FirstPageManager

# References to other nodes
@onready var runic_circle: CircleManager = $RunicCircle
@onready var rune_tray: RuneTray = $RuneTray
@onready var resource_container: ResourceManager = $ResourceContainer
@onready var tutorial_elements: Node2D = $TutorialElements

# Called when the node enters the scene tree for the first time
func _ready():
	# Connect signals
	if runic_circle:
		runic_circle.circle_activated.connect(_on_circle_activated)
		runic_circle.circle_deactivated.connect(_on_circle_deactivated)
		
	if resource_container:
		resource_container.resource_increased.connect(_on_resource_increased)

# Handle initial setup and state
func setup_page() -> void:
	# Any initial page setup can go here
	pass

# Signal handlers
func _on_circle_activated() -> void:
	print("Circle activated! Resources now generating.")
	
	# Maybe play a sound or animation here
	
	# Could trigger a tutorial step here
	show_tutorial_message("circle_activated")

func _on_circle_deactivated() -> void:
	print("Circle deactivated. Resource generation stopped.")
	
	# Maybe play a sound or animation here
	
func _on_resource_increased(amount, total) -> void:
	print("Resource increased by: %s. New total: %s" % [amount, total])
	
	# Could trigger progression events based on resource milestones
	check_resource_milestones(total)

# Check if any resource milestones have been reached
func check_resource_milestones(total: int) -> void:
	# Example milestone checks
	if total >= 10 and not has_reached_milestone("first_milestone"):
		unlock_milestone("first_milestone")
		# Maybe unlock a new page or feature
		
	if total >= 50 and not has_reached_milestone("second_milestone"):
		unlock_milestone("second_milestone")
		# Maybe introduce a new game mechanic

# Milestone tracking
var milestones = {
	"first_milestone": false,
	"second_milestone": false
}

func has_reached_milestone(milestone_name: String) -> bool:
	return milestones.has(milestone_name) and milestones[milestone_name]

func unlock_milestone(milestone_name: String) -> void:
	if milestones.has(milestone_name):
		milestones[milestone_name] = true
		print("Milestone unlocked: %s" % milestone_name)
		
		# Could trigger special effects or tutorials
		show_tutorial_message(milestone_name)

# Tutorial system
func show_tutorial_message(message_id: String) -> void:
	# This would show visual tutorial elements based on the message_id
	# For now, just a placeholder
	var tutorial_message = tutorial_elements.get_node_or_null(message_id)
	if tutorial_message:
		tutorial_message.visible = true
		
		# Hide after a delay
		var timer = get_tree().create_timer(5.0)
		await timer.timeout
		tutorial_message.visible = false
