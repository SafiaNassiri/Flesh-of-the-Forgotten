extends CanvasLayer

@onready var button_sound_player := $ButtonSoundPlayer

@onready var dialogue_text := $Panel/VBox/DialogueText
@onready var choices_container := $Panel/VBox/Choices

signal choice_selected(index)

func clear_text():
	dialogue_text.clear()

func show_line(speaker:String, text:String):
	dialogue_text.bbcode_text = text

func scroll_to_end():
	dialogue_text.scroll_to_line(dialogue_text.get_line_count() - 1)

func show_choices(choices:Array):
	clear_choices()
	for i in range(choices.size()):
		var btn = Button.new()
		btn.text = choices[i]
		btn.name = str(i)
		btn.connect("pressed", Callable(self, "_on_choice_pressed").bind(i))
		choices_container.add_child(btn)

func clear_choices():
	for child in choices_container.get_children():
		child.queue_free()

func _on_choice_pressed(index):
	_play_button_sound()
	emit_signal("choice_selected", index)
	clear_choices()

func _play_button_sound():
	if button_sound_player:
		button_sound_player.play()
