extends Control

@export var ending_key := ""
@onready var title_label := $Panel/VBoxContainer/EndingTitle
@onready var text_label := $Panel/VBoxContainer/EndingText
@onready var return_btn := $Panel/VBoxContainer/ReturnButton

func _ready():
	# Load endings JSON
	var file = FileAccess.open("res://dialogue/endings_info.json", FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		
		var data = JSON.parse_string(text)
		
		if typeof(data) == TYPE_DICTIONARY:
			if ending_key in data:
				var ending_entry = data[ending_key]
				if typeof(ending_entry) == TYPE_DICTIONARY:
					title_label.text = ending_entry.get("title", "No Title")
					text_label.text = ending_entry.get("text", "No Text")
				else:
					title_label.text = "Invalid ending data"
					text_label.text = ""
			else:
				title_label.text = "Ending not found"
				text_label.text = ""
		else:
			title_label.text = "Failed to parse JSON"
			text_label.text = ""
	else:
		title_label.text = "Error loading endings"
		text_label.text = ""

	return_btn.connect("pressed", Callable(self, "_on_return_pressed"))

func _on_return_pressed():
	# Remove EndGame scene from tree
	self.queue_free()
	
	# Go back to Main Menu
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
