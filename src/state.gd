extends Node

# Inventory, stats, flags, and endings unlocked
var inventory: Array = []
var flags: Dictionary = {}
var endings_unlocked: Array = []

# Add an item to inventory (avoid duplicates)
func add_item(item: String):
	if item not in inventory:
		inventory.append(item)

# Check if player has an item
func has_item(item: String) -> bool:
	return item in inventory

# Set a flag (for stats or choices)
func set_flag(key: String, value):
	flags[key] = value

# Get a flag (returns false if unset)
func get_flag(key: String):
	return flags.get(key, false)

# Unlock an ending if not already unlocked
func unlock_ending(ending_id: String):
	if ending_id not in endings_unlocked:
		endings_unlocked.append(ending_id)

# Check if all endings from a list are unlocked (for bonus)
func all_endings_unlocked(required_endings: Array) -> bool:
	for e in required_endings:
		if e not in endings_unlocked:
			return false
	return true
