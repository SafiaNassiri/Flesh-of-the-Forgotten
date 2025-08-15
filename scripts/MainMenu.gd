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
		var text = file.get_as_text()
		file.close()
		
		var parsed = JSON.parse_string(text)
		if typeof(parsed) == TYPE_ARRAY:   # your endings.json is an array
			endings_data = parsed
		else:
			print("Failed to parse endings.json: not an array")
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
	title_label.add_theme_font_size_override("font_size", 50)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	endings_vbox.add_child(title_label)

	# Load endings info JSON
	var info_data = {}
	var file = FileAccess.open("res://dialogue/endings_info.json", FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		var parsed = JSON.parse_string(text)
		if typeof(parsed) == TYPE_DICTIONARY:
			info_data = parsed
		else:
			print("Failed to parse endings_info.json")
	else:
		print("Failed to open endings_info.json")

	# Add unlocked endings first
	for entry in endings_data:
		var key = entry["ending"]
		var btn = Button.new()
		btn.name = "EndingBtn_" + key
		btn.text = key.capitalize() if key in unlocked_endings else "???"
		btn.disabled = not (key in unlocked_endings)
		btn.add_theme_font_size_override("font_size", 25)
		btn.connect("pressed", Callable(self, "_on_ending_pressed").bind(key))
		endings_vbox.add_child(btn)

	# Spacer
	var spacer = Label.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	endings_vbox.add_child(spacer)

	# Reset button
	var reset_btn = Button.new()
	reset_btn.text = "Reset Player File"
	reset_btn.add_theme_font_size_override("font_size", 25)
	reset_btn.connect("pressed", Callable(self, "_on_reset_endings_pressed"))
	endings_vbox.add_child(reset_btn)

	# Return button
	var return_btn = Button.new()
	return_btn.text = "Return to Main Menu"
	return_btn.add_theme_font_size_override("font_size", 25)
	return_btn.connect("pressed", Callable(self, "_on_return_pressed"))
	endings_vbox.add_child(return_btn)

func _on_play_pressed():
	# Reset PlayerStats before starting a new run
	PlayerStats.reset_all()
	
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
	# Load endings_info.json
	var info_data = {}
	var file = FileAccess.open("res://dialogue/endings_info.json", FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		var parsed = JSON.parse_string(text)
		if typeof(parsed) == TYPE_DICTIONARY:
			info_data = parsed

	if key in unlocked_endings and key in info_data:
		var dialog = AcceptDialog.new()
		dialog.dialog_text = "%s\n\n%s" % [info_data[key]["title"], info_data[key]["text"]]
		add_child(dialog)
		dialog.popup_centered()
