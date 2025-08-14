extends Node

# Loads dialogue JSON for the current scene and provides step/branch helpers.
# Minimal, jam-friendly: supports nodes, choices, effects, conditions, and scene exits.

var script_data := []      # now an Array, matches JSON structure
var current_node_id := ""  # string
var current_scene_key := ""  # string

func load_script(scene_key:String) -> bool:
	current_scene_key = scene_key
	var path = "res://dialogue/%s.json" % scene_key
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Dialogue file not found: %s" % path)
		script_data = []
		return false

	var text = file.get_as_text()
	var parse_result = JSON.parse_string(text)

	# Godot 4 parses arrays/objects directly, no result property
	if typeof(parse_result) == TYPE_ARRAY:
		script_data = parse_result
	else:
		push_error("Failed to parse JSON: expected array but got %s" % typeof(parse_result))
		script_data = []
		return false

	# Find start node
	for n in script_data:
		if n.get("id", "") == "start":
			current_node_id = "start"
			return true

	push_error("No 'start' node in %s" % scene_key)
	return false

func get_current_node():
	for n in script_data:
		if n.get("id", "") == current_node_id:
			return n
	return null

func goto_node(id:String):
	current_node_id = id

func apply_effects(effects:Dictionary):
	if effects.has("morality"):
		GameState.add_morality(int(effects.morality))
	if effects.has("bond"):
		GameState.add_bond(int(effects.bond))
	if effects.has("flags") and typeof(effects.flags) == TYPE_DICTIONARY:
		for k in effects.flags.keys():
			GameState.set_flag(k, effects.flags[k])

func choice_is_available(choice:Dictionary) -> bool:
	# Supports simple conditions: {"require": {"bond": ">=2", "morality": "<=-1", "flag_helped": true}}
	if not choice.has("require"):
		return true
	var req = choice.require
	for k in req.keys():
		var v = req[k]
		if k == "bond":
			if not _compare(GameState.bond, String(v)):
				return false
		elif k == "morality":
			if not _compare(GameState.morality, String(v)):
				return false
		elif k.begins_with("flag_"):
			var flag_name = k.substr(5)
			if GameState.get_flag(flag_name) != v:
				return false
		else:
			# Unknown requirement key
			pass
	return true

func _compare(current:int, expr:String) -> bool:
	# expr like ">=2", "<=-1", "==0"
	var op = expr.substr(0,2)
	var num_str = expr.substr(2)
	var value = int(num_str)
	match op:
		">=":
			return current >= value
		"<=":
			return current <= value
		"==":
			return current == value
		"> ":
			return current > int(expr.substr(1))
		"< ":
			return current < int(expr.substr(1))
		"!=":
			return current != value
		_:
			# Fallback: try first char ops
			var op1 = expr[0]
			var v1 = int(expr.substr(1))
			match String(op1):
				">":
					return current > v1
				"<":
					return current < v1
				_:
					return false
