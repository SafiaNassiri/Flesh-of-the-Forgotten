extends Node

@onready var ambient_music_player := $AmbientMusicPlayer
@onready var button_sound_player := $ButtonSoundPlayer

@onready var menu_vbox := $Panel/MenuVBox
@onready var endings_vbox := $Panel/EndingsVBox
@onready var ending_buttons_vbox := $Panel/EndingsVBox/EndingsScroll/CenterContainer/EndingButtonsVBox
@onready var reset_btn := $Panel/EndingsVBox/ButtonContainer/ResetButton
@onready var return_btn := $Panel/EndingsVBox/ButtonContainer/ReturnButton

var unlocked_endings_file := "user://unlocked_endings.txt"

var unlocked_endings := []
var endings_info = {}

func _ready():
	ambient_music_player.play()
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
	
	for child in ending_buttons_vbox.get_children():
		child.queue_free()
	
	var populated_count = 0

	for key in endings_info.keys():
		var btn = Button.new()
		btn.name = "EndingBtn_" + key
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
	_play_button_sound()
	var timer = get_tree().create_timer(0.31)
	await timer.timeout
	GameState.reset_all()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_endings_pressed():
	_play_button_sound()
	print("MainMenu: 'Endings' button pressed. Showing endings_vbox.")
	menu_vbox.visible = false
	endings_vbox.visible = true
	_populate_endings_list()

func _on_quit_pressed():
	_play_button_sound()
	get_tree().quit()

func _on_reset_button_pressed() -> void:
	_play_button_sound()
	var f = FileAccess.open(unlocked_endings_file, FileAccess.WRITE)
	if f:
		f.store_string("")
		f.close()
	unlocked_endings.clear()
	_populate_endings_list()

func _on_return_button_pressed() -> void:
	_play_button_sound()
	endings_vbox.visible = false
	menu_vbox.visible = true

func _on_ending_pressed(key: String):
	_play_button_sound()
	if key in unlocked_endings and endings_info.has(key):
		var ending_info = endings_info[key]

		var popup_panel = Panel.new()
		popup_panel.name = "EndingPopup"
		popup_panel.set_size(Vector2(600, 400))
		
		var viewport_size = get_viewport().get_visible_rect().size
		popup_panel.position = (viewport_size - popup_panel.size) / 2
		
		var background = ColorRect.new()
		background.color = Color(0, 0, 0, 0.75)
		background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		popup_panel.add_child(background)
		
		var margin_container = MarginContainer.new()
		margin_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		margin_container.add_theme_constant_override("margin_left", 20)
		margin_container.add_theme_constant_override("margin_top", 20)
		margin_container.add_theme_constant_override("margin_right", 20)
		margin_container.add_theme_constant_override("margin_bottom", 20)
		popup_panel.add_child(margin_container)
		
		var content_vbox = VBoxContainer.new()
		content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		content_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
		margin_container.add_child(content_vbox)

		var title_label = Label.new()
		title_label.text = ending_info["title"]
		title_label.add_theme_font_size_override("font_size", 30)
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		content_vbox.add_child(title_label)

		var separator = Control.new()
		separator.custom_minimum_size = Vector2(0, 20)
		content_vbox.add_child(separator)

		var info_label = RichTextLabel.new()
		info_label.bbcode_enabled = true
		info_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		info_label.bbcode_text = "[center]%s[/center]" % ending_info["text"]
		info_label.add_theme_font_size_override("normal_font_size", 25)
		info_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		content_vbox.add_child(info_label)
		
		var close_btn = Button.new()
		close_btn.text = "Close"
		close_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		close_btn.custom_minimum_size = Vector2(150, 40)
		close_btn.add_theme_font_size_override("font_size", 25)
		
		var normal_stylebox = StyleBoxFlat.new()
		normal_stylebox.bg_color = Color.BLACK
		normal_stylebox.set_corner_radius_all(8)
		
		var hover_stylebox = StyleBoxFlat.new()
		hover_stylebox.bg_color = Color.GRAY
		hover_stylebox.set_corner_radius_all(8)

		close_btn.add_theme_stylebox_override("normal", normal_stylebox)
		close_btn.add_theme_stylebox_override("hover", hover_stylebox)
		close_btn.connect("pressed", Callable(popup_panel, "queue_free"))
		content_vbox.add_child(close_btn)
		
		add_child(popup_panel)
	else:
		print("Ending info not found for key: ", key)

func _play_button_sound():
	if button_sound_player:
		button_sound_player.play()
