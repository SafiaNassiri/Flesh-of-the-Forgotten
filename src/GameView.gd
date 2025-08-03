extends CanvasLayer

@onready var story_text = $MarginContainer/VBoxContainer/StoryText
@onready var choice_box = $MarginContainer/VBoxContainer/ChoiceBox
@onready var inventory_popup = $InventoryPopup
@onready var map_popup = $MapPopup
@onready var pause_menu = $PauseMenu
@onready var resume_button = $PauseMenu/Panel/VBoxContainer/Resume
@onready var main_menu_button = $PauseMenu/Panel/VBoxContainer/MainMenu
@onready var quit_button = $PauseMenu/Panel/VBoxContainer/Quit

var current_node = "1.0"  # Start node id from your STORY dictionary

func _ready():
	load_node(current_node)
	
	# Connect pause menu buttons
	resume_button.pressed.connect(toggle_pause_menu)
	main_menu_button.pressed.connect(_go_to_main_menu)
	quit_button.pressed.connect(_quit_game)
	
	pause_menu.visible = false

func _input(event):
	if event.is_action_pressed("ui_inventory"):
		inventory_popup.visible = not inventory_popup.visible
	if event.is_action_pressed("ui_map"):
		map_popup.visible = not map_popup.visible
	if event.is_action_pressed("ui_pause"):
		toggle_pause_menu()

func load_node(node_id: String):
	# Clear choices
	for child in choice_box.get_children():
		child.queue_free()

	if StoryData.ENDINGS.has(node_id):
		var ending = StoryData.ENDINGS[node_id]
		story_text.text = "[%s]\n\n%s" % [ending.title, ending.description]
		Global.state.unlock_ending(node_id)

		var restart_btn = Button.new()
		restart_btn.text = "Restart Game"
		restart_btn.pressed.connect(_on_restart_pressed)
		choice_box.add_child(restart_btn)

	else:
		var node = StoryData.STORY.get(node_id)
		if node:
			story_text.text = node["text"]
			for choice in node["choices"]:
				var btn = Button.new()
				btn.text = choice["text"]
				btn.pressed.connect(Callable(self, "_on_choice_selected").bind(choice))
				choice_box.add_child(btn)
		else:
			story_text.text = "ERROR: Node '%s' not found." % node_id

func _on_choice_selected(choice):
	if "effects" in choice:
		for key in choice.effects.keys():
			var val = choice.effects[key]
			if not Global.state.get_flag(key) and typeof(val) == TYPE_BOOL:
				Global.state.set_flag(key, val)
			elif typeof(val) == TYPE_INT:
				var current = Global.state.get_flag(key)
				if not current:
					current = 0
				Global.state.set_flag(key, current + val)

	current_node = choice.next
	load_node(current_node)

func _on_restart_pressed():
	Global.state.inventory.clear()
	Global.state.flags.clear()
	Global.state.endings_unlocked.clear()
	current_node = "1.0"
	load_node(current_node)

func toggle_pause_menu():
	if pause_menu.visible:
		get_tree().paused = false
		pause_menu.visible = false
	else:
		get_tree().paused = true
		pause_menu.visible = true
		resume_button.grab_focus()  # Optional: auto-focus resume on open

func _go_to_main_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _quit_game():
	get_tree().quit()
