extends Control

@onready var button_sound_player := $ButtonSoundPlayer
@onready var AmbientPlayer := $"AmbientPlayer"

@export var ending_key := ""
@export var ending_title := "Default Title" 
@export var ending_text := "Default Text" 

@onready var title_label := $Panel/VBoxContainer/EndingTitle
@onready var text_label := $Panel/VBoxContainer/EndingText
@onready var return_btn := $Panel/VBoxContainer/ReturnButton

func _ready():
	AmbientPlayer.play()
	title_label.text = ending_title
	text_label.text = ending_text

	return_btn.connect("pressed", Callable(self, "_on_return_pressed"))

func _on_return_pressed():
	_play_button_sound()
	var timer = get_tree().create_timer(0.31)
	await timer.timeout
	self.queue_free()
	
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _play_button_sound():
	if button_sound_player:
		button_sound_player.play()
