extends Node

@onready var AmbientPlayer := $"../AmbientPlayer"
@onready var dialog_ui := $"../DialogBox"
@onready var GameState = get_node("/root/GameState")

const EndingDeterminer = preload("res://scripts/EndingDeterminer.gd")

var current_node_text := ""
var typewriter_index := 0
var typing_speed := 0.03
var typing := false
var waiting_for_click := false
var current_speaker := ""
var in_ending := false

var endings_file_path := "user://unlocked_endings.txt"
var unlocked_endings := []
var endings_data = {}
var final_ending_descriptions = {}

var act_ambient_sounds = {
	"act1_shrine": {
		"stream": preload("res://SFX/614092__szegvari__dark-atmo-sea-beach-sad-mood-myst-thriller-fantasy.wav"),
		"volume_db": -3 
	},
	"act2_market": {
		"stream": preload("res://SFX/581134__szegvari__dark-fantasy-forrest-atmo.wav"),
		"volume_db": -5  
	},
	"act3_womb_below": {
		"stream": preload("res://SFX/539813__szegvari__temple-fantasy-vocal-ambient.wav"),
		"volume_db": -3 
	}
}

func _ready():
	_load_endings_json()
	_load_final_ending_descriptions()
	_load_unlocked_endings()
	DialogueRouter.game_ended.connect(_on_game_ended)
	DialogueRouter.act_changed.connect(_on_act_changed)
	_load_scene("start")

