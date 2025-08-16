extends CanvasLayer

@onready var dialogue_text := $Panel/VBox/DialogueText
@onready var choices_container := $Panel/VBox/Choices

signal choice_selected(index)

func clear_text():
	dialogue_text.clear()

# This function needs to be updated to accept the full history text.
# It should not clear the text, but rather set the full BBCode string.
func show_line(speaker:String, text:String):
	# The 'speaker' parameter is no longer used for formatting,
	# as the text is pre-formatted in the SceneController.
	dialogue_text.bbcode_text = text

# Add this new function to scroll the RichTextLabel.
func scroll_to_end():
	dialogue_text.scroll_to_line(dialogue_text.get_line_count() - 1)

# Show multiple choices
func show_choices(choices:Array):
	clear_choices()
	for i in range(choices.size()):
		var btn = Button.new()
		btn.text = choices[i]
		btn.name = str(i)
		btn.connect("pressed", Callable(self, "_on_choice_pressed").bind(i))
		choices_container.add_child(btn)

# Clear all buttons
func clear_choices():
	for child in choices_container.get_children():
		child.queue_free()

func _on_choice_pressed(index):
	emit_signal("choice_selected", index)
	clear_choices()
