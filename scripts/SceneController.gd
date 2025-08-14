extends Node

@onready var dialog_ui := $"../DialogBox"
var current_scene_key := "act1_shrine"

var endings_file_path := "user://unlocked_endings.txt"
var unlocked_endings := []

var current_node_text := ""
var typewriter_index := 0
var typing_speed := 0.03
var typing := false
var waiting_for_click := false
var current_speaker := ""
var in_ending := false
var endings_data = {}

func _ready():
	# Load endings JSON
	var file = FileAccess.open("res://dialogue/endings.json", FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		
		# In Godot 4, parse_string returns Dictionary directly
		var parsed = JSON.parse_string(text)
		
		# Check if it's a dictionary
		if typeof(parsed) == TYPE_DICTIONARY:
			endings_data = parsed
		else:
			print("Failed to parse endings.json: Not a valid dictionary")
	else:
		print("ERROR: Could not load endings.json")
	
	_load_unlocked_endings()
	_load_scene(current_scene_key)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if typing:
			# Finish typing immediately
			dialog_ui.show_line(current_speaker, current_node_text)
			typing = false
			waiting_for_click = true
		elif waiting_for_click:
			waiting_for_click = false
			_process_node_end()

func _load_scene(scene_key:String):
	print("Loading scene: ", scene_key)
	current_scene_key = scene_key
	var ok = DialogueRouter.load_script(scene_key)
	if not ok:
		print("Failed to load scene: ", scene_key)
		return
	_show_current_node()

func _show_current_node():
	var node = DialogueRouter.get_current_node()
	if node == null:
		return

	current_speaker = node.get("speaker", "Narration")
	current_node_text = node.get("text", "")
	dialog_ui.clear_choices()
	typewriter_index = 0
	typing = true
	waiting_for_click = false

	# Start typewriter effect
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
			set_process(false)

func _process_node_end():
	if in_ending:
		# Already handled; do nothing or can reset state
		return

	var node = DialogueRouter.get_current_node()
	if node == null:
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
			var ending_name = next_key.substr(7)
			show_ending(ending_name)
		else:
			_load_scene(next_key)

func _on_choice_selected(index):
	var node = DialogueRouter.get_current_node()
	var choices = node.get("choices", [])
	if index >= choices.size():
		return
	var choice = choices[index]

	# Apply choice effects
	if choice.has("effects"):
		var effects = choice.effects
		if effects.has("morality"):
			PlayerStats.add_morality(effects.morality)
		if effects.has("bond"):
			PlayerStats.add_bond(effects.bond)
		if effects.has("flags"):
			for key in effects.flags.keys():
				PlayerStats.set_flag(key, effects.flags[key])

	# Proceed to next node or ending
	if choice.has("goto"):
		DialogueRouter.goto_node(choice.goto)
		_show_current_node()
	elif choice.has("exit_to"):
		var next_key = choice.exit_to
		if next_key.begins_with("ending:"):
			var ending_name = next_key.substr(7)
			_show_ending_based_on_stats(ending_name)
		else:
			_load_scene(next_key)

func _show_ending_based_on_stats(default_ending_key:String):
	var ending_key = default_ending_key
	
	# Example: override ending based on stats
	if PlayerStats.get_flag("low_bond_path", false):
		ending_key = "predatory"
	elif PlayerStats.get_flag("high_bond_path", false) and PlayerStats.bond >= 5:
		ending_key = "trickster"
	elif PlayerStats.morality >= 5:
		ending_key = "benevolent"
	elif PlayerStats.morality <= -3:
		ending_key = "tyrant"
	elif PlayerStats.bond <= 0:
		ending_key = "mortal"

	show_ending(ending_key)

# In your SceneController.gd
func show_ending(key: String):
	if key in endings_data:
		_save_unlocked_ending(key)
		in_ending = true

		# Load EndGame scene instead of showing text in dialog
		var end_scene = preload("res://scenes/EndGame.tscn").instantiate()
		end_scene.ending_key = key
		get_tree().current_scene.queue_free()  # remove current scene
		get_tree().root.add_child(end_scene)
	else:
		dialog_ui.show_line("Narration", "Ending not found.")

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
