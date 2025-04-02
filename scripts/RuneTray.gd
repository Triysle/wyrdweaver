extends Node2D
class_name RuneTray

# Tray properties
@export var slot_spacing: float = 80.0  # Distance between slots (default)

# Runtime properties
var slots = []  # Array of slot positions
var occupied_slots = {}  # Dictionary mapping slot index to rune

# Called when the node enters the scene tree for the first time
func _ready():
	# Initialize the tray slots using existing RuneContainer
	_setup_slots_from_container()
	
	# Connect signals from existing runes
	for rune in $RuneContainer.get_children():
		if rune is Rune:
			# Set original position based on current position
			rune.original_position = rune.position
			# Connect the signals
			rune.rune_drag_ended.connect(_on_rune_drag_ended)

# Set up the slot positions based on existing runes in the RuneContainer
func _setup_slots_from_container():
	slots.clear()
	
	# Use existing rune positions as slots
	for rune in $RuneContainer.get_children():
		if rune is Rune:
			slots.append(rune.position)
			
			# Mark slot as occupied initially
			var slot_index = slots.size() - 1
			occupied_slots[slot_index] = rune
	
	print("Initialized ", slots.size(), " tray slots based on existing runes")

# Get the nearest available slot to a given position
func get_nearest_available_slot(global_pos: Vector2) -> Vector2:
	var local_pos = to_local(global_pos)
	var nearest_slot_index = -1
	var nearest_distance = INF
	
	# Find the nearest unoccupied slot
	for i in range(slots.size()):
		if not occupied_slots.has(i):
			var distance = local_pos.distance_to(slots[i])
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_slot_index = i
	
	# If all slots are occupied, find the nearest slot regardless
	if nearest_slot_index == -1:
		for i in range(slots.size()):
			var distance = local_pos.distance_to(slots[i])
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_slot_index = i
	
	# Mark this slot as occupied
	occupied_slots[nearest_slot_index] = true
	
	return slots[nearest_slot_index]

# Free up a slot for a specific rune
func free_slot_for_rune(rune: Rune):
	# Find the slot that contains this rune
	for slot_index in occupied_slots.keys():
		if occupied_slots[slot_index] == rune:
			# Remove from occupied slots
			occupied_slots.erase(slot_index)
			return

# Handle a rune being returned to the tray
func _on_rune_drag_ended(rune: Rune):
	if rune.current_state == "in_tray":
		# Rune is being returned to tray
		
		# Free up the old slot if this rune had one
		free_slot_for_rune(rune)
		
		# Find nearest available slot
		var new_slot_position = get_nearest_available_slot(rune.global_position)
		
		# Update rune's original position to the new slot
		rune.original_position = new_slot_position
		
		# Create a tween for smooth movement to the slot
		var tween = create_tween()
		tween.tween_property(rune, "position", new_slot_position, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		
		# Update occupied slots
		for slot_index in range(slots.size()):
			if slots[slot_index] == new_slot_position:
				occupied_slots[slot_index] = rune
				break
