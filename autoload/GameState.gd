extends Node

signal stats_changed

var dialogue_history = ""  # New variable to store all dialogue text
var flags := {}
var next_node_id = "" # To store the node ID for the next scene after a transition

func set_flag(key:String, value):
	flags[key] = value
	print("[Stats] Flag set: ", key, " = ", value)
	emit_signal("stats_changed")

func get_flag(key:String, default_value=null):
	return flags.get(key, default_value)

func reset_all():
	dialogue_history = "" # Reset the history on new game
	flags.clear()
	print("[Stats] All stats reset to default")
	emit_signal("stats_changed")
