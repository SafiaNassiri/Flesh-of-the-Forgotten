extends Node

signal stats_changed

var dialogue_history = ""
var flags := {}
var next_node_id = ""

func set_flag(key:String, value):
	flags[key] = value
	print("[Stats] Flag set: ", key, " = ", value)
	emit_signal("stats_changed")

func get_flag(key:String, default_value=null):
	return flags.get(key, default_value)

func reset_all():
	dialogue_history = "" 
	flags.clear()
	print("[Stats] All stats reset to default")
	emit_signal("stats_changed")