func _load_endings_json():
	var file = FileAccess.open("res://dialogue/endings.json", FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		var parsed = JSON.parse_string(text)
		if typeof(parsed) == TYPE_ARRAY:
			for node in parsed:
				endings_data[node.get("id")] = node
			print("Loaded endings:", endings_data.size())
		else:
			print("Failed to parse endings.json: Not a valid array")
	else:
		print("ERROR: Could not load endings.json")

func _on_game_ended(ending_id: String):
	print("Game ended with ID: ", ending_id)
	
	_save_unlocked_ending(ending_id)
	_load_final_ending_scene(ending_id)

func _on_act_changed():
	print("Act changed.")
	in_ending = false
	_change_ambient_sound()
	_show_current_node()

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if typing:
			dialog_ui.show_line(current_speaker, current_node_text)
			typing = false
			waiting_for_click = true
		elif waiting_for_click:
			waiting_for_click = false
			if in_ending:
				var final_ending_key = EndingDeterminer.determine_ending(GameState.flags)
				_load_final_ending_scene(final_ending_key)
			else:
				_process_node_end()

func _load_scene(scene_key:String):
	print("Loading scene: ", scene_key)
	DialogueRouter.load_script(scene_key)
	_show_current_node()

func _show_current_node():
	var node = DialogueRouter.get_current_node()
	if node == null:
		print("No current node to show.")
		return

	current_speaker = node.get("speaker", "Narration")
	current_node_text = node.get("text", "")
	dialog_ui.clear_choices()
	typewriter_index = 0
	typing = true
	waiting_for_click = false
	dialog_ui.clear_text()
	set_process(true)

func _process(delta):
	if typing:
		if typewriter_index < current_node_text.length():
			typewriter_index += 1
			dialog_ui.show_line(current_speaker, current_node_text.substr(0, typewriter_index))
		else:
			typing = false
			waiting_for_click = true

func _process_node_end():
	var node = DialogueRouter.get_current_node()
	if node == null:
		print("Warning: _process_node_end called with no current node.")
		return

	var choices = node.get("choices", [])
	if choices.size() > 0:
		var visible_choices := []
		for ch in choices:
			if DialogueRouter.choice_is_available(ch):
				visible_choices.append(ch.text)
		dialog_ui.show_choices(visible_choices)
		var callable = Callable(self, "_on_choice_selected")
		if not dialog_ui.is_connected("choice_selected", callable):
			dialog_ui.connect("choice_selected", callable)
	elif node.has("goto"):
		DialogueRouter.goto_node(node.get("goto"))
		_show_current_node()
	elif node.has("exit_to"):
		var next_key = node.get("exit_to")
		if next_key.begins_with("ending:"):
			DialogueRouter.emit_ending_and_reset(next_key)
		elif DialogueRouter.scene_file_map.has(next_key):
			DialogueRouter.load_script(next_key)
		else:
			DialogueRouter.goto_node(next_key)
			_show_current_node()

func _on_choice_selected(index):
	var node = DialogueRouter.get_current_node()
	var choices = node.get("choices", [])
	if index >= choices.size():
		return
	var choice = choices[index]

	if choice.has("effects"):
		var effects = choice.effects
		if effects.has("flags") and typeof(effects.flags) == TYPE_DICTIONARY:
			for key in effects.flags.keys():
				GameState.set_flag(key, effects.flags[key])

	if choice.has("goto"):
		DialogueRouter.goto_node(choice.goto)
		_show_current_node()
	elif choice.has("exit_to"):
		var next_key = choice.exit_to
		if next_key.begins_with("ending:"):
			DialogueRouter.emit_ending_and_reset(next_key)
		elif DialogueRouter.scene_file_map.has(next_key):
			DialogueRouter.load_script(next_key)
		else:
			DialogueRouter.goto_node(next_key)
			_show_current_node()

func _load_unlocked_endings():
	unlocked_endings.clear()
	if FileAccess.file_exists(endings_file_path):
		var f = FileAccess.open(endings_file_path, FileAccess.READ)
		if f:
			while not f.eof_reached():
				var line = f.get_line().strip_edges()
				if line != "":
					unlocked_endings.append(line)
			f.close()

func _save_unlocked_ending(key: String):
	if key in unlocked_endings:
		return
	unlocked_endings.append(key)
	var f = FileAccess.open(endings_file_path, FileAccess.WRITE)
	if f:
		for e in unlocked_endings:
			f.store_line(e)
		f.close()

# SceneController.gd
func _load_final_ending_scene(key: String):
	print("Loading final ending scene with key: ", key)
	
	var final_description = final_ending_descriptions.get(key)
	
	if final_description:
		var end_scene = preload("res://scenes/EndGame.tscn").instantiate()
		end_scene.ending_key = key
		end_scene.ending_title = final_description.get("title", "Unknown Ending Title")
		end_scene.ending_text = final_description.get("text", "No description available.")
		get_tree().current_scene.queue_free()
		get_tree().root.add_child(end_scene)
	else:
		push_error("ERROR: Final ending description not found for key: ", key)
		var end_scene = preload("res://scenes/EndGame.tscn").instantiate()
		end_scene.ending_key = "lost"
		end_scene.ending_title = "An Unforeseen End"
		end_scene.ending_text = "The story concluded in an unexpected way. An ending description could not be found."
		get_tree().current_scene.queue_free()
		get_tree().root.add_child(end_scene)

func _load_final_ending_descriptions():
	var file = FileAccess.open("res://dialogue/endings_info.json", FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		var parsed = JSON.parse_string(text)
		if typeof(parsed) == TYPE_DICTIONARY:
			final_ending_descriptions = parsed
			print("Loaded final ending descriptions:", final_ending_descriptions.size())
		else:
			print("Failed to parse endings_info.json: Not a valid dictionary")
	else:
		print("ERROR: Could not load endings_info.json.")

func _change_ambient_sound():
	var current_act_key = DialogueRouter.current_scene_key
	if act_ambient_sounds.has(current_act_key):
		var sound_info = act_ambient_sounds[current_act_key] 
		
		AmbientPlayer.stop()
		AmbientPlayer.stream = sound_info["stream"]
		AmbientPlayer.volume_db = sound_info["volume_db"]
		
		AmbientPlayer.play()
	else:
		print("No ambient sound found for act key: ", current_act_key)
