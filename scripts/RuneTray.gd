extends Node2D
class_name RuneTray

# Tray properties
@export var max_slots: int = 5
@export var slot_spacing: float = 80.0  # Distance between slots
@export var slot_padding: float = 10.0  # Extra padding on the edges

# Runtime properties
var slots = []  # Array of slot positions
var occupied_slots = {}  # Dictionary mapping slot index to rune

# Called when the node enters the scene tree for the first time
func _ready():
	# Initialize the tray slots dynamically
	_setup_slots()
	
	# Connect signals from existing runes
	_connect_rune_signals()
	
	# Position the runes in the tray initially
	_position_initial_runes()

# Set up the slot positions dynamically
func _setup_slots():
	slots.clear()
	occupied_slots.clear()
	
	# Calculate total width available
	var tray_width = $TrayBackground.texture.get_width() - (slot_padding * 2)
	
	# Calculate position of each slot
	for i in range(max_slots):
		var x_pos = (tray_width / (max_slots + 1)) * (i + 1) - (tray_width / 2)
		slots.append(Vector2(x_pos, 0))
	
	print("Initialized ", slots.size(), " tray slots dynamically")

# Connect signals from all runes in the container
func _connect_rune_signals():
	for rune in $RuneContainer.get_children():
		if rune is Rune:
			# Disconnect existing connections to avoid duplicates
			if rune.is_connected("rune_drag_ended", _on_rune_drag_ended):
				rune.rune_drag_ended.disconnect(_on_rune_drag_ended)
			
			# Connect the signals
			rune.rune_drag_ended.connect(_on_rune_drag_ended)
			
	print("Connected signals from ", $RuneContainer.get_children().size(), " runes")

# Position the initial runes in the tray
func _position_initial_runes():
	var runes = $RuneContainer.get_children()
	
	# Only position up to max_slots runes
	var rune_count = min(runes.size(), max_slots)
	
	for i in range(rune_count):
		if i < runes.size() and i < slots.size():
			var rune = runes[i]
			if rune is Rune:
				# Set rune position to slot
				rune.position = slots[i]
				rune.original_position = slots[i]
				
				# Mark slot as occupied
				occupied_slots[i] = rune
	
	print("Positioned ", rune_count, " runes in the tray")

# Get the nearest available slot to a given position
func get_nearest_available_slot(global_pos: Vector2) -> Dictionary:
	var local_pos = to_local(global_pos)
	
	# First, check for completely empty slots (first available)
	for i in range(slots.size()):
		if not occupied_slots.has(i):
			print("Found first available slot at index: ", i)
			return {
				"index": i,
				"position": slots[i]
			}
	
	# If we get here, all slots are occupied
	print("All slots are occupied, finding nearest one")
	var nearest_slot_index = -1
	var nearest_distance = INF
	
	# Find the nearest slot
	for i in range(slots.size()):
		var distance = local_pos.distance_to(slots[i])
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_slot_index = i
	
	# Return information about the nearest slot
	return {
		"index": nearest_slot_index,
		"position": slots[nearest_slot_index] if nearest_slot_index != -1 else Vector2.ZERO
	}

# Free up a slot for a specific rune
func free_slot_for_rune(rune: Rune):
	# Find the slot that contains this rune
	for slot_index in occupied_slots.keys():
		if occupied_slots[slot_index] == rune:
			# Remove from occupied slots
			occupied_slots.erase(slot_index)
			return

# Add a rune to the tray
func add_rune(rune: Rune):
	# Find an available slot
	var slot_info = get_nearest_available_slot(rune.global_position)
	
	if slot_info.index != -1:
		# Update rune's original position to the new slot
		rune.original_position = slot_info.position
		
		# Update occupied slots
		occupied_slots[slot_info.index] = rune
		
		# Create a tween for smooth movement to the slot
		var tween = create_tween()
		tween.tween_property(rune, "position", slot_info.position, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		
		return true
	
	return false

# Handle a rune being returned to the tray
func _on_rune_drag_ended(rune: Rune):
	if rune.current_state == "in_tray":
		# Rune is being returned to tray
		
		print("Rune returning to tray: ", rune.rune_type)
		
		# Free up the old slot if this rune had one
		free_slot_for_rune(rune)
		
		# Find an available slot
		var slot_info = get_nearest_available_slot(rune.global_position)
		
		print("Found slot index: ", slot_info.index, " at position: ", slot_info.position)
		
		if slot_info.index != -1:
			# Update occupied slots
			occupied_slots[slot_info.index] = rune
			
			# Create a tween for smooth movement to the slot
			var tween = create_tween()
			tween.tween_property(rune, "position", slot_info.position, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		else:
			print("ERROR: No available slots found in tray!")
