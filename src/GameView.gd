extends CanvasLayer

@onready var story_text = $MarginContainer/VBoxContainer/StoryText
@onready var choice_box = $MarginContainer/VBoxContainer/ChoiceBox
@onready var inventory_popup = $InventoryPopup
@onready var map_popup = $MapPopup

var current_node = "start"

func _ready():
	load_node(current_node)

func _input(event):
	if event.is_action_pressed("ui_inventory"):
		inventory_popup.visible = not inventory_popup.visible
	if event.is_action_pressed("ui_map"):
		map_popup.visible = not map_popup.visible

func load_node(node_id: String):
	var node = StoryData.STORY.get(node_id)
	if node:
		story_text.text = node["text"]

		for child in choice_box.get_children():
			child.queue_free()

		for choice in node["choices"]:
			var btn = Button.new()
			btn.text = choice["text"]
			btn.pressed.connect(Callable(self, "_on_choice_selected").bind(choice["next"]))
			choice_box.add_child(btn)

		# Save the ending if reached
		if node.has("ending") and node["ending"]:
			Global.endings.save_ending(node_id)

func _on_choice_selected(next_node: String):
	current_node = next_node
	load_node(current_node)
