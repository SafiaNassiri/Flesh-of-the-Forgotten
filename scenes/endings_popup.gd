extends Control

@onready var endings_list = $VBoxContainer/EndingsList  # ItemList node
@onready var description_label = $VBoxContainer/DescriptionLabel  # Label node

func _ready():
	endings_list.connect("item_selected", Callable(self, "_on_ending_selected"))
	update_endings_list()

func update_endings_list():
	endings_list.clear()
	for ending_id in StoryData.ENDINGS.keys():
		var ending = StoryData.ENDINGS[ending_id]
		var unlocked = Global.state.endings_unlocked.has(ending_id)
		var display_name = ending.title + (" (Unlocked)" if unlocked else " (Locked)")
		endings_list.add_item(display_name)

	if endings_list.get_item_count() > 0:
		endings_list.select(0)
		show_ending_description(0)
	else:
		description_label.text = "No endings available."

func _on_ending_selected(index):
	show_ending_description(index)

func show_ending_description(index):
	var ending_id = StoryData.ENDINGS.keys()[index]
	var ending = StoryData.ENDINGS[ending_id]

	if Global.state.endings_unlocked.has(ending_id):
		description_label.text = ending.description
	else:
		description_label.text = "This ending is locked."
