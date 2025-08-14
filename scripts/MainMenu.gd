extends Node

@onready var menu_vbox := $Panel/MenuVBox
@onready var endings_vbox := $Panel/EndingsVBox

var endings_json_path := "res://dialogue/endings.json"
var unlocked_endings_file := "user://unlocked_endings.txt"

var endings_data = {}
var unlocked_endings := []

func _ready():
	# Hide endings panel by default
	endings_vbox.visible = false
	
	# Load endings JSON
	var file = FileAccess.open(endings_json_path, FileAccess.READ)
	if file:
		var parse_result = JSON.parse_string(file.get_as_text())
		file.close()
		if parse_result.has("error") and parse_result.error == OK:
			endings_data = parse_result.result
		else:
			print("Failed to parse endings.json:", parse_result.get("error_string", "Unknown error"))
	else:
		print("Failed to open endings.json")

	# Load unlocked endings from file
	_load_unlocked_endings()

func _load_unlocked_endings():
	unlocked_endings.clear()
	if FileAccess.file_exists(unlocked_endings_file):
		var f = FileAccess.open(unlocked_endings_file, FileAccess.READ)
		if f:
			while not f.eof_reached():
				var line = f.get_line().strip_edges()
				if line != "":
					unlocked_endings.append(line)
			f.close()

func _populate_endings_list():
	# Clear all dynamic children
	for child in endings_vbox.get_children():
		child.queue_free()

	# Add title label
	var title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "Unlocked Endings"
	title_label.add_theme_font_size_override("font_size", 50) # Title font size
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	endings_vbox.add_child(title_label)

	# Load endings info JSON
	var data = {}
	var file = FileAccess.open("res://dialogue/endings_info.json", FileAccess.READ)
	if file:
		var parsed = JSON.parse_string(file.get_as_text())
		file.close()
		if typeof(parsed) == TYPE_DICTIONARY:
			data = parsed
		else:
			print("Failed to parse endings_info.json")
	else:
		print("Failed to open endings_info.json")

	# Add unlocked endings first
	for key in data.keys():
		if key in unlocked_endings:
			var btn = Button.new()
			btn.name = "EndingBtn_" + key
			btn.text = key.capitalize()
			btn.disabled = false
			btn.add_theme_font_size_override("font_size", 25) # Button font size
			btn.connect("pressed", Callable(self, "_on_ending_pressed").bind(key))
			endings_vbox.add_child(btn)

	# Add locked endings
	for key in data.keys():
		if key not in unlocked_endings:
			var btn = Button.new()
			btn.name = "EndingBtn_" + key
			btn.text = "???"
			btn.disabled = true
			btn.add_theme_font_size_override("font_size", 25) # Button font size
			btn.connect("pressed", Callable(self, "_on_ending_pressed").bind(key))
			endings_vbox.add_child(btn)

	# Add a spacer Label
	var spacer = Label.new()
	spacer.name = "Spacer"
	spacer.text = ""
	spacer.custom_minimum_size = Vector2(0, 20)
	endings_vbox.add_child(spacer)

	# Add Reset button
	var reset_btn = Button.new()
	reset_btn.name = "ResetEndings"
	reset_btn.text = "Reset Player File"
	reset_btn.add_theme_font_size_override("font_size", 25) # Button font size
	reset_btn.connect("pressed", Callable(self, "_on_reset_endings_pressed"))
	endings_vbox.add_child(reset_btn)

	# Add Return button
	var return_btn = Button.new()
	return_btn.name = "Return"
	return_btn.text = "Return to Main Menu"
	return_btn.add_theme_font_size_override("font_size", 25) # Button font size
	return_btn.connect("pressed", Callable(self, "_on_return_pressed"))
	endings_vbox.add_child(return_btn)

func _on_play_pressed():
	# Load first game scene
	get_tree().change_scene_to_file("res://scenes/Main.tscn") # replace with your first scene

func _on_endings_pressed():
	menu_vbox.visible = false
	endings_vbox.visible = true
	_populate_endings_list()

func _on_return_pressed():
	endings_vbox.visible = false
	menu_vbox.visible = true

func _on_reset_endings_pressed():
	# Clear TXT file
	var f = FileAccess.open(unlocked_endings_file, FileAccess.WRITE)
	if f:
		f.store_string("")
		f.close()
	unlocked_endings.clear()
	_populate_endings_list()

func _on_quit_pressed():
	get_tree().quit()

func _on_ending_pressed(key: String):
	# Load endings_info.json to get title + text
	var file = FileAccess.open("res://dialogue/endings_info.json", FileAccess.READ)
	var data = {}
	if file:
		var text = file.get_as_text()
		file.close()
		var parsed = JSON.parse_string(text)
		if typeof(parsed) == TYPE_DICTIONARY:
			data = parsed
		else:
			data = {}
	else:
		data = {}

	if key in unlocked_endings and key in data:
		var dialog = AcceptDialog.new()
		dialog.dialog_text = "%s\n\n%s" % [data[key]["title"], data[key]["text"]]
		add_child(dialog)
		dialog.popup_centered()
