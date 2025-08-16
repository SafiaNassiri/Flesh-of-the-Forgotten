extends Node

@onready var menu_vbox := $Panel/MenuVBox
@onready var endings_vbox := $Panel/EndingsVBox
@onready var ending_buttons_vbox := $Panel/EndingsVBox/EndingsScroll/CenterContainer/EndingButtonsVBox
@onready var reset_btn := $Panel/EndingsVBox/ButtonContainer/ResetButton
@onready var return_btn := $Panel/EndingsVBox/ButtonContainer/ReturnButton

var unlocked_endings_file := "user://unlocked_endings.txt"

var unlocked_endings := []
var endings_info = {}

func _ready():
	endings_vbox.visible = false
	
	_load_endings_info()
	_load_unlocked_endings()

	print("MainMenu: _ready completed.")
	print("MainMenu: endings_info keys after loading: ", endings_info.keys())

func _load_endings_info():
	var file = FileAccess.open("res://dialogue/endings_info.json", FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		var parsed = JSON.parse_string(text)
		if typeof(parsed) == TYPE_DICTIONARY:
			endings_info = parsed
			print("MainMenu: Successfully loaded endings_info.json. Number of entries: ", endings_info.size())
		else:
			print("MainMenu: Failed to parse endings_info.json: Not a dictionary. Parsed type: ", typeof(parsed))
	else:
		print("MainMenu: Failed to open endings_info.json at path: ", "res://dialogue/endings_info.json")

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
	print("MainMenu: _populate_endings_list called.")
	
	# The CenterContainer now handles the centering automatically,
	# so these lines are no longer necessary.
	# ending_buttons_vbox.set_alignment(BoxContainer.ALIGNMENT_CENTER)
	# var flags = ending_buttons_vbox.size_flags_vertical
	# flags = flags & ~Control.SIZE_EXPAND
	# flags = flags | Control.SIZE_SHRINK_CENTER
	# ending_buttons_vbox.size_flags_vertical = flags
	
	for child in ending_buttons_vbox.get_children():
		child.queue_free()
	
	var populated_count = 0

	for key in endings_info.keys():
		var btn = Button.new()
		btn.name = "EndingBtn_" + key
		
		# Set the button's horizontal size flags to Shrink Center.
		# This is still a good practice to prevent the button from expanding to fill the VBoxContainer.
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		
		var is_unlocked = key in unlocked_endings
		
		if is_unlocked:
			var title = endings_info.get(key, {}).get("title", "???")
			btn.text = title
			print("  - Creating button for unlocked ending: %s (Text: %s)" % [key, title])
		else:
			btn.text = "???"
			print("  - Creating button for locked ending: %s (Text: ???)" % key)
			
		btn.disabled = not is_unlocked
		btn.add_theme_font_size_override("font_size", 25)
		btn.connect("pressed", Callable(self, "_on_ending_pressed").bind(key))
		ending_buttons_vbox.add_child(btn)
		populated_count += 1
	
	print("MainMenu: Finished populating. Total buttons created: ", populated_count)
	print("MainMenu: Children in ending_buttons_vbox: ", ending_buttons_vbox.get_children().size())

func _on_play_pressed():
	GameState.reset_all()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_endings_pressed():
	print("MainMenu: 'Endings' button pressed. Showing endings_vbox.")
	menu_vbox.visible = false
	endings_vbox.visible = true
	_populate_endings_list()

func _on_quit_pressed():
	get_tree().quit()

func _on_reset_button_pressed() -> void:
	var f = FileAccess.open(unlocked_endings_file, FileAccess.WRITE)
	if f:
		f.store_string("")
		f.close()
	unlocked_endings.clear()
	_populate_endings_list()

func _on_return_button_pressed() -> void:
	endings_vbox.visible = false
	menu_vbox.visible = true

func _on_ending_pressed(key: String):
	if key in unlocked_endings and endings_info.has(key):
		var dialog = AcceptDialog.new()
		var ending_info = endings_info[key]
		dialog.dialog_text = "%s\n\n%s" % [ending_info["title"], ending_info["text"]]
		add_child(dialog)
		dialog.popup_centered()
	else:
		print("Ending info not found for key: ", key)
