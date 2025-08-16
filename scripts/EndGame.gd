# EndGame.gd
extends Control

@export var ending_key := "" # Keep this if you still need it for other logic in EndGame.tscn
@export var ending_title := "Default Title" # New export var for the title
@export var ending_text := "Default Text"   # New export var for the text

@onready var title_label := $Panel/VBoxContainer/EndingTitle
@onready var text_label := $Panel/VBoxContainer/EndingText
@onready var return_btn := $Panel/VBoxContainer/ReturnButton

func _ready():
	# Assign the passed-in values directly to the labels
	title_label.text = ending_title
	text_label.text = ending_text

	return_btn.connect("pressed", Callable(self, "_on_return_pressed"))

func _on_return_pressed():
	# Remove EndGame scene from tree
	self.queue_free()
	
	# Go back to Main Menu
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
