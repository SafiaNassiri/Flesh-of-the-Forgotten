extends Node

signal game_ended(ending_id: String)
signal act_changed

var script_data := []
var current_node_id := ""
var current_scene_key := ""

var scene_file_map := {
	"start": "act1_shrine",
	"start_cautious": "act2_market",
	"start_bold": "act2_market",
	"start_dark_merge": "act2_market",
	"cautious_start": "act3_womb_below",
	"bold_start": "act3_womb_below",
	"dark_start": "act3_womb_below",
}

func load_script(node_id_to_start_at: String) -> bool:
	var file_key : String = ""

	if scene_file_map.has(node_id_to_start_at):
		file_key = scene_file_map[node_id_to_start_at]
	elif node_id_to_start_at.begins_with("ending:"):
		file_key = "endings"
	else:
		file_key = node_id_to_start_at
		push_warning("load_script called with non-mapped ID '%s'. Attempting to load '%s.json'." % [node_id_to_start_at, file_key])

	current_scene_key = file_key
	
	var path = "res://dialogue/%s.json" % file_key
	if not FileAccess.file_exists(path):
		push_error("Dialogue file not found: %s for node_id: %s" % [path, node_id_to_start_at])
		script_data = []
		return false

	var file = FileAccess.open(path, FileAccess.READ)
	var text = file.get_as_text()
	file.close()

	var parse_result = JSON.parse_string(text)
	if typeof(parse_result) == TYPE_DICTIONARY:
		if parse_result.error != OK:
			push_error("Failed to parse JSON: %s - %s" % [parse_result.error_string, path])
			return false
		script_data = parse_result.result
	elif typeof(parse_result) == TYPE_ARRAY:
		script_data = parse_result
	else:
		push_error("JSON parse returned unexpected type: %s for %s" % [typeof(parse_result), path])
		return false

	if get_node_by_id(node_id_to_start_at) != null:
		current_node_id = node_id_to_start_at
	elif script_data.size() > 0:
		current_node_id = script_data[0].get("id", "")
		push_warning("Node '%s' not found in %s.json. Defaulting to first node '%s'." % [node_id_to_start_at, file_key, current_node_id])
		if current_node_id.begins_with("ending:"):
			emit_ending_and_reset(current_node_id)
			return false
	else:
		push_error("JSON is empty: %s" % path)
		return false
	
	emit_signal("act_changed")
	
	return true

func get_current_node():
	for n in script_data:
		if n.get("id", "") == current_node_id:
			return n
	return null

func goto_node(id:String) -> bool:
	if get_node_by_id(id):
		current_node_id = id
		return true
	else:
		if scene_file_map.has(id):
			GameState.next_node_id = id
			return true
		
		push_error("goto_node failed: node '%s' not found in CURRENTLY LOADED SCRIPT (%s.json)." % [id, current_scene_key])
		return false

func emit_ending_and_reset(ending_id: String):
	emit_signal("game_ended", ending_id)
	script_data = []
	current_node_id = ""
	current_scene_key = ""
	GameState.reset_all()

func get_node_by_id(id:String):
	for n in script_data:
		if n.get("id", "") == id:
			return n
	return null

func apply_effects(effects:Dictionary):
	if effects.has("flags") and typeof(effects.flags) == TYPE_DICTIONARY:
		for k in effects.flags.keys():
			GameState.set_flag(k, effects.flags[k])
	if effects.has("morality"):
		GameState.add_morality(effects.morality)
	if effects.has("bond"):
		GameState.add_bond(effects.bond)

func choice_is_available(choice:Dictionary) -> bool:
	if not choice.has("require"):
		return true
	var req = choice.require
	for k in req.keys():
		var v = req[k]
		if k.begins_with("flag_"):
			var flag_name = k.substr(5)
			if GameState.get_flag(flag_name) != v:
				return false
	return true
