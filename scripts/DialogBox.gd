extends CanvasLayer

@onready var dialogue_text := $Panel/VBox/DialogueText
@onready var choices_container := $Panel/VBox/Choices

signal choice_selected(index)

func clear_text():
	dialogue_text.clear()

func show_line(speaker:String, text:String):
	dialogue_text.clear()
	var color := "[color=white]"
	if speaker == "Kael":
		color = "[color=purple]"
	elif speaker == "Godling":
		color = "[color=orange]"
	dialogue_text.bbcode_text = "%s[b]%s:[/b] %s[/color]" % [color, speaker, text]

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
