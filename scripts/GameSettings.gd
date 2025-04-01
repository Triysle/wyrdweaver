extends Node

# This is a singleton that can be accessed from anywhere
# Add it to the AutoLoad list in Project Settings

# Game version
const VERSION = "0.1.0"

# Visual settings
const USE_GRAYSCALE_ONLY = true

# Rune definitions
const RUNES = {
	"sowilo": {
		"symbol": "ᛋ",
		"name": "Sowilo",
		"description": "Sun rune",
		"texture_path": "res://assets/runes/sowilo.png"
	},
	"fehu": {
		"symbol": "ᚠ",
		"name": "Fehu",
		"description": "Wealth rune",
		"texture_path": "res://assets/runes/fehu.png"
	},
	"ansuz": {
		"symbol": "ᚨ",
		"name": "Ansuz",
		"description": "Communication rune",
		"texture_path": "res://assets/runes/ansuz.png"
	},
	"jera": {
		"symbol": "ᛃ",
		"name": "Jera",
		"description": "Harvest/year rune",
		"texture_path": "res://assets/runes/jera.png"
	},
	"dagaz": {
		"symbol": "ᛞ",
		"name": "Dagaz",
		"description": "Day/awakening rune",
		"texture_path": "res://assets/runes/dagaz.png"
	}
}

# Node requirements for first circle
const FIRST_CIRCLE_CONFIG = {
	"central_node": "sowilo",
	"north_node": "dagaz",
	"east_node": "ansuz",
	"south_node": "jera",
	"west_node": "fehu"
}

# Resource definitions
const RESOURCES = {
	"energy": {
		"name": "Ethereal Energy",
		"initial_amount": 0,
		"max_amount": 100,
		"texture_path": "res://assets/resources/energy.png"
	}
}

# Game flags
var flags = {
	"tutorial_completed": false,
	"first_circle_activated": false,
	"second_page_unlocked": false
}

# Set a flag
func set_flag(flag_name: String, value: bool) -> void:
	if flags.has(flag_name):
		flags[flag_name] = value

# Get a flag value
func get_flag(flag_name: String) -> bool:
	return flags.get(flag_name, false)

# Convert value to runic number
func to_runic_number(value: int) -> String:
	# This is a placeholder for a real runic number conversion
	# In a real implementation, you'd convert to Elder Futhark numerals
	# or other historically accurate representation
	
	# For now, just return as string
	return str(value)
