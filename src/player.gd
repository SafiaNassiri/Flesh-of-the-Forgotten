extends Node

var inventory = []
var morality = 0
var decay = 0

func add_item(item):
	if item not in inventory:
		inventory.append(item)

func has_item(item) -> bool:
	return item in inventory
