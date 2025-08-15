extends Node

signal stats_changed

var morality:int = 0
var bond:int = 0
var flags := {}

func add_morality(delta:int):
	morality += delta
	print("[Stats] Morality updated: ", morality)
	emit_signal("stats_changed")

func add_bond(delta:int):
	bond += delta
	bond = clamp(bond, 0, 300) # cap at a maximum
	print("[Stats] Bond updated: ", bond)
	emit_signal("stats_changed")

func set_flag(key:String, value):
	flags[key] = value
	print("[Stats] Flag set: ", key, " = ", value)
	emit_signal("stats_changed")

func get_flag(key:String, default_value=null):
	return flags.get(key, default_value)

func reset_all():
	morality = 0
	bond = 0
	flags.clear()
	print("[Stats] All stats reset to default")
	emit_signal("stats_changed")
