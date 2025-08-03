extends Node

var inventory: Array = []
var flags: Dictionary = {}
var current_location: String = "awakening"
var endings_unlocked: Array = []

func add_item(item: String):
	if item not in inventory:
		inventory.append(item)

func has_item(item: String) -> bool:
	return item in inventory

func set_flag(key: String, value):
	flags[key] = value

func get_flag(key: String):
	return flags.get(key, false)

func unlock_ending(ending_id: String):
	if ending_id not in endings_unlocked:
		endings_unlocked.append(ending_id)
