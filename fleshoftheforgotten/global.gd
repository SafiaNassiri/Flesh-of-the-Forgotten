extends Node

var state
var map
var endings

func _ready():
	state = preload("res://src/state.gd").new()
	map = preload("res://src/map.gd").new()
	endings = preload("res://src/endings.gd").new()
	endings.load_endings()
